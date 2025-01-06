%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_num;
extern char* yytext;
extern FILE* yyin;
void yyerror(const char* s);
int yylex(void);

/* Symbol table structure */
struct SymbolEntry {
    char* name;
    char* type;
    int scope;
    int is_constant;
    struct SymbolEntry* next;
};

struct SymbolEntry* symbol_table = NULL;
int current_scope = 0;

/* Logging functions */
void log_syntax(const char* rule) {
    printf("SYNTAX: Line %d - Reducing rule: %s\n", line_num, rule);
}

void log_semantic(const char* action) {
    printf("SEMANTIC: Line %d - %s\n", line_num, action);
}

void log_symbol(const char* name, const char* type, int scope) {
    printf("SYMBOL: Added '%s' of type '%s' to scope %d\n", name, type, scope);
}
%}

%union {
    int integer;
    float floating;
    char character;
    char* string;
}

/* Token definitions */
%token T_INT T_FLOAT T_CHAR T_STRING T_VOID
%token T_CONST_INT T_CONST_FLOAT T_CONST_CHAR T_CONST_STRING
%token T_FARUKI T_EMIT T_DEFAULT
%token T_IF T_ELSE_IF T_ELSE T_SWITCH T_FOR T_WHILE
%token T_FROM T_TO T_WITH T_THEN
%token <string> T_IDENTIFIER
%token <integer> T_INT_LITERAL
%token <floating> T_FLOAT_LITERAL
%token <character> T_CHAR_LITERAL
%token <string> T_STRING_LITERAL

%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE
%token T_ASSIGN T_EQ T_NEQ T_LT T_LTE T_GT T_GTE
%token T_AND T_OR T_NOT
%token T_LPAREN T_RPAREN T_LBRACE T_RBRACE T_LBRACKET T_RBRACKET
%token T_COMMA T_DOT

/* Operator precedence */
%left T_OR
%left T_AND
%left T_EQ T_NEQ
%left T_LT T_LTE T_GT T_GTE
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%right T_NOT

%%

program
    : statements    { log_syntax("program -> statements"); }
    ;

statements
    : statement    { log_syntax("statements -> statement"); }
    | statements statement    { log_syntax("statements -> statements statement"); }
    ;

statement
    : declaration T_DOT    { log_syntax("statement -> declaration DOT"); }
    | assignment T_DOT    { log_syntax("statement -> assignment DOT"); }
    | if_statement    { log_syntax("statement -> if_statement"); }
    | switch_statement    { log_syntax("statement -> switch_statement"); }
    | loop_statement    { log_syntax("statement -> loop_statement"); }
    | function_declaration    { log_syntax("statement -> function_declaration"); }
    | emit_statement T_DOT    { log_syntax("statement -> emit_statement DOT"); }
    ;

declaration
    : type T_IDENTIFIER    { 
        log_syntax("declaration -> type IDENTIFIER"); 
        log_semantic("Declaring variable without initialization");
        log_symbol($2, "type", current_scope);
    }
    | type T_IDENTIFIER T_ASSIGN expression    { 
        log_syntax("declaration -> type IDENTIFIER ASSIGN expression");
        log_semantic("Declaring and initializing variable");
        log_symbol($2, "type", current_scope);
    }
    | const_type T_IDENTIFIER T_ASSIGN expression    {
        log_syntax("declaration -> const_type IDENTIFIER ASSIGN expression");
        log_semantic("Declaring constant variable");
        log_symbol($2, "const", current_scope);
    }
    | array_declaration    { log_syntax("declaration -> array_declaration"); }
    ;

type
    : T_INT
    | T_FLOAT
    | T_CHAR
    | T_STRING
    ;

const_type
    : T_CONST_INT
    | T_CONST_FLOAT
    | T_CONST_CHAR
    | T_CONST_STRING
    ;

