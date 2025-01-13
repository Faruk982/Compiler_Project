%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line_num;
extern char* yytext;
extern FILE* yyin;
FILE* output_file = NULL;
void yyerror(const char* s);
int yylex(void);

/* Symbol table structure */
struct SymbolEntry {
    char* name;
    char* type;
    int is_constant;
    struct SymbolEntry* next;
};

struct SymbolEntry symbol_table [1000];
int current_num = 0,current_scope = 0;
int had_error = 0;  // Global error flag
int get(char* name) {
    printf("Getting %s\n", name);
    for(int i = 0; i < current_num; i++) {
        if(strcmp(symbol_table[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

int is_constant(char* name) {
    int idx = get(name);
    if (idx != -1) {
        return symbol_table[idx].is_constant;
    }
    return 0;
}

void add(char* name, char* type, int scope, int is_constant) {
    if (current_num >= 1000) {
        fprintf(stderr, "Error: Symbol table is full\n");
        had_error = 1;  // Set error flag instead of YYERROR
        return;
    }
    symbol_table[current_num].name = strdup(name);
    symbol_table[current_num].type = strdup(type);
    symbol_table[current_num].is_constant = is_constant;
    current_num++;
    printf("Added symbol %s at index %d\n", name, current_num - 1);  // Debug print
}
/* Logging functions */
void log_semantic(const char* action) {
    printf("SEMANTIC: Line %d - %s\n", line_num, action);
    fprintf(output_file, "SEMANTIC: Line %d - %s\n", line_num, action);
}

void log_symbol(const char* name, const char* type, int scope) {
    printf("SYMBOL: Added '%s' of type '%s' to scope %d\n", name, type, scope);
    fprintf(output_file, "SYMBOL: Added '%s' of type '%s' to scope %d\n", name, type, scope);

}

void log_operation(const char* op_type, const char* op, const char* left_val, const char* right_val) {
    printf("OPERATION: Line %d - %s operation '%s' between '%s' and '%s'\n", 
           line_num, op_type, op, left_val, right_val);
           fprintf(output_file, "OPERATION: Line %d - %s operation '%s' between '%s' and '%s'\n", 
        line_num, op_type, op, left_val, right_val);

}

void log_assignment(const char* var_name, const char* value) {
    printf("ASSIGNMENT: Line %d - Variable '%s' assigned value '%s'\n", 
           line_num, var_name, value);
           fprintf(output_file, "ASSIGNMENT: Line %d - Variable '%s' assigned value '%s'\n", 
        line_num, var_name, value);

}

void log_declaration(const char* var_name, const char* type, const char* value) {
    printf("DECLARATION: Line %d - Variable '%s' of type '%s' initialized with '%s'\n", 
           line_num, var_name, type, value);
           fprintf(output_file, "DECLARATION: Line %d - Variable '%s' of type '%s' initialized with '%s'\n", 
        line_num, var_name, type, value);

}

void log_condition(const char* condition_type, const char* condition) {
    printf("CONDITION: Line %d - %s condition: '%s'\n", 
           line_num, condition_type, condition);
           fprintf(output_file, "CONDITION: Line %d - %s condition: '%s'\n", 
        line_num, condition_type, condition);

}
%}

%union {
    int integer;
    float floating;
    char character;
    char* string;
    struct {
        char* name;
        char* value;
    } expr;
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

%type <expr> expression
%type <expr> expression_list

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
    : statements    
    ;

statements
    : statement    
    | statements statement    
    ;

statement
    : declaration T_DOT    
    | assignment T_DOT    
    | if_statement    
    | switch_statement    
    | loop_statement    
    | function_declaration    
    | emit_statement T_DOT    
    ;

declaration
    : type T_IDENTIFIER    { 
        if (get($2) != -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Redeclaration of variable '%s'", $2);
            yyerror(error_msg);
            YYERROR;
        }
        add($2, "variable", current_scope, 0);
        log_declaration($2, "variable", "undefined");
    }
    | type T_IDENTIFIER T_ASSIGN expression    { 
        if (get($2) != -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Redeclaration of variable '%s'", $2);
            yyerror(error_msg);
            YYERROR;
        }
        add($2, "variable", current_scope, 0);
        log_declaration($2, "variable", $4.value);
    }
    | const_type T_IDENTIFIER T_ASSIGN expression    {
        if (get($2) != -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Redeclaration of constant '%s'", $2);
            yyerror(error_msg);
            YYERROR;
        }
        add($2, "constant", current_scope, 1);
        log_declaration($2, "constant", $4.value);
        log_symbol($2, "const", current_scope);
    }
    | array_declaration    
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
    : type T_IDENTIFIER T_LPAREN T_INT_LITERAL T_COMMA expression T_RPAREN    {
        if (get($2) != -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Redeclaration of array '%s'", $2);
            yyerror(error_msg);
            YYERROR;
        }
        add($2, "array", current_scope, 0);
        log_declaration($2, "array", "undefined");
    }
    | type T_IDENTIFIER T_LPAREN T_INT_LITERAL T_RPAREN T_ASSIGN array_init    {
        if (get($2) != -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Redeclaration of array '%s'", $2);
            yyerror(error_msg);
            YYERROR;
        }
        add($2, "array", current_scope, 0);
        log_declaration($2, "array", "initialized");
    }
    ;

array_init
    : T_LPAREN expression_list T_RPAREN
    ;

expression_list
    : expression
    | expression_list T_COMMA expression
    ;

assignment
    : T_IDENTIFIER T_ASSIGN expression    {
        int idx = get($1);
        if (idx == -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Assignment to undeclared variable '%s'", $1);
            yyerror(error_msg);
            YYERROR;
        }
        if (symbol_table[idx].is_constant) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Cannot assign to constant '%s'", $1);
            yyerror(error_msg);
            YYERROR;
        }
        log_assignment($1, $3.value);
    }
    ;

expression
    : T_IDENTIFIER    { 
        int idx = get($1);
        if (idx == -1) {
            char error_msg[256];
            snprintf(error_msg, sizeof(error_msg), 
                    "Use of undeclared variable '%s'", $1);
            yyerror(error_msg);
            YYERROR;
        }
        $$.name = strdup($1);
        $$.value = strdup($1);
    }
    | T_INT_LITERAL    { 
        char buf[32];
        snprintf(buf, sizeof(buf), "%d", $1);
        $$.name = strdup("integer_literal");
        $$.value = strdup(buf);
    }
    | T_FLOAT_LITERAL    { 
        char buf[32];
        snprintf(buf, sizeof(buf), "%f", $1);
        $$.name = strdup("float_literal");
        $$.value = strdup(buf);
    }
    | T_STRING_LITERAL    { 
        $$.name = strdup("string_literal");
        $$.value = strdup($1);
    }
    | T_CHAR_LITERAL    { 
        char buf[32];
        snprintf(buf, sizeof(buf), "'%c'", $1);
        $$.name = strdup("char_literal");
        $$.value = strdup(buf);
    }
    | expression T_PLUS expression    {
        log_operation("Arithmetic", "+", $1.value, $3.value);
        $$.name = strdup("addition_result");
        // Combine the values for the result
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s + %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_MINUS expression    {
        log_operation("Arithmetic", "-", $1.value, $3.value);
        $$.name = strdup("subtraction_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s - %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_MULTIPLY expression    {
        log_operation("Arithmetic", "*", $1.value, $3.value);
        $$.name = strdup("multiplication_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s * %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_DIVIDE expression    {
        log_operation("Arithmetic", "/", $1.value, $3.value);
        $$.name = strdup("division_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s / %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_AND expression    {
        log_operation("Logical", "AND", $1.value, $3.value);
        $$.name = strdup("and_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s && %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_OR expression    {
        log_operation("Logical", "OR", $1.value, $3.value);
        $$.name = strdup("or_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s || %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_EQ expression    {
        log_operation("Comparison", "==", $1.value, $3.value);
        $$.name = strdup("equality_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s == %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_GT expression    {
        log_operation("Comparison", ">", $1.value, $3.value);
        $$.name = strdup("greater_than_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s > %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_GTE expression     {
        log_operation("Comparison", ">=", $1.value, $3.value);
        $$.name = strdup("greater_than_or_equal_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s >= %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_LT expression      {
        log_operation("Comparison", "<", $1.value, $3.value);
        $$.name = strdup("less_than_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s < %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_LTE expression     {
        log_operation("Comparison", "<=", $1.value, $3.value);
        $$.name = strdup("less_than_or_equal_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s <= %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | expression T_NEQ expression     {
        log_operation("Comparison", "!=", $1.value, $3.value);
        $$.name = strdup("inequality_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(%s != %s)", $1.value, $3.value);
        $$.value = strdup(buf);
    }
    | T_NOT expression    {
        log_operation("Logical", "NOT", $2.value, "");
        $$.name = strdup("not_result");
        char buf[256];
        snprintf(buf, sizeof(buf), "(!%s)", $2.value);
        $$.value = strdup(buf);
    }
    | T_LPAREN expression T_RPAREN    {
        $$.name = strdup($2.name);
        $$.value = strdup($2.value);
    }
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
    : T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE T_ELSE T_LBRACE statements T_RBRACE
    | T_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE else_if_list T_ELSE T_LBRACE statements T_RBRACE
    ;

else_if_list
    : T_ELSE_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE
    | else_if_list T_ELSE_IF T_LBRACKET expression T_RBRACKET T_THEN T_LBRACE statements T_RBRACE
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
    : T_LBRACKET expression T_RBRACKET T_LBRACE statements T_RBRACE    {
        printf("CASE: Line %d - Case with condition '%s'\n", line_num, $2.value);
    }
    | T_LBRACKET T_DEFAULT T_RBRACKET T_LBRACE statements T_RBRACE    {
        printf("CASE: Line %d - Default case\n", line_num);
    }
    ;

loop_statement
    : for_loop
    | while_loop
    ;

for_loop
    : T_FOR type T_IDENTIFIER T_FROM expression T_TO expression T_WITH expression T_LBRACE statements T_RBRACE
    ;

while_loop
    : T_WHILE T_LBRACKET expression T_RBRACKET    {
        printf("CONDITION: Line %d - While loop condition '%s'\n", 
               line_num, $3.value);
               fprintf(output_file, "CONDITION: Line %d - While loop condition '%s'\n", 
        line_num, $3.value);

    } T_LBRACE statements T_RBRACE
    ;

function_declaration
    : T_FARUKI T_VOID T_IDENTIFIER T_LPAREN parameter_list T_RPAREN T_LBRACE    
        { 
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
    : T_EMIT expression    {
        printf("EMIT: Line %d - Outputting value '%s'\n", 
               line_num, $2.value);
               fprintf(output_file, "EMIT: Line %d - Outputting value '%s'\n", 
        line_num, $2.value);

    }
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
     output_file = fopen("output.txt", "w");
    if (!output_file) {
        fprintf(stderr, "Cannot open output file output.txt\n");
        fclose(input);
        return 1;
    }
    printf("=== Starting Faruki Language Parser ===\n\n");
     fprintf(output_file, "=== Starting Faruki Language Parser ===\n\n");
    yyin = input;
    int parse_result = yyparse();
    
    printf("\n=== Parsing Complete ===\n");
    fprintf(output_file, "\n=== Parsing Complete ===\n");
    
    if (had_error || parse_result != 0) {
        printf("Parsing failed due to errors\n");
        fprintf(output_file, "Parsing failed due to errors\n");
    }
    
    printf("Total lines processed: %d\n", line_num);
    fprintf(output_file, "Total lines processed: %d\n", line_num);
    
    fclose(input);
    fclose(output_file);
    return (had_error || parse_result != 0) ? 1 : 0;
}
