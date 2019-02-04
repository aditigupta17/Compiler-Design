/* 
* =====================================
* Authored by:
* Aditi Gupta - 16CO202
* S Chethana Vaisali - 16CO255
* =====================================
* Compiler Design Project Phase-1: Lexical Analyser
* Test Case 5
 - Implementation of Binary Search
*/
int main () 
{ 
	int A[] = { 2, 3, 4, 10, 40 }; 
	int n = 5; 
    int first = 0, last = n, mid, flag = 0, key = 10;
    while(first <= last)
    {
        mid = (first+last)/2;
        if(A[mid] == key)
        {
            flag = 1;
            printf("\nElement found at location %d", mid + 1);         
            break;
        }
        else if(key > A[mid]) first = mid + 1;
        else last = mid - 1;
    }
	if(flag == 0) printf("\nElement not found.\n");
} 

