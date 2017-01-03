""" Module for an approximation algorithm to solve knapsack-type
problems.  In the knapsack, we have some capacity 'B', and some
items with a size dimension and a value dimension.  The goal is
to maximize value with a constraint on size by choosing the 
optimal items to include.

This module implements the hard 0/1 version of the problem -- 
only whole items allowed -- as well as the relaxed fractional
packing problem.

Presented as part of the approximation algorithms course, the
key concept was in rounding the input.  (In the previous set
cover problem lesson, we had rounded the output from a LP
solution.)  In both cases, we manipulate our input or output
values to conform to some formulation of the problem that we do
know how to solve, and using which we can make some guarantees
about performance and accuracy.
"""

module knapsack

import PyPlot
import StatsBase


# ------------------------------------
# Fractional Knapsack (homework)
# ------------------------------------

"""
Get v/s ratio and return in a new array.  

Inputs are value and size arrays.
Returns v/s ratio array, and perumted indices - (iterate over
    the permuted vector to access the rows of [v/s] in sorted
    order...)
"""
function compute_value_ratios(v::Array{Float64}, s::Array{Float64})
    r = zeros(Float64, length(v))
    for i in 1:length(v)    
        r[i] = v[i] / s[i]
    end
    return r, StatsBase.sortperm(r, rev=true);
end        


""" Sort parallel arrays -- meaning, arrays where elements of
one array correspond pairwise to elements of another array.
Inputs are v1 - a reference array - and v2, an array to which
the sorting of v1 will be applied.  (v1 is also sorted).
Arrays are returned in sorted order."""
function sort_arrs(v_ref, v_apply)
    perm_i = StatsBase.sortperm(v_ref, rev=false)  #[end:-1:1]
    return v_ref[perm_i], v_apply[perm_i]
end


"""
Algorithm for homework special case --
In the special case, we are asked to relax the constraint of having
to include whole items in the knapsack.  

Recall that the greedy knapsack solution behaves badly when size != value:
A small, high value item blocks the entry of a much larger, higher value
item.  But with fractional packings allowed, this problem disappears.

To achieve the optimal fractional packing, sort in decreasing v/s,
(or increasing s/v), and choose as much as possible from each object
before moving onto the next until target or capacity is reached.

In this assignment, 'target' is used just like a more-constrained 
capacity... so we can just use 'capacity' and set it to the value
of 'target', simplifying the program."""
function fractional_knapsack(
    v::Array{Float64}, s::Array{Float64}, target, capacity)

    # the fractional _p_acking amount for each item
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
The point of lesson 2! : rounding the input.  Here we manipulate our
approximation scheme via N, the number of values to map into.  We
need to be able to represent values by indices in an array, which are
integers.  Scale them such that they fall between 1 and N and are
floored -- the difference between rounded and non-rounded values
is our approximation error."""
function round_input(v::Array{Float64}, v_max, N)
    
    if N < v_max
        println("WARNING: Rounding constant < max value of items: setting
            equal so that approximation ratio is 1.")
        N = v_max
    end
    
    # alpha is the rounding constant 
    alpha = N / v_max

    # array to hold the rounded input values 
    v_rounded = Array(Int64, length(v))
    for i in 1:length(v)
        v_rounded[i] = floor(v[i] * alpha)
    end

    return v_rounded
end


"""
The general case knapsack algorithm.  Uses an array to store combinations
of values and sizes attained while doing recurrence (packing the knapsack).
Inputs are rounded down to achieve a solution within error = 1/N of OPT.

The dimensions of the table 'A' are:
    
    A[<number of items> , <value of items>]

So A[i,v] tells you the minimum size required to achieve value v_i.

This implementation differs from the standard in that the column 
dimension of the matrix corresponds to values, not sizes.  This
is because it has to work for arbitrary sized values, but the assumption
of the base algorithm deals in 'small N'.  We are approximating the 
optimal value, not the size.  The larger we make N, the more accurate
the approximation but the worse the run time.

The running time of this algorithm is N*n^2 ... n items, n*N columns."""
function fill_knapsack(
    v::Array{Float64}, s::Array{Float64}, capacity, N)

    # sort arrays in order of values so that later rows can reference
    # work of earlier rows.
    s, v = sort_arrs(s, v)

    v_max = maximum(v) 
    v_rounded = round_input(v, v_max, N)
    
    println("sizes = ", s)
    println("values = ", v)
    println("rounded values = ", v_rounded)
    println("sum of values = ", sum(v))

    # dimensions are m objects by n*N values + 1 (for the zero index)
    # it's n*N so that we have some head room ... in the maximum,
    # we pack all values and all values are the max size.

    # array is filled > capacity unless otherwise 
    # overwritten by the recurrence
    values = 0:(N * length(v))
    nvalues = length(values) 
    dp = fill(capacity + 1, length(s), nvalues)
    
    # initialize -- top corner has zero size and zero value
    # will have the minimum value of 1, so this is safe
    dp[1, 1] = 0.0
    
    # rep first object across first row (any arbitrary object
    # can achieve up to v_rounded_i with size_i
    for j in 2:v_rounded[1] + 1
        dp[1, j] = s[1]
    end

    for i in 2:length(s)
        # not possible to have a valid size for value this large, 
        # so don't do any work for the 'upper triangle'
        #last_index = i * N + 1

        # can we achieve v_i using some combo of the previous items,
        # or do we need to include this item to get there?
        
        # also record the best value seen so far for size < capacity
        # to avoid re-scanning the array at the end

        # best size to achieve values up until this value
        for v_i in 1:v_rounded[i] + 1
            dp[i, v_i] = min(dp[i - 1, v_i], s[i])
        end

        # for all values > v_i, does adding item i improve on 
        # value / size ratio?
        for v_i in v_rounded[i] + 2:size(dp)[2] 
            
            # one indexed -- when v_i - v_rounded[i] = 0 ; use index 1 
            dp[i, v_i] = min(
                    dp[i - 1, v_i],
                    dp[i - 1, (v_i - v_rounded[i])]  + s[i])

        end
    end


    # basically a function to print the < B items in the matrix to
    # visualize what's going on
    println("i: size: value: values->")
    for i in 1:size(dp)[1]
        print(i, ": ", s[i], ": ", v_rounded[i], "| ")
        for j in 1:size(dp)[2]
            size_ = dp[i, j]
            if size_ <= capacity
                print(size_, " ")
            else
                print("\n")
                break
            end
        end
    end
            
    # Walk backward (from highest to lowest value) over the final
    # row of the array until you reach a size lower than capacity.
    max_val = 0.0
    for (i, size_) in enumerate(dp[end, end:-1:1])

        # because enumerate syntax only gives indices relative to number
        # of items seen, not to reversal of array indices
        j = size(dp)[2] - i + 1
        
        #println("j = ", j, ", size = ", size_)
        if size_ <= capacity
            # value (re-scaled), size
            #println("scaling factor: ", v_max / N)
            #println("scaled best value: ", j + 1)
            
            return (j - 1) * (v_max / N), dp[end, j]  # +1 to make interpetable as value
        end
    end
    return 0.0, 0.0
end


end # module
