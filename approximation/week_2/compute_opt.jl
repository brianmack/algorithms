#"""
#Executing script for knapsack examples. 
#
#Invocation:
#
#  julia compute_opt.jl objects0.txt 7 10
#  julia compute_opt.jl objects0.txt 3 10
#  julia compute_opt.jl objects0.txt 3 100
#
# (this is all commented out because Julia didn't like my script
# docstring)
#"""


# in case not set in .juliarc
push!(LOAD_PATH, "./")


using DataFrames

import knapsack


required_args_str = """
    1. (str) filename to data in csv format (v=value, s=size);
        other columns will be read but discarded
    2. (int) B (capacity of knapsack)
    3. (int) N (accuracy of approximation)
"""

if length(ARGS) < 3
    print("missing required args:\n", required_args_str)
    println("exiting...")
    exit(1)
end


data_fname = ARGS[1];
B = parse(Float64, ARGS[2]);
N = parse(Float64, ARGS[3]);

println("reading data file...")
data = readtable(data_fname);

v = convert(Array{Float64}, data[:v])
s = convert(Array{Float64}, data[:s])

println("fill knapsack:")
print(">>>>>>>>>>>\n")
println(knapsack.fill_knapsack(v, s, B, N))

