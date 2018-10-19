module BiDiGraph

using LightGraphs


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

import Base:show

export SimpleBiDiGraph, inneighbors, add_edge!, has_edge,edges,vertices


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

function show(io::IO, g::SimpleBiDiGraph)
    print(io, "{$(nv(g)), $(ne(g))} bidirected graph")
end

function has_edge(g::SimpleBiDiGraph, e::SimpleBiEdge)
    for E in edges(g)
        if e==e
            return(true)
        end
    end
    return(false)
end

function outneighbors(g::SimpleBiDiGraph,v::Int)
    outedges = filter(e -> e.src == v && e.indir == "+" ,edges(g))
    f = [e.dst for e in outedges]
    outedges = filter(e -> e.dst == v && e.indir == "-" ,edges(g))
    b = [e.src for e in outedges]
    return append!(f,b)
end

function inneighbors(g::SimpleBiDiGraph,v::Int)
    outedges = filter(e -> e.dst == v && e.indir == "+" ,edges(g))
    f = [e.src for e in outedges]
    outedges = filter(e -> e.src == v && e.indir == "-" ,edges(g))
    b = [e.dst for e in outedges]
    return append!(f,b)
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

end # module
