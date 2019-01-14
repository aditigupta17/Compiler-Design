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
