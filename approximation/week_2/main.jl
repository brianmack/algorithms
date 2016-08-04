

using DataFrames

import knapsack

data_fname = ARGS[1];
t = parse(Float64, ARGS[2]);
b = parse(Float64, ARGS[3]);

data = readtable(data_fname);

v = convert(Array{Float64}, data[:v])
s = convert(Array{Float64}, data[:s])

print(string(v) * "\n")
print(string(s) * "\n")

#t = 3.1
#b = 1
println(knapsack.fractional_knapsack(v, s, t, b))

println(v)
print(">>>>>>>>>>>\n")
println(knapsack.fill_knapsack(v, s, t, b))

