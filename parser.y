%{
#include <stdlib.h>
#include <stdio.h>
#include "tables.h"
#include "lex.yy.c"

int declaration_flag = 0;
int is_loop = 0;
int is_func = 0;
int func_type;
int param_list[10];
int p_idx = 0;
int p=0;
int rhs = 0;
int yyerror(char *msg);
void check_datatypes(int,int,int);
#define SYMBOL_TABLE symbol_table_list[cur_scope].sym_tab
  
extern entry_t** constant_table;
int cur_dtype;
table_t symbol_table_list[NUM_TABLES];
%}

%union
{
	int ival;
	int data_type;
	entry_t* entry;
}

%token <entry> IDENTIFIER


%token <entry> DEC_CONSTANT HEX_CONSTANT CHAR_CONSTANT FLOAT_CONSTANT
%token STRING


%token LOGICAL_AND LOGICAL_OR LS_EQ GR_EQ EQ NOT_EQ


%token MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN
%token INCREMENT DECREMENT


%token SHORT INT LONG LONG_LONG SIGNED UNSIGNED CONST VOID CHAR FLOAT

%token IF FOR WHILE CONTINUE BREAK RETURN

%type <entry> identifier
%type <entry> constant
%type <entry> array_index

%type <data_type> sub_expr
%type <data_type> unary_expr
%type <data_type> arithmetic_expr
%type <data_type> assignment_expr
%type <data_type> function_call
%type <data_type> array_access
%type <data_type> lhs

%left ','
%right '='
%left LOGICAL_OR
%left LOGICAL_AND
%left EQ NOT_EQ
%left '<' '>' LS_EQ GR_EQ
%left '+' '-'
%left '*' '/' '%'
%right '!'


%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start: start block
			 | block;

block: function
			 | declaration
			 ;

function: type identifier {
						declaration_flag = 0;
						func_type = cur_dtype;
						cur_scope = scope_entry();
					}
		'(' argument_list ')' {
						declaration_flag = 0;
						fill_parameter_list($2,param_list,p_idx);
						p_idx = 0;
						is_func = 1;
						p=1;
					}
		compound_stmt {
						is_func = 0;
					}
          			;

type : data_type pointer
     {declaration_flag = 1; }
     | data_type
     {declaration_flag = 1; }
		 ;

pointer: '*' pointer
    	 | '*'
       ;

data_type : sign_specifier type_specifier
    			| type_specifier
    			;

sign_specifier : SIGNED
    					 | UNSIGNED
    			 		 ;

type_specifier :INT                    {cur_dtype = INT;}
    |SHORT INT                         {cur_dtype = SHORT;}
    |SHORT                             {cur_dtype = SHORT;}
    |LONG                              {cur_dtype = LONG;}
	|LONG INT                          {cur_dtype = LONG;}
    |LONG_LONG                         {cur_dtype = LONG_LONG;}
    |LONG_LONG INT                     {cur_dtype = LONG_LONG;}
	|CHAR 				  			   {cur_dtype = CHAR;}
	|FLOAT 							  {cur_dtype = FLOAT;}
	|VOID							 {cur_dtype = VOID;}
    ;

 
argument_list : arguments
    					|
    					;
 
arguments : arguments ',' arg
    			| arg
    			;

 
arg : type identifier	{param_list[p_idx++] = $2->data_type;}
    ;


stmt:compound_stmt
    |single_stmt
    ;

 
compound_stmt :
				'{'	
				{
					if(!p)cur_scope = scope_entry();
					else p = 0;
				}

				statements '}'
				{cur_scope = exit_scope();}
    ;

statements:statements stmt
    |
    ;

 
