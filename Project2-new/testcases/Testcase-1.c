/* 
* =====================================
* Authored by:
* Aditi Gupta - 16CO202
* S Chethana Vaisali - 16CO255
* =====================================
* Compiler Design Project Phase-1: Lexical Analyser
* Test Case 1
 - Nested comments
 - Illegal header file
 - Illegal identifier name
 - Illegal token/character (like @, $, ?, etc.)
 - Incomplete string 
 - Unmatched comment
*/

/*
*   Error 1: Illegal Header File
*/
#include <<stdio.h>

int main()
{

/*
*   Error 2: Nested Comment
*/

/*This is a normal comment /*but we nested it here */ blah blah */
int a = 1, b = 2, c;
/*
*   Error 3: Illegal Identifier Name
*/
int 7upIsTheBestDrink;

/*
*   Error 4: Illegal token/character (in this case, "?" and ":")
*/
c = (a == b) ? 10 : 100;

/*
*   Error 5: Incomplete String
*/
char s[100] = "NITK Surathkal, Srinivasnagar;

/*
*   Error 6: Unmatched Comment
*/

/* This is an unmatched comment, i.e, it does not terminate

}