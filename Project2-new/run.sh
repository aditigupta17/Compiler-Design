#!/bin/bash

lex scanner.l
yacc -d parser.y
gcc -w -g y.tab.c -ll -ly -o parser
