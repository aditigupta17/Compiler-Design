/*
* Compiler Design Project Phase 1 - Scanner for C-language
* Authors	:  Aditi Gupta - 16CO202, S Chethana Vaisali - 16CO255
* Date		: 14th January 2019
*/

%{


#include <stdint.h>
#include <limits.h>
#include <string.h>

#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT "\x1B[37m"

int cmnt_strt = 0;
//entry_t** symbol_table;
//entry_t** constant_table;

%}

letter [a-zA-Z]
digit [0-9]
ws  [ \t\r\f\v]+
identifier (_|{letter})({letter}|{digit}|_){0,31}
hex [0-9a-f]
BID		([0-9]|!|@|#|$|%)+([a-zA-Z0-9])+


 /* Exclusive states */
%x CMNT
%x PREPROC

%%

 /* Keywords*/

"int"                             {return INT;}
"long"                            {return LONG;}
"long long"                       {return LONG_LONG;}
"short"                           {return SHORT;}
"signed"                          {return SIGNED;}
"unsigned"                        {return UNSIGNED;}
"void"				  {return VOID;}
"for"                             {return FOR;}
"while"                           {return WHILE;}
"break"                           {return BREAK;}
"continue"                        {return CONTINUE;}
"if"                              {return IF;}
"else"                            {return ELSE;}
"return"                          {return RETURN;}

{identifier}                      {yylval.entry = insert(symbol_table, yytext, IDENTIFIER); return  IDENTIFIER;}				

{ws}                              ;

[+\-]?[0][x|X]{hex}+[lLuU]?        { yylval.dval = (int)strtol(yytext, NULL, 16); entry_t* t =insert(constant_table,yytext,HEX_CONSTANT); return  HEX_CONSTANT;}
[+\-]?{digit}+[lLuU]?              {yylval.dval = atoi(yytext);insert( constant_table,yytext,DEC_CONSTANT);
					return DEC_CONSTANT;}
"/*"                              {cmnt_strt = yylineno; BEGIN CMNT;}
<CMNT>.|{ws}                      ;
<CMNT>\n                          {yylineno++;}
<CMNT>"*/"                        {BEGIN INITIAL;}
<CMNT>"/*"                        {printf("%s\nLine %3d: Nested comments are not valid!\n%s\n",KRED,yylineno,KNRM);}
<CMNT><<EOF>>                     {printf("%s\nLine %3d: Unterminated comment\n%s\n", KRED,cmnt_strt,KNRM); yyterminate();}
"//".*                            ;

\"[^\"\n]*\"     {

  if(yytext[yyleng-2]=='\\') /* check if it was an escaped quote */
  {
    yyless(yyleng-1);       /* push the quote back if it was escaped */
    yymore();
  }
  else
  insert( constant_table,yytext,INT_MAX);
return STRING;
 }

\"[^\"\n]*$                     	{printf("%s\nLine %3d:Unterminated string %s\n%s\n",KRED,yylineno,yytext,KNRM);}
{digit}+({letter}|_)+	        	{printf("%s\nLine %3d: Illegal identifier name %s\n%s\n",KRED,yylineno,yytext,KNRM);}
\n                              	{yylineno++;}
"--"			                { return DECREMENT;}
"++"			                {return INCREMENT;}
"+="			                {return ADD_ASSIGN;}
"-="			                {return SUB_ASSIGN;}
"*="					{return MUL_ASSIGN;}
"/="					{return DIV_ASSIGN;}
"%="					{return MOD_ASSIGN;} 

"&&"			                {return LOGICAL_AND;}
"||"			                {return LOGICAL_OR;}
"<="			                {return LS_THAN_EQ;}
">="			                {return GR_THAN_EQ;}
"=="			                {return EQ;}
"!="		                    	{return NOT_EQ;}
.                               	{return yytext[0];}

%%







