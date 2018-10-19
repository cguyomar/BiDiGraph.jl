using LightGraphs
using BiDiGraph

using Test


g = SimpleBiDiGraph(3)

@test ne(g)==0 && nv(g)==3

e = SimpleBiEdge(1,2,"+","+")

@test add_edge!(g,e)
@test ne(g)==1
@test 2 in g.fadjlist[1] && 1 in g.badjlist[2]

e = SimpleBiEdge(1,3,"-","+")
@test add_edge!(g,e)
@test 3 in g.badjlist[1] && 1 in g.badjlist[3]

e = SimpleBiEdge(1,3,"-","-")
@test add_edge!(g,e)
@test 3 in g.badjlist[1] && 1 in g.fadjlist[3]


# Problem : not possible to add several edges with same start and end node but different strands
# Solution : Change verification in add_edge by testing if e in edges(g)
# -> define edges and implement comparison?
