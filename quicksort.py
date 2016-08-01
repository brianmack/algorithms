"""
Homework for the Algorithms coursera course 

May 4, 2014
"""

import random


def quicksort(S):
    """ Non in-place version of quicksort (not used). 
    Input:
        S is an array to be sorted.
    """
    
    if len(S) <= 1:
        return S
    indices = range(0,len(S))
    pivot_i = random.choice(indices)
    pivot = S[pivot_i]
    less_ = []
    more_ = []
    for i in indices:
        if i == pivot_i:
            continue
        if S[i] < pivot:
            less_.append(S[i])
        else: 
            more_.append(S[i])
    return quicksort(less_) + [pivot] + quicksort(more_)

    

def quicksort_in_place(S, left, right):
    """ Organizer function for dividing S up into sub-jobs.
    Inputs:
        S: array to sort
        left:  left index
        right:  right index
    Returns:
        S, sorted in place
    """
    if left < right:
        
        i = random.choice(range(left, right))
        print "random i:", i

        new = partition(S, left, right, i)
        print "new pivot:", new

        quicksort_in_place(S, left, new)
        quicksort_in_place(S, new+1, right)
    else:
        pass
    

def partition(S, left, right, i):
    """ Swap around randomized pivot.
    Inputs:
        S: array to sort
        left:  left index
        right:  right index
        i:  pivot
    Returns:
        S, with swapped values
    """

    # define pivot
    pivot = S[i]
    
    print "\t", left, right, i
    print "\t", S[left:right]

    # swap if pivot is not first index
    if not left==i:
        print "\t\t", "swapping i to left"
        S[i], S[left] = S[left], S[i]
        print "\t\t", S[left:right]
    
    i=left+1
    for j in range(left+1,right):
        print "\tcomparing j, pivot:", S[j], pivot
        if S[j] <= pivot:
            S[j], S[i] = S[i], S[j]
            print "\t\tswapped: j,i:", S[i], S[j], S[left:right]
            i += 1
    S[i-1], S[left] = S[left], S[i-1]
    print "\t\tfinal swapped:", S[left:right]
    return i-1


if __name__ == "__main__":

    random.seed(1)
    S = [random.randint(0, 100) for x in range(10)]

    print S
    quicksort_in_place(S, 0, len(S))
    print S
