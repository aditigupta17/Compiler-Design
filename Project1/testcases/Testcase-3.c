/* 
* =====================================
* Authored by:
* Aditi Gupta - 16CO202
* S Chethana Vaisali - 16CO255
* =====================================
* Compiler Design Project Phase-1: Lexical Analyser
* Test Case 3
 - Test for single line comments
 - Test for multi-line comments
 - Test for single line nested comments
 - Test for multiline nested comments 
* The output in lex should remove all the comments including this one 
*/

/* #include <stdlib.h>

    {}.@All nonsense symbols */
//another comment
int main{}
{/**/

 printf("hello");
 /* comment inside// comment is ignored */
 //how about//this?
 /* now we /* try this */ */
 printf("COOL!!");
 return (0);
 /* this comment is unmatched.
}