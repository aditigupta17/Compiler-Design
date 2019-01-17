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
*/

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

	for ( i = 0 ; i < HASH_TABLE_SIZE ; i++ )
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
			else if(ptr->token=402)
				strcpy(token_type,"HEADER FILE");
			else if(ptr->token=403)
				strcpy(token_type,"STRING");	
			printf("\t%-50s %-50s \n", ptr->lexeme,  token_type);
			
			ptr = ptr->next;
		}
	}

	
}

