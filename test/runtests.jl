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



## MetaGraphs

mg = MetaBiDiGraph(3)

add_vertex!(mg)

e1 = SimpleBiEdge(1,2,"+","+")
e2 = SimpleBiEdge(1,3,"-","+")
e3 = SimpleBiEdge(2,4,"-","-")

@test add_edge!(mg,e1)
@test add_edge!(mg,e2)
@test add_edge!(mg,e3)
