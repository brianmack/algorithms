""" Contains core functions for doing the 2- and 3-d
clustering."""


# keeps values from converging to single point,
# aids in visualization - how does it affect
# convergence properties?
PERTURB_VAL = 0.1




#------------------------
# Utils
#------------------------


function init_similarity_matrix(n)

    X = randn(n, n)
    # make positive
    X = X*X'

    unit_scale_matrix(X)
    
    # set diagonal
    X[1:(n + 1):end] = 1.0

    return(X)
end


function unit_scale_matrix(X)

    X -= minimum(X)
    X /= maximum(X)

    return(X)
end

#------------------------
# NOT USED
#------------------------


function l2_distance(z1_vec, z2_vec)
    d = 0.0
    for i in 1:length(z1_vec)
        d += (z1_vec[i] + z2_vec[i])^2
    end
    return(d^(1/2))
end


# functional form of loss
function loss2(v, d)
    (v + d - 1)^2
end

# kl-divergence based loss function?
SHIFT_LOGVAL = 0.001
function loss3(v, r, d)
    (v + d - 1)^2 - (v - log(r + SHIFT_LOGVAL))
end


#------------------------
# 2-D Case
#------------------------

function pointwise_grad2(v, z_vec1, z_vec2)
    """ loss includes an attractive and repellant component.
        v:  correlation for this pair
        z_vec1: x,y pos. for item_i
        z_vec2: x,y pos. for item_j

    Gradient is a mix of attractive and repellent forces.
    """

    # z-vectors are row-cuts across column matrix of z positions
    len = size(z_vec1)[2] # size is (1, 2) in this case

    # will only apply gradient to a single point (x, y)
    grads = zeros(1, len)
    
    # go column-wise
    for i in 1:len
        z1, z2 =  z_vec1[i], z_vec2[i]
        grads[i] = (
            ((v + abs(z1 - z2) - 1) * sign(z1 - z2 + SHIFT_LOGVAL)) -
            (1 - (1 / ((z1 + z2 +  SHIFT_LOGVAL))))
        )
    end
    
    return grads
end


#TODO do x and y coordinates separately
function update2(X, Z, learning_rate)

    z_nrow, z_ncol = size(Z)
    updates = zeros(Z)

    
    for i in 1:z_nrow
        
        # in this case, a two-dimensional gradient matrix (a, b)...
        # gradient is summed over all pairs of points for index i
        grad_ = zeros(1, z_ncol)

        # for all pairs i, j
        for j in 1:z_nrow

            # no self-distance
            if j == i
                continue
            end

            # get gradient of this point relative to all positions 
            # pass as horizontal vector rep. to keep addition intuitive
            # now you have all x and y positional coordinates for rows
            # i and j;
            grad_ += pointwise_grad2(
                X[i,j], Z[i,:]', Z[j,:]') / 2.0

        end

        if i == z_nrow
            println(grad_)
        end
        
        updates[i,:] -= (learning_rate * (grad_ / (z_nrow - 1)))'
    end

    Z -= updates
    return(Z)
end


function do_2cluster(X, num_iter, learning_rate)
    

    # initialize positional matrix -- by making all ones, we
    # put all points at the same place and let repulsion and
    # attraction forces disperse them.
    #Z = ones(size(X)[1], 2) # two dimensions
    #Z = copy(X)

    # some different choices for init..
    Z = randn(size(X)[1], 2) #* 1000
    println(Z)
    #Z = [mapslices(sum, X, 1)' mapslices(sum, X, 2)]
    
    
    #anim = @animate
    #plot(Z[1,:], Z[2,:])
    
    for i in 1:num_iter

        Z = update2(X, Z, learning_rate)
        Z = unit_scale_matrix(Z)
        #if i % 10 == 0
        #    plot(Z[1,:], Z[2,:])
        #end
    end
    #gif(anim, "~/tmp/animations/learn.gif", fps=15)
 
    return(Z)
end



#----------------------------
# 3-d case
#----------------------------

function update3(X, r, Z, learning_rate)

    z_nrow, z_ncol = size(Z)
    updates = zeros(Z)
    for i in 1:z_nrow
        grad_ = zeros(1, z_ncol)
        for j in i:z_nrow
            # no self-distance
            if j == 1
                continue
            end
            grad_ += pointwise_grad3(X[i,j], [r[i] r[j]], Z[i,:]', Z[j,:]') / 2.0
        end
        updates[i,:] -= (learning_rate * (grad_ / (z_nrow - 1)))'
    end

    Z += updates
    return(Z)
end







# R1: ex. correlation matrix -- similarity matrix among points
#     in high dimensional space
# R2: ex. mutual information -- vector of values, one for each
#     data point
function do_3cluster(R1, r2, num_iter, learning_rate)

    Z = zeros(size(R1)[1], 2) # two dimensions
    for i in 1:num_iter
        Z = update3(R1, r2, Z, learning_rate)
        #if i % 10 == 0
        #    plot(Z[1,:], Z[2,:])
        #end
    end
 
    return(Z)
end



function pointwise_grad3(v, r, z_vec1, z_vec2)
    
    # z-vectors are row-cuts across column matrix of z positions
    len = size(z_vec1)[2]
    #print("v: ", v, " z: ", z_vec1, " size ",  size(z_vec1), " len ",  len, "\n")
    grads = zeros(1, len)
    for i in 1:len
        z1, z2 =  z_vec1[i], z_vec2[i]
        grads[i] = (
            ((v + abs(z1 - z2) - 1) * sign(z1 - z2 + SHIFT_LOGVAL)) - 
            (1 - (1 / ((z1 + z2 +  SHIFT_LOGVAL))))
        )
        #print(grads[i], "\n")
    end
    return(grads)
end