single_stmt :if_block
    |for_block
    |while_block
    |declaration
    |function_call ';'
	|RETURN ';'	{
					if(is_func)
					{
						if(func_type != VOID)
						yyerror("return type (VOID) does not match function type");
					}
					else yyerror("return statement not inside function definition");
				}

	|CONTINUE ';' {if(!is_loop) {yyerror("Illegal use of continue");}}
	|BREAK ';'    {if(!is_loop) {yyerror("Illegal use of break");}}
	|RETURN sub_expr ';'
				{
					if(is_func)
					{
						if(func_type != $2)
						yyerror("return type does not match function type");
					}
					else yyerror("return statement not in function definition");
				}
    ;

for_block:FOR '(' expression_stmt  expression_stmt ')' {is_loop = 1;} stmt {is_loop = 0;}
    		 |FOR '(' expression_stmt expression_stmt expression ')' {is_loop = 1;} stmt {is_loop = 0;}
    		 ;

if_block:IF '(' expression ')' stmt 	%prec LOWER_THAN_ELSE
				|IF '(' expression ')' stmt ELSE stmt
    ;

while_block: WHILE '(' expression	')' {is_loop = 1;} stmt {is_loop = 0;}
		;

declaration: type  declaration_list ';'
           {declaration_flag = 0; }
					 | declaration_list ';'
					 | unary_expr ';'
					;

declaration_list: declaration_list ',' sub_decl
								|sub_decl
								;

sub_decl: assignment_expr
    		|identifier
    		|array_access
				;

expression_stmt: expression ';'
    					 | ';'
    			 		 ;

expression: expression ',' sub_expr
    			| sub_expr
					;

sub_expr:
    sub_expr '>' sub_expr				{check_datatypes($1,$3,2); $$ = $1;}
    |sub_expr '<' sub_expr				{check_datatypes($1,$3,2); $$ = $1;}
    |sub_expr EQ sub_expr				{check_datatypes($1,$3,2); $$ = $1;}
    |sub_expr NOT_EQ sub_expr			{check_datatypes($1,$3,2); $$ = $1;}
    |sub_expr LS_EQ sub_expr			{check_datatypes($1,$3,2); $$ = $1;}
    |sub_expr GR_EQ sub_expr			{check_datatypes($1,$3,2); $$ = $1;}
	|sub_expr LOGICAL_AND sub_expr		{check_datatypes($1,$3,2); $$ = $1;}
	|sub_expr LOGICAL_OR sub_expr		{check_datatypes($1,$3,2); $$ = $1;}
	|'!' sub_expr						{$$ = $2;}
	|arithmetic_expr					{$$ = $1;}
    |assignment_expr					{$$ = $1;}
	|unary_expr							{$$ = $1;}
    ;


assignment_expr :
	lhs assign_op  arithmetic_expr		{check_datatypes($1,$3,1); $$ = $3; rhs=0;}
    |lhs assign_op  array_access		{check_datatypes($1,$3,1); $$ = $3;rhs=0;}
    |lhs assign_op  function_call		{check_datatypes($1,$3,1); $$ = $3;rhs=0;}
	|lhs assign_op  unary_expr          {check_datatypes($1,$3,1); $$ = $3;rhs=0;}
	|unary_expr assign_op  unary_expr	{check_datatypes($1,$3,1); $$ = $3;rhs=0;}
    ;

unary_expr:	identifier INCREMENT				{$$ = $1->data_type;}
					| identifier DECREMENT		{$$ = $1->data_type;}
					| DECREMENT identifier		{$$ = $2->data_type;}
					| INCREMENT identifier		{$$ = $2->data_type;}
					;
lhs: identifier							{$$ = $1->data_type;}
   | array_access						{$$ = $1;}
	 ;

identifier:IDENTIFIER {
                        if(declaration_flag && !rhs) 
                        {
                            $1 = insert(SYMBOL_TABLE,yytext,INT_MAX,cur_dtype);
                            if($1 == NULL) yyerror("Redeclaration of variable");
                        }
                        else
                        {
                            $1 = search_recursive(yytext);
                            if($1 == NULL) yyerror("Variable not declared");
                        }
                        $$ = $1;
                      }
    			 ;

