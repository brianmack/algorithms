module knapsack

import PyPlot
import StatsBase


# ------------------------------------
# Fractional Knapsack (homework)
# ------------------------------------

"""
Get v/s ratio and return in a new array.  Inputs are value and size
arrays.
"""
function compute_value_ratios(v::Array{Float64}, s::Array{Float64})
    r = zeros(Float64, length(v))
    for i in 1:length(v)    
        r[i] = v[i] / s[i]
    end
    return r, sortperm(r, rev=true);
end        


"""
Homework assignment 2 answer:  
Here we're allowed to pack fractional items.  Sort in decreasing v/s,
(or increasing s/v), and choose as much as possible from each object
before moving onto the next until target or capacity is reached.
"""
function fractional_knapsack(
    v::Array{Float64}, s::Array{Float64}, target, capacity)

    p = zeros(Float64, length(v))
    r, sort_indices = compute_value_ratios(v, s)

    for i in sort_indices
        
        if target <= 0 || capacity <= 0
            break
        end
        
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
N = 1000.0
function round_input(v::Array{Float64}, v_max)
    
    alpha = N / v_max # rounding constant
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
    
    println("s = ", s)
    println("v = ", v)
    println("v_r = ", v_rounded)
    
    # dimensions are m objects by n*N values, plus one for the zero index
    values = 0:(N * length(v))
    nvalues = length(values) 
    dp = fill(capacity + 1, length(s), nvalues)
    
    # initialize
    dp[1, 1] = 0.0
    dp[1, 2] = s[1]
    for val in 0:v_rounded[1]
        dp[1,val + 1] = s[1]
    end

    for i in 2:length(s)
        for j in 1:(v_rounded[i] - 1)
            dp[i, j] = dp[i - 1, j]
        end
        for j in v_rounded[i]:nvalues
            dp[i, j] = min(
                dp[i - 1, j],
                dp[i - 1, (j - v_rounded[i]) + 1]  + s[i])
        end
    end

    # Walk backward (from highest to lowest value) over the final
    # row of the array until you reach a size lower than capacity.
    max_val = 0.0
    for (i, size_) in enumerate(dp[length(s), end:-1:1])
        if size_ <= capacity
            # no need to index to zero with a '+1' because 'nvalues'
            # already accounts for the extra index.
            return max_val * (v_max / N)
        end
    end
    return 0.0
    return max_val * (v_max / N)
end

end
