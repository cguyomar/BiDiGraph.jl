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

# Methods

is_directed(::Type{MetaDiGraph}) = true
is_directed(g::MetaBiDiGraph) = true
