#!/bin/bash

lex scanner.l
cc lex.yy.c -ll
./a.out
