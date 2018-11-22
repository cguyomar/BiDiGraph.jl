module BiDiGraph

using LightGraphs
using MetaGraphs

import Base:show,eltype

import LightGraphs:
    _NI, AbstractGraph, AbstractEdge, AbstractEdgeIter,
    AbstractSimpleGraph,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    add_vertex!, add_edge!, rem_vertex!, rem_edge!,
    has_vertex, has_edge, inneighbors, outneighbors,
    indegree, outdegree, degree, has_self_loops, num_self_loops,

    add_vertices!, adjacency_matrix, weights, connected_components,

    AbstractGraphFormat, loadgraph, loadgraphs, savegraph,
pagerank, induced_subgraph

import MetaGraphs:
    AbstractMetaGraph, PropDict, MetaDict, weighttype, _hasdict,clear_props!,props,set_props!,set_prop!

export SimpleBiDiGraph, inneighbors, outneighbors, add_edge!, has_edge,edges,vertices,MetaBiDiGraph, nv, ne, props, rem_vertex!, list_edges, change_dir


include("./SimpleBiEdge.jl")


"""
    SimpleBiDiGraph{T, U}
A type representing a bi-directed graph.
"""
mutable struct SimpleBiDiGraph <: AbstractSimpleGraph{Int}
    ne::Int
    elist::Array{SimpleBiEdge}
    vlist::Array{Int}
    # Implemented as an edge list
    # Todo : Think of a better implementation
    SimpleBiDiGraph(n,elist,vlist) = new(n,elist,vlist)
end


# Constructors
function SimpleBiDiGraph(n::Integer=0)
    # fadjlist = [Vector{T}() for _ = one(T):n]
    # badjlist = [Vector{T}() for _ = one(T):n]
    elist = Array{SimpleBiEdge,1}(undef,0)
    vlist = collect(1:n)
    return SimpleBiDiGraph(0, elist,vlist)
end

ne(g::SimpleBiDiGraph) = g.ne
nv(g::SimpleBiDiGraph) = length(g.vlist)
vertices(g::SimpleBiDiGraph) = g.vlist
edges(g::SimpleBiDiGraph) = g.elist
edgetype(g::SimpleBiDiGraph) = SimpleBiEdge
is_directed(g::SimpleBiDiGraph) = true
eltype(g::SimpleBiDiGraph) = Int

function show(io::IO, g::SimpleBiDiGraph)
    print(io, "{$(nv(g)), $(ne(g))} bidirected graph")
end

function has_edge(g::SimpleBiDiGraph, e::SimpleBiEdge)
    for E in edges(g)
        if E==e
            return(true)
        end
    end
    return(false)
end

function outneighbors(g::SimpleBiDiGraph,v::Int)
    outedges = filter(e -> e.src == v && e.indir == "+" ,edges(g))
    f = [e.dst for e in outedges]
    outedges = filter(e -> e.dst == v && e.outdir == "-" ,edges(g))
    b = [e.src for e in outedges]
    return append!(f,b)
end

function inneighbors(g::SimpleBiDiGraph,v::Int)
    outedges = filter(e -> e.dst == v && e.outdir == "+" ,edges(g))
    f = [e.src for e in outedges]
    outedges = filter(e -> e.src == v && e.indir == "-" ,edges(g))
    b = [e.dst for e in outedges]
    return append!(f,b)
end

function list_edges(g::SimpleBiDiGraph,v1,v2)
    # Return all edges connecting v1 and v2, regardless the directions
    (v1 in vertices(g) && v2 in vertices(g)) || return(Array{SimpleBiEdge,1}())
    return(filter(e -> e.dst in [v1,v2] && e.src in [v1,v2], edges(g)))
end



# Mutability methods
function add_vertex!(g::SimpleBiDiGraph)
    (nv(g) + one(Int) <= nv(g)) && return false       # test for overflow
    push!(g.vlist, length(g.vlist)+1)
    return true
end

function add_edge!(g::SimpleBiDiGraph, e::SimpleBiEdge)
    s, d = Tuple(e)
    verts = vertices(g)
    (s in verts && d in verts) || return false  # edge out of bounds
    push!(g.elist,e)

    g.ne += 1
    return true  # edge successfully added
end

function rem_edge!(g::SimpleBiDiGraph, e::SimpleBiEdge)
    for (i,E) in enumerate(g.elist)
        if e == E
            deleteat!(g.elist,i)
            g.ne -= 1
            return(true)
        end
    end
    return(false)
end


function rem_vertex!(g::SimpleBiDiGraph,v::Int)
    # Kept LightGraph behavior : v is replaced by the last vertex
    v in vertices(g) || return false
    n = nv(g)
    v_edges = copy(filter(e -> e.dst == v || e.src == v,g.elist))


    for e in v_edges
        rem_edge!(g,e)
    end
    n_inedges = copy(filter(e -> e.dst == n,g.elist))
    n_outedges = copy(filter(e -> e.src == n,g.elist))

    if v != n
        # add the edges from n back to  v, and remove edges to/from n
        for e in n_inedges
            add_edge!(g,SimpleBiEdge(e.src,v,e.indir,e.outdir))
            rem_edge!(g,e)
        end
        for e in n_outedges
            add_edge!(g,SimpleBiEdge(v,e.dst,e.indir,e.outdir))
            rem_edge!(g,e)
        end
    end
    pop!(g.vlist)
    return(true)
end

function change_dir(g::SimpleBiDiGraph,n1,n2)
    es = list_edges(g,n1,n2)
    @assert length(es)==1
    if change_dir(es[1])
        return(true)
    else return(false)
    end
end




include("./metabidigraph.jl")


end # module
