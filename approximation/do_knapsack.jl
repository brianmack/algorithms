


data_fname = ARGS[1];

data, colnames = readdlm(data_fname, ',', header=true);

v = data[:,1]
s = data[:,2]

print(string(v) * "\n")
print(string(s) * "\n")


t = 3.1
b = 1

knapsack::fractional_knapsack(v, s, t, b)
