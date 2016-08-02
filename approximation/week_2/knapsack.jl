module knapsack

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
function fractional_knapsack(
    v::Array{Float64}, s::Array{Float64}, target, capacity)

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



"""
The point of lesson 2:  rounding the input.  Here we manipulate our
approximation scheme via N, the number of values we map to.
"""

N = 100.0
function round_input(v::Array{Float64}, v_max)
    
    alpha = N / v_max # rounding constant
    println("alpha ", alpha)
    v_rounded = Array(Int64, length(v))
    for i in 1:length(v)
        v_rounded[i] = floor(v[i] * alpha)
    end

    return v_rounded
end


"""
The general case knapsack algorithm.  Uses a table to store combinations
of values and sizes attained while doing recurrence (packing the knapsack).
Inputs are rounded down to achieve a solution within error = 1/N of OPT.
"""
function fill_knapsack(
    v::Array{Float64}, s::Array{Float64}, target, capacity)

    v_max = maximum(v) 
    v_rounded = round_input(v, v_max)
    
    println(s)
    println(v_rounded)
    
    # dimensions are m objects by n*N values, plus one for the zero index
    values = 0:(N * length(v))
    nvalues = length(values)
    dp = zeros(Float64, length(s), nvalues)
    
    # initialize
    
    
    dp[1, 1] = 0.0
    dp[1, 2] = s[1]
    for i in 1:v_rounded[1]
        dp[1,i] = s[1]
    end
    for i in v_rounded[1]:nvalues
        dp[1,i] = capacity + 1
    end

    for i in 2:length(s)
        for j in 1:v_rounded[i]
            dp[i, j] = dp[i - 1, j]
        end
        for j in (v_rounded[i] + 1):nvalues
            dp[i, j] = min(
                dp[i - 1, j],
                dp[i - 1, j - (v_rounded[i])]  + s[i])
        end
    end

    println(dp)
    max_val = 0.0
    # clean this up -- was designed for true / false case when
    # you could identify first item != 0, doesn't work so hot now
    for (i, val) in enumerate(dp[length(s), end:-1:1])
        if val != capacity + 1
            max_val = nvalues - i
            break
        end
    end
    return max_val / N
end

end
