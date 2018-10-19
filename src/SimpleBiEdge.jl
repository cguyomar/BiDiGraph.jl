
import LightGraphs: AbstractEdge, AbstractSimpleEdge
export SimpleBiEdge

struct SimpleBiEdge <: AbstractSimpleEdge{Int}
    src::Int
    dst::Int
    indir::String
    outdir::String
end

SimpleBiEdge(t::Tuple) = SimpleBiEdge(t[1], t[2],t[3],t[4])
