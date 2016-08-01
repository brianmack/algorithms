#include <stdio.h>
#include <stdlib.h>

#define ARRLEN 100000

/* 
Brian's first C program, a divide and conquer sorting 
algorithm running in O(n log n) time and THETA(n) space.
*/

void print_array(int A[], int start_i, int len);
void copy_array(int A[], int B[], int end);
void merge(int S[], int tmp_S[], int begin, int middle, int end);
void split_merge(int S[], int tmp_S[], int begin, int end);


// create random array and pass to mergesort
main()
{
	int random_arr[ARRLEN];
	int tmp_arr[ARRLEN];
	int i, number;

	i=0;
	FILE* fp = fopen("IntegerArray.txt", "r");
	while(fscanf(fp, "%i", & number)==1 && i<100000)
		random_arr[i++] = number;
	

	//for(i = 0; i<ARRLEN; ++i)
	//	random_arr[i] = rand() % (ARRLEN * 5);

	printf("starting with random array:\n");
	print_array(random_arr, 0, ARRLEN);	
	
	split_merge(random_arr, tmp_arr, 0, ARRLEN);
	
	printf("rearranged to order:\n");
	print_array(random_arr, 0, ARRLEN);	

	return 0;
}

/* for debugging and general display purposes */
void print_array(int A[], int start_i, int len)
{
	int i;
	printf("[ ");
	for(i=start_i; i<len; ++i)
		printf("%i ", A[i]);
	printf("]\n");
}

/* special version that copies select indices from A
	into a new array of smaller size */
void copy_array(int *src, int *dest, int end)
{
	while(end-- > 0)
		*dest++ = *src++;
}

/* recursively split array to small chunks and merge back */
void split_merge(int S[], int tmp_S[], int begin, int end)
{
	int size, middle;
	size = end - begin;
	middle = begin + (size / 2);
	if (size < 2)
		return;
	
	split_merge(S, tmp_S, begin, middle);
	split_merge(S, tmp_S, middle, end);
	merge(S, tmp_S, begin, middle, end);
}

/* for a sub-part of main array S given by starting and
	ending indices, split in half, move pointers to a
	tmp array, and then walk the tmp arrays, restoring
	pointers back in S in sorted order */
void merge(int *S, int *tmp_S, int begin, int middle, int end)
{
	// some indices
	int i, j;

	copy_array(S + begin, tmp_S + begin, end);
	i = begin, j = middle;
	
	// printf("\told S:\t");
	// print_array(S, 0, 8);
	
	S += begin;

	// printf("\tmid S:\t");
	// print_array(S, 0, 8);
	
	while((i<middle) && (j<end))
		if(tmp_S[i] <= tmp_S[j]) 
			*S++ = tmp_S[i++];
		else
			*S++ = tmp_S[j++];
	
	while(i < middle)
		*S++ = tmp_S[i++];
	while(j < end)
		*S++ = tmp_S[j++];

	// printf("\tnew S:\t");
	// print_array(S, 0, 8);

}

