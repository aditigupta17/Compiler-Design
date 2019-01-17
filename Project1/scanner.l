/*
* Compiler Design Project Phase 1 - Scanner for C-language
* Authors	:  Aditi Gupta - 16CO202, S Chethana Vaisali - 16CO255
* Date		: 14th January 2019
*/

%{

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
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

#define HASH_TABLE_SIZE 100


// struct to hold entry
struct node
{
	char* lexeme;
	int token;
	struct node *next;
};


//Implementing djb2 hash function
unsigned int get_hash(char *str)
{
	unsigned int hash=5381;
	int c;
	
	while((c=*str++))
		hash=((hash << 5) + hash) + c;
	return hash % HASH_TABLE_SIZE;
}


//Create a new hash table
struct node** create_table()
{
	struct node** table_ptr =  NULL;
	
	table_ptr=(struct node**)malloc(sizeof(struct node*)*HASH_TABLE_SIZE);
	if(table_ptr==NULL)
	{
		printf("\n Cannot alocate memory for the table");
		exit(1);
	}

	int i;
	
	//Initialise all entries as NULL
	for( i = 0; i < HASH_TABLE_SIZE ; i++ )
	{
		table_ptr[i] = NULL ;
	}	

	return table_ptr;
}


//Create a node
struct node* create( char *lexeme, int token_name )
{
	struct node* newentry;

	/* Allocate space for newentry */
	if( ( newentry = malloc( sizeof( struct node* ) ) ) == NULL ) {
		return NULL;
	}
	/* Copy lexeme to newentry location using strdup (string-duplicate). Return NULL if it fails */
	if( ( newentry->lexeme = strdup( lexeme ) ) == NULL ) {
		return NULL;
	}

	newentry->token = token_name;
	newentry->next = NULL;

	return newentry;
}
	 

/* Search for an entry given a lexeme. Return a pointer to the entry of the lexeme if exists, else return NULL */
struct node* search( struct node** table_ptr , char* lexeme )
{
	uint32_t idx = 0;
	struct node* ptr;

	//get the index of this lexeme as per the hash function
	idx = get_hash ( lexeme );

	ptr = table_ptr[idx];

	while( ptr != NULL && strcmp( lexeme, ptr->lexeme ) != 0)
		ptr = ptr->next;

	if( ptr ==NULL)
		return NULL;
	else
		return ptr;
} 


//Insert a node into the hash table
void insert( struct node** hash_table_ptr, char* lexeme, int token_name )
{
	if( search( hash_table_ptr, lexeme ) != NULL) // If lexeme already exists, don't insert, return
	    return;

	uint32_t idx;
	struct node* newentry = NULL;
	struct node* head = NULL;

	idx = get_hash( lexeme ); // Get the index for this lexeme based on the hash function
	newentry = create( lexeme, token_name ); // Create an entry using the <lexeme, token> pair

	if(newentry == NULL) // In case there was some error while executing create_entry()
	{
		printf("Insert failed. New entry could not be created.");
		exit(1);
	}

	head = hash_table_ptr[idx]; // get the head entry at this index

	if(head == NULL) // This is the first lexeme that matches this hash index 
	{
		hash_table_ptr[idx] = newentry;
	}
	else // if not, add this entry to the head
	{
		newentry->next = hash_table_ptr[idx];
		hash_table_ptr[idx] = newentry;
	}
}

//Display all the entries of a hash table

void display ( struct node** table_ptr)
{
	int i;

	struct node* ptr;

	printf("%s\n=====================================================================================================\n",KCYN);

    	printf("%s\n\t%-50s %-50s\n",KYEL,"Token", "Token type");

    	printf("%s=====================================================================================================\n%s\n",KCYN,KNRM);

	for (i = 0; i < HASH_TABLE_SIZE ; i++ )
	{
		ptr = table_ptr[i];

		while( ptr != NULL )
		{
			char token_type[100];
			if(ptr->token==500)
				strcpy(token_type,"IDENTIFIER");
			else if(ptr->token==400)
				strcpy(token_type,"HEX_CONSTANT");
			else if(ptr->token==401)
				strcpy(token_type,"DEC_CONSTANT");
			else if(ptr->token==402)
				strcpy(token_type,"HEADER FILE");
			else if(ptr->token==403)
				strcpy(token_type,"STRING");	
			printf("\t%-50s %-50s \n", ptr->lexeme,  token_type);
			
			ptr = ptr->next;
		}
	}
}

enum keywords
{
  INT=100,
  LONG,
  LONG_LONG,
  SHORT,
  SIGNED,
  UNSIGNED,
  FOR,
  WHILE,
  BREAK,
  CONTINUE,
  RETURN,
  CHAR,
  IF,
  ELSE
};

enum operators
{
  DECREMENT=200,
  INCREMENT,
  PTR_SELECT,
  LOGICAL_AND,
  LOGICAL_OR,
  LS_THAN_EQ,
  GR_THAN_EQ,
  ADD_AND_ASS,
  SUB_AND_ASS,
  EQ,
  NOT_EQ,
  ASSIGN,
  MINUS,
  PLUS,
  STAR,
  MODULO,
  LS_THAN,
  GR_THAN
};

enum special_symbols
{
  DELIMITER=300,
  OPEN_BRACES,
  CLOSE_BRACES,
  COMMA,
  OPEN_PAR,
  CLOSE_PAR,
  OPEN_SQ_BRKT,
  CLOSE_SQ_BRKT,
  FW_SLASH
};

enum constants
{
  HEX_CONSTANT=400,
  DEC_CONSTANT,
  HEADER_FILE,
  STRING
};

enum IDENTIFIER
{
  IDENTIFIER=500
};


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
<PREPROC>"<"[^<>\n]+">"            {printf("\t#include%-22s %-40s %3d\n",yytext,"Header File",HEADER_FILE); BEGIN INITIAL;}
<PREPROC>{ws}                       ;
<PREPROC>\"[^"\n]+\"              {printf("\t#include%-22s %-40s %3d\n",yytext,"Header File",HEADER_FILE); BEGIN INITIAL;}
<PREPROC>\n                       {yylineno++; BEGIN INITIAL;}
<PREPROC>.                        {printf("%s\n%40s%10d%s\n%s",KRED,"Illegal header file format at",yylineno,"\n",KNRM); BEGIN INITIAL;}
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
.                               {printf("%s Line %3d: Illegal character %s%s\n",KRED, yylineno,yytext,KNRM);}

%%

int main()
{
  yyin=fopen("testcases/Testcase-5.c","r");
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






