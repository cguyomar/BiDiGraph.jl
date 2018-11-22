mutable struct MetaBiDiGraph <: AbstractMetaGraph{Int}
    graph::SimpleBiDiGraph
    vprops::Dict{Int,PropDict}
    eprops::Dict{SimpleBiEdge,PropDict}
    gprops::PropDict
    weightfield::Symbol
    defaultweight::Real
    metaindex::MetaDict
    indices::Set{Symbol}
end

# Constructors

function MetaBiDiGraph(x, weightfield::Symbol, defaultweight::Real)
    g = SimpleBiDiGraph(x)
    vprops = Dict{Int,PropDict}()
    eprops = Dict{SimpleBiEdge,PropDict}()
    gprops = PropDict()
    metaindex = MetaDict()
    idxs = Set{Symbol}()

    MetaBiDiGraph(g, vprops, eprops, gprops,
        weightfield, defaultweight,
        metaindex, idxs)
end

MetaBiDiGraph(x) = MetaBiDiGraph(x, :weight, 1.0)
weighttype(g::MetaBiDiGraph) = Real
# Methods

is_directed(::Type{MetaDiGraph}) = true
is_directed(g::MetaBiDiGraph) = true

inneighbors(g::MetaBiDiGraph, v::Integer) = inneighbors(g.graph, v)
outneighbors(g::MetaBiDiGraph, v::Integer) = outneighbors(g.graph, v)


_hasdict(g::MetaBiDiGraph, e::SimpleBiEdge) = haskey(g.eprops, e)
clear_props!(g::MetaBiDiGraph, e::SimpleBiEdge) = _hasdict(g, e) && delete!(g.eprops, e)

props(g::MetaBiDiGraph,e::SimpleBiEdge) = get(g.eprops, e, PropDict())



function rem_vertex!(g::MetaBiDiGraph,v::Int)
    # Kept LightGraph behavior : v is replaced by the last vertex
    v in vertices(g) || return false
    lastv = nv(g)

    # Collect properties of the last node of the graph
    lastv_in_edges = copy(filter(e -> e.dst == lastv,g.graph.elist)) # edges connected to last node
    lastv_out_edges = copy(filter(e -> e.src == lastv,g.graph.elist)) # edges connected to last node

    lastvprops = props(g, lastv)
    lasteinprops = Dict(e.src => props(g, e) for e in lastv_in_edges)
    lasteoutprops = Dict(e.dst => props(g, e) for e in lastv_out_edges)

    # Clear properties for the last node
    clear_props!(g,lastv)
    for e in lastv_in_edges
        clear_props!(g, e)
    end
    for e in lastv_out_edges
        clear_props!(g, e)
    end

    # Do the same for the node v (if different)
    if v != lastv # ignore if we're removing the last vertex.
        v_in_edges = copy(filter(e -> e.dst == v ,g.graph.elist))
        v_out_edges = copy(filter(e -> e.src == v ,g.graph.elist))

        for e in v_in_edges
            clear_props!(g,e)
        end
        for e in v_out_edges
            clear_props!(g,e)
        end
    end
    clear_props!(g, v)
    # remove v
    retval = rem_vertex!(g.graph, v)
    retval && set_props!(g, v, lastvprops)
    if v != lastv # ignore if we're removing the last vertex.
      for n in outneighbors(g, v)
          for e in lastv_in_edges
              set_props!(g, e, lasteinprops[e.src])
          end
          for e in lastv_out_edges
              set_props!(g, e, lasteoutprops[e.dst])
          end
      end
    end
    return retval
end





function set_props!(g::MetaBiDiGraph, e::SimpleBiEdge, d::Dict)
    #e = LightGraphs.is_ordered(_e) ? _e : reverse(_e)
    if has_edge(g, e)
        if !_hasdict(g, e)
            g.eprops[e] = d
        else
            merge!(g.eprops[e], d)
        end
        return true
    end
    return false
end

set_prop!(g::MetaBiDiGraph, e::SimpleBiEdge, prop::Symbol, val) = set_props!(g, e, Dict(prop => val))

function list_edges(g::MetaBiDiGraph,v1,v2)
    list_edges(g.graph,v1,v2)
end


function change_dir(g::MetaBiDiGraph,n1,n2)
    return(change_dir(g.graph,n1,n2))
end
