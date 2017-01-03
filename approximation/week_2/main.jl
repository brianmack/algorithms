#"""
#Executing script for knapsack examples. 

#Invocation:

#julia main.jl objects0.txt 5 10

#"""




# in case not set in .juliarc
push!(LOAD_PATH, "./")


using DataFrames

import knapsack


required_args_str = """
    1. (str) filename to data in csv format (v=value, s=size);
        other columns will be read but discarded
    2. (int) target (capacity of knapsack)
    3. (int) capacity of knapsack
"""

if length(ARGS) < 3
    print("missing required args:\n", required_args_str)
    println("exiting...")
    exit(1)
end

# 'b' because 'B' was the capacity of knapsack in lectures

data_fname = ARGS[1];
t = parse(Float64, ARGS[2]);
b = parse(Float64, ARGS[3]);

println("reading data file...")
data = readtable(data_fname);

v = convert(Array{Float64}, data[:v])
s = convert(Array{Float64}, data[:s])

println("initial values and sizes:")
print(string(v) * "\n")
print(string(s) * "\n")

println("fractional knapsack:")
println(knapsack.fractional_knapsack(v, s, t, b))

println(v)
println("fill knapsack:")
print(">>>>>>>>>>>\n")
println(knapsack.fill_knapsack(v, s, b))

