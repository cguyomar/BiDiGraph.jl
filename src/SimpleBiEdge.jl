
import LightGraphs: AbstractEdge, AbstractSimpleEdge
import Base: ==
export SimpleBiEdge

struct SimpleBiEdge <: AbstractSimpleEdge{Int}
    src::Int
    dst::Int
    indir::String
    outdir::String
end

# Accessors
indir(e::SimpleBiEdge) = e.indir
outdir(e::SimpleBiEdge) = e.outdir

# I/O
show(io::IO, e::SimpleBiEdge) = print(io, "Edge $(e.src) ($(e.indir)) => $(e.dst) ($(e.outdir))")

SimpleBiEdge(t::Tuple) = SimpleBiEdge(t[1], t[2],t[3],t[4])

==(e1::SimpleBiEdge, e2::SimpleBiEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2) && indir(e1) == indir(e2) && outdir(e1) == outdir(e2))