assign_op:'=' {rhs=1;}
    |ADD_ASSIGN {rhs=1;} 
    |SUB_ASSIGN {rhs=1;}
    |MUL_ASSIGN {rhs=1;}
    |DIV_ASSIGN {rhs=1;}
    |MOD_ASSIGN {rhs=1;}
    ;

arithmetic_expr: arithmetic_expr '+' arithmetic_expr	{check_datatypes($1,$3,0);}
    |arithmetic_expr '-' arithmetic_expr				{check_datatypes($1,$3,0);}
    |arithmetic_expr '*' arithmetic_expr				{check_datatypes($1,$3,0);}
    |arithmetic_expr '/' arithmetic_expr				{check_datatypes($1,$3,0);}
	|arithmetic_expr '%' arithmetic_expr				{check_datatypes($1,$3,0);}
	|'(' arithmetic_expr ')'							{$$ = $2;}
    |'-' arithmetic_expr %prec UMINUS					{$$ = $2;}
    |identifier											{$$ = $1->data_type;}
    |constant											{$$ = $1->data_type;}
    ;

constant: DEC_CONSTANT 		{$1->constant_flag=1; $$ = $1;}
    | HEX_CONSTANT			{$1->constant_flag=1; $$ = $1;}
	| CHAR_CONSTANT			{$1->constant_flag=1; $$ = $1;}
	| FLOAT_CONSTANT		{$1->constant_flag=1; $$ = $1;}
    ;

array_access: identifier '[' array_index ']'
				{
					if(declaration_flag)
					{
						if($3->value <= 0)
							yyerror("size of array is not positive");
						else if($3->constant_flag && !rhs) 
							$1->dimension = $3->value;
						else if(rhs){
							{
								if($3->value > $1->dimension)
									yyerror("Array index out of bound");
								if($3->value < 0)
									yyerror("Array index cannot be negative");
							}
						}
					}
					else if($3->constant_flag)
					{
						if($3->value > $1->dimension)
							yyerror("Array index out of bound");
						if($3->value < 0)
							yyerror("Array index cannot be negative");
					}
					$$ = $1->data_type;
				}
					;

array_index: constant				{$$ = $1;}
					 | identifier	{$$ = $1;}
					 ;

function_call: identifier '(' parameter_list ')'
		{
			$$ = $1->data_type;
			check_parameter_list($1,param_list,p_idx);
			p_idx = 0;
		}
        | identifier '(' ')'						
		{
			$$ = $1->data_type;
			check_parameter_list($1,param_list,p_idx);
			p_idx = 0;
		}
        ;

parameter_list:
              parameter_list ','  parameter
              |parameter
              ;

parameter: sub_expr			{param_list[p_idx++] = $1;}
		 | STRING			{param_list[p_idx++] = STRING;}
				 ;
%%

void check_datatypes(int left, int right, int flag)
{
	if(left != right)
	{
		switch(flag)
		{
			case 0: yyerror("Type mismatch in arithmetic expression"); break;
			case 1: yyerror("Type mismatch in assignment expression"); break;
			case 2: yyerror("Type mismatch in logical expression"); break;
		}
	}
}

int main(int argc, char *argv[])
{
	 int i;
	 for(i=0; i<NUM_TABLES;i++)
	 {
	  symbol_table_list[i].sym_tab = NULL;
	  symbol_table_list[i].parent = -1;
	 }

	constant_table = create_table();
  symbol_table_list[0].sym_tab = create_table();
	yyin = fopen(argv[1], "r");

	if(!yyparse())
	{
		printf("\nPARSING COMPLETE\n\n\n");
	}
	else
	{
			printf("\nPARSING FAILED!\n\n\n");
	}

	printf("SYMBOL TABLES\n\n");
	display_all();

	printf("CONSTANT TABLE");
	display_constant_table(constant_table);

	fclose(yyin);
	return 0;
}

int yyerror(char *msg)
{
	printf("Line no: %d Error message: %s Token: %s\n", yylineno, msg, yytext);
	exit(0);
}
