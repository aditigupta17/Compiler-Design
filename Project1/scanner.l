/*
* Compiler Design Project Phase 1 - Scanner for C-language
*
* File		:  tables.h
*
* Description	:  This file contains functions related to hash organised symbol and constant tables.
*	       	   The functions implemented are:
*		   
*
*
* Authors	:  Aditi Gupta - 16CO202, S Chethana Vaisali - 16CO255
* Date		: 14th January 2019
Pre-processor instructions
• Single-line comments
• Multi-line comments
• Errors for unmatched comments
• Errors for nested comments
• Parentheses (all types)
• Operators
• Literals (integer, float, string)
• Errors for unclean integers and floating point numbers
• Errors for incomplete strings
• Keywords
• Identifiers

*/

%{

#include <stdlib.h>
#include <stdio.h>
#include "tables.h"
#include "tokens.h"


struct node** symbol_table;
struct node** constant_table;
int cmnt_strt = 0;

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

"int"                             {printf("\t%-30s %-40s %3d\n",yytext,"keyword int",INT);}
"long"                            {printf("\t%-30s %-40s %3d\n",yytext,"keyword long",LONG);}
"char"				  {printf("\t%-30s %-40s %3d\n",yytext,"keyword char",CHAR);}
"long long"                       {printf("\t%-30s %-40s %3d\n",yytext,"keyword long long",LONG_LONG);}
"short"                           {printf("\t%-30s %-40s %3d\n",yytext,"keyword short",SHORT);}
"signed"                          {printf("\t%-30s %-40s %3d\n",yytext,"keyword signed",SIGNED);}
"unsigned"                        {printf("\t%-30s %-40s %3d\n",yytext,"keyword unsigned",UNSIGNED);}
"for"                             {printf("\t%-30s %-40s %3d\n",yytext,"keyword for",FOR);}
"while"                             {printf("\t%-30s %-40s %3d\n",yytext,"keyword while",WHILE);}
"break"                           {printf("\t%-30s %-40s %3d\n",yytext,"keyword break",BREAK);}
"continue"                        {printf("\t%-30s %-40s %3d\n",yytext,"keyword continue",CONTINUE);}
"if"                              {printf("\t%-30s %-40s %3d\n",yytext,"keyword if",IF);}
"else"                            {printf("\t%-30s %-40s %3d\n",yytext,"keyword else",ELSE);}
"return"                          {printf("\t%-30s %-40s %3d\n",yytext,"keyword return",RETURN);}

{identifier}                      {printf("\t%-30s %-40s %3d\n", yytext,"Identifier",IDENTIFIER);
                                  insert( symbol_table,yytext,IDENTIFIER );}				

{ws}                              ;
[+\-]?[0][x|X]{hex}+[lLuU]?        {printf("\t%-30s %-40s %3d\n", yytext,"Hex Constant",HEX_CONSTANT);
									insert( constant_table,yytext,HEX_CONSTANT);}
[+\-]?{digit}+[lLuU]?              {printf("\t%-30s %-40s %3d\n", yytext,"Decimal Constant",DEC_CONSTANT);
									insert( constant_table,yytext,DEC_CONSTANT);}
"/*"                              {cmnt_strt = yylineno; BEGIN CMNT;}
<CMNT>.|{ws}                      ;
<CMNT>\n                          {yylineno++;}
<CMNT>"*/"                        {BEGIN INITIAL;}
<CMNT>"/*"                        {printf("%s\nLine %3d: Nested comments are not valid!\n%s\n",KRED,yylineno,KNRM);}
<CMNT><<EOF>>                     {printf("%s\nLine %3d: Unterminated comment\n%s\n", KRED,cmnt_strt,KNRM); yyterminate();}
^"#include"                       {BEGIN PREPROC;}
<PREPROC>"<"[^<>\n]+">"            {printf("\t#include%-22s %-40s %3d\n",yytext,"Header File",HEADER_FILE);}
<PREPROC>{ws}                       ;
<PREPROC>\"[^"\n]+\"              {printf("\t#include%-22s %-40s %3d\n",yytext,"Header File",HEADER_FILE);}
<PREPROC>\n                       {yylineno++; BEGIN INITIAL;}
<PREPROC>.                        {printf("%s\n%40s%10d%s\n%s",KRED,"Illegal header file format at",yylineno,"\n",KNRM);}
"//".*                            ;