array_declaration
    : type T_IDENTIFIER T_LPAREN T_INT_LITERAL T_COMMA expression T_RPAREN
    | type T_IDENTIFIER T_LPAREN T_INT_LITERAL T_RPAREN T_ASSIGN array_init
    ;

array_init
    : T_LPAREN expression_list T_RPAREN
    ;

expression_list
    : expression
    | expression_list T_COMMA expression
    ;

assignment
    : T_IDENTIFIER T_ASSIGN expression
    ;

expression
    : T_IDENTIFIER
    | T_INT_LITERAL
    | T_FLOAT_LITERAL
    | T_CHAR_LITERAL
    | T_STRING_LITERAL
    | expression T_PLUS expression
    | expression T_MINUS expression
    | expression T_MULTIPLY expression
    | expression T_DIVIDE expression
    | expression T_AND expression
    | expression T_OR expression
    | expression T_EQ expression
    | expression T_NEQ expression
    | expression T_LT expression
    | expression T_LTE expression
    | expression T_GT expression
    | expression T_GTE expression
    | T_NOT expression
    | T_LPAREN expression T_RPAREN
    ;

if_statement
    : if_without_else
    | if_with_else
    ;

if_without_else
    : T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE
    | T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE else_if_list
    ;

if_with_else
    : T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE else_statement
    | T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE else_if_list else_statement
    ;

else_if_list
    : else_if
    | else_if_list else_if
    ;

else_if
    : T_ELSE_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE
    ;

else_statement
    : T_ELSE T_LBRACE statements T_RBRACE
    ;

switch_statement
    : T_SWITCH T_LBRACKET expression T_RBRACKET T_LBRACE case_list T_RBRACE
    ;

case_list
    : case_item
    | case_list case_item
    ;

case_item
    : T_LBRACKET expression T_RBRACKET T_LBRACE statements T_RBRACE
    | T_LBRACKET T_DEFAULT T_RBRACKET T_LBRACE statements T_RBRACE
    ;

loop_statement
    : for_loop
    | while_loop
    ;

for_loop
    : T_FOR type T_IDENTIFIER T_FROM expression T_TO expression T_WITH expression T_LBRACE statements T_RBRACE
    ;

while_loop
    : T_WHILE T_LBRACKET expression T_RBRACKET T_LBRACE statements T_RBRACE
    ;

function_declaration
    : T_FARUKI T_VOID T_IDENTIFIER T_LPAREN parameter_list T_RPAREN T_LBRACE    
        { 
            log_syntax("function_declaration -> void function");
            log_semantic("Entering new function scope");
            current_scope++;
            log_symbol($3, "void function", current_scope);
        }
      statements T_RBRACE
        {
            log_semantic("Exiting function scope");
            current_scope--;
        }
    | T_FARUKI type T_IDENTIFIER T_LPAREN parameter_list T_RPAREN T_LBRACE
        {
            log_syntax("function_declaration -> typed function");
            log_semantic("Entering new function scope");
            current_scope++;
            log_symbol($3, "function", current_scope);
        }
      statements T_RBRACE
        {
            log_semantic("Exiting function scope");
            current_scope--;
        }
    ;

parameter_list
    : /* empty */
    | parameter
    | parameter_list T_COMMA parameter
    ;

parameter
    : type T_IDENTIFIER
    ;

emit_statement
    : T_EMIT expression
    ;

%%

void yyerror(const char* s) {
    fprintf(stderr, "Error on line %d: %s\n", line_num, s);
}

int main(int argc, char** argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s input_file\n", argv[0]);
        return 1;
    }

    FILE* input = fopen(argv[1], "r");
    if (!input) {
        fprintf(stderr, "Cannot open input file %s\n", argv[1]);
        return 1;
    }

    printf("=== Starting Faruki Language Parser ===\n\n");
    yyin = input;
    yyparse();
    printf("\n=== Parsing Complete ===\n");
    printf("Total lines processed: %d\n", line_num);
    fclose(input);
    return 0;
}