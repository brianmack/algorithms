module Knapsack

import PyPlot
import StatsBase


# ------------------------------------
# Fractional Knapsack (homework)
# ------------------------------------

function compute_value_ratios(v::Array{Float64}, s::Array{Float64})
    r = zeros(Float64, length(v))
    for i in 1:length(v)    
        r[i] = v[i] / s[i]
    end
    return r, sortperm(r, rev=true);
end        


"""
Homework assignment 2 answer.

"""
function fractional_knapsack(v::Array{Float64}, 
    s::Array{Float64}, capacity, target)

    p = zeros(Float64, length(v))
    r, sort_indices = compute_value_ratios(v, s)

    println("r = ", r);
    println("sort order = ", sort_indices);

    for i in sort_indices
        
        if target <= 0 || capacity <= 0
            break
        end
        print("-------------\n")
        println("t=", target, " b=", capacity, " v=", v[i], " s=", s[i]);
        
        if target > v[i]
            p[i] = min(1, capacity / s[i])
        else
            p[i] = min(capacity / s[i], target / v[i])
        end
        target -= p[i] * v[i]
        capacity -= p[i] * s[i]
    end

    return p, target, capacity
end



end