\"[^\"\n]*\"     {

  if(yytext[yyleng-2]=='\\') /* check if it was an escaped quote */
  {
    yyless(yyleng-1);       /* push the quote back if it was escaped */
    yymore();
  }
  else
  insert( constant_table,yytext,STRING);
 }

\"[^\"\n]*$                     {printf("%s\nLine %3d:Unterminated string %s\n%s\n",KRED,yylineno,yytext,KNRM);}
{digit}+({letter}|_)+	        {printf("%s\nLine %3d: Illegal identifier name %s\n%s\n",KRED,yylineno,yytext,KNRM);}
\n                              {yylineno++;}
"--"			                {printf("\t%-30s %-40s %3d\n",yytext,"Decrement Operator ",DECREMENT);}
"++"			                {printf("\t%-30s %-40s %3d\n",yytext,"Increment Operator ",INCREMENT);}
"+="			                {printf("\t%-30s %-40s %3d\n",yytext,"Addition assignment operator ",ADD_AND_ASS);}
"-="			                {printf("\t%-30s %-40s %3d\n",yytext,"Subtraction assignment operator ",SUB_AND_ASS);}
"->"			                {printf("\t%-30s %-40s %3d\n",yytext,"Indirection Operator ",PTR_SELECT);}
"&&"			                {printf("\t%-30s %-40s %3d\n",yytext,"Logical AND",LOGICAL_AND);}
"||"			                {printf("\t%-30s %-40s %3d\n",yytext,"Logical OR",LOGICAL_OR);}
"<="			                {printf("\t%-30s %-40s %3d\n",yytext,"Less than equal to",LS_THAN_EQ);}
">="			                {printf("\t%-30s %-40s %3d\n",yytext,"Greater than equal to",GR_THAN_EQ);}
"=="			                {printf("\t%-30s %-40s %3d\n",yytext,"Equal to",EQ);}
"!="		                    {printf("\t%-30s %-40s %3d\n",yytext,"Not equal to",NOT_EQ);}
";"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Delimiter",DELIMITER);}
"{"                             {printf("\t%-30s %-40s %3d\n",yytext,"Open Braces",OPEN_BRACES);}
"}"                             {printf("\t%-30s %-40s %3d\n",yytext,"Close braces",CLOSE_BRACES);}
","			                    {printf("\t%-30s %-40s %3d\n",yytext,"Comma",COMMA);}
"="			                    {printf("\t%-30s %-40s %3d\n",yytext,"Assignment",ASSIGN);}
"("			                    {printf("\t%-30s %-40s %3d\n",yytext,"Open bracket",OPEN_PAR);}
")"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Closed bracket",CLOSE_PAR);}
"["                             {printf("\t%-30s %-40s %3d\n",yytext,"Open square bracket",OPEN_SQ_BRKT);}
"]"                             {printf("\t%-30s %-40s %3d\n",yytext,"Closed square bracket",CLOSE_SQ_BRKT);}
"-"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator minus",MINUS);}
"+"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator plus",PLUS);}
"*"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator star",STAR);}
"/"		                        {printf("\t%-30s %-40s %3d\n",yytext,"Operator forward slash",FW_SLASH);}
"%"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator modulo",MODULO);}
"<"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator less than",LS_THAN);}
">"			                    {printf("\t%-30s %-40s %3d\n",yytext,"Operator greater than",GR_THAN);}
.                               {printf("Line %3d: Illegal character %s\n",yylineno,yytext);}

%%

int main()
{
  yyin=fopen("testcases/test-case-5.c","r");
  symbol_table=create_table();
  constant_table=create_table();
  printf("%s\n=====================================================================================================%s\n",KCYN,KNRM);
  printf("%s\n\t%-30s %-40s %-30s%s\n",KYEL,"Token","Class","Number",KCYN);
  printf("%s\n=====================================================================================================%s\n",KCYN,KNRM);
  yylex();
  printf("\n\tSymbol table");
  display(symbol_table);
  printf("\n\tConstants Table");
  display(constant_table);
}






