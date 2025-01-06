%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int line_num = 1;
%}

/* Regular definitions */
DIGIT       [0-9]
LETTER      [a-zA-Z]
ID          {LETTER}({LETTER}|{DIGIT}|"_")*
WHITESPACE  [ \t\r]+
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+"."{DIGIT}+
STRING      \"[^\"]*\"
CHAR        \'[^\']\'

%%

"fint"      { return T_INT; }
"ffloat"    { return T_FLOAT; }
"fchar"     { return T_CHAR; }
"fstring"   { return T_STRING; }
"f@int"     { return T_CONST_INT; }
"f@float"   { return T_CONST_FLOAT; }
"f@char"    { return T_CONST_CHAR; }
"f@string"  { return T_CONST_STRING; }
"faruki"    { return T_FARUKI; }
"emit"      { return T_EMIT; }
"_Check"    { return T_IF; }
"_orelse"   { return T_ELSE_IF; }
"_else"     { return T_ELSE; }
"_match"    { return T_SWITCH; }
"_Repeat"   { return T_FOR; }
"until"     { return T_WHILE; }
"from"      { return T_FROM; }
"to"        { return T_TO; }
"with"      { return T_WITH; }
"then"      { return T_THEN; }
"void"      { return T_VOID; }
"default"   { return T_DEFAULT; }

"+"         { return T_PLUS; }
"-"         { return T_MINUS; }
"*"         { return T_MULTIPLY; }
"/"         { return T_DIVIDE; }
"="         { return T_ASSIGN; }
"=="        { return T_EQ; }
"!="        { return T_NEQ; }
"<"         { return T_LT; }
"<="        { return T_LTE; }
">"         { return T_GT; }
">="        { return T_GTE; }
"&&"        { return T_AND; }
"||"        { return T_OR; }
"!"         { return T_NOT; }

"("         { return T_LPAREN; }
")"         { return T_RPAREN; }
"{"         { return T_LBRACE; }
"}"         { return T_RBRACE; }
"["         { return T_LBRACKET; }
"]"         { return T_RBRACKET; }
","         { return T_COMMA; }
"."         { return T_DOT; }

"@@".*      { /* Single line comment - ignore */ }
"@"[^@]*"@" { /* Multi-line comment - ignore */ }

{ID}        { yylval.string = strdup(yytext); return T_IDENTIFIER; }
{INTEGER}   { yylval.integer = atoi(yytext); return T_INT_LITERAL; }
{FLOAT}     { yylval.floating = atof(yytext); return T_FLOAT_LITERAL; }
{STRING}    { yylval.string = strdup(yytext); return T_STRING_LITERAL; }
{CHAR}      { yylval.character = yytext[1]; return T_CHAR_LITERAL; }

\n          { line_num++; }
{WHITESPACE} { /* Ignore whitespace */ }

.           { printf("Lexical error on line %d: Unexpected character %s\n", line_num, yytext); }

%%

int yywrap() {
    return 1;
} 