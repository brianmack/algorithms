

include("algorithm.jl")
using PyPlot


X = init_similarity_matrix(5)
println(X)
Z = do_2cluster(X, 1000, .1)
println(Z)

print(plot(Z[:,1], Z[:,2]))


