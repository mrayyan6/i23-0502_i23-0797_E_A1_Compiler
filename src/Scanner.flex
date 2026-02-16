/* ============================================================================
 * JFlex Scanner Specification for Custom Programming Language
 * CS4031 - Compiler Construction Assignment 01
 * Part 2: JFlex Implementation
 * ============================================================================
 */

/* ============================================================================
 * USER CODE SECTION
 * Imports and helper methods
 * ============================================================================
 */
import java.io.*;
import java.util.ArrayList;
import java.util.List;

%%

/* ============================================================================
 * OPTIONS AND DECLARATIONS
 * ============================================================================
 */
%class Yylex
%public
%unicode
%line
%column
%type Token

/* Enable character counting for accurate column tracking */
%{
    // List to store all tokens
    private List<Token> tokens = new ArrayList<>();
    
    // Statistics counters
    private int tokenCount = 0;
    private int commentCount = 0;
    
    // Helper method to get current line number (1-indexed)
    private int getLine() {
        return yyline + 1;
    }
    
    // Helper method to get current column number (1-indexed)
    private int getColumn() {
        return yycolumn + 1;
    }
    
    // Create and store token
    private Token createToken(TokenType type, String lexeme) {
        Token token = new Token(type, lexeme, getLine(), getColumn());
        tokens.add(token);
        tokenCount++;
        return token;
    }
    
    // Get all tokens
    public List<Token> getTokens() {
        return tokens;
    }
    
    // Get token count
    public int getTokenCount() {
        return tokenCount;
    }
    
    // Get comment count
    public int getCommentCount() {
        return commentCount;
    }
%}

/* ============================================================================
 * MACRO DEFINITIONS
 * Pattern definitions for better readability and reusability
 * ============================================================================
 */

/* Basic Components */
DIGIT           = [0-9]
UPPERCASE       = [A-Z]
LOWERCASE       = [a-z]
LETTER          = [A-Za-z]
UNDERSCORE      = "_"

/* Whitespace */
WHITESPACE      = [ \t\r\n]+
NEWLINE         = \r|\n|\r\n

/* Integer Literal: [+-]?[0-9]+ */
INTEGER         = [+\-]?{DIGIT}+

/* Floating-Point Literal: [+-]?[0-9]+\.[0-9]{1,6}([eE][+-]?[0-9]+)? */
FLOAT           = [+\-]?{DIGIT}+"."{DIGIT}{1,6}([eE][+\-]?{DIGIT}+)?

/* Identifier: [A-Z][a-z0-9_]{0,30} */
IDENTIFIER      = {UPPERCASE}({LOWERCASE}|{DIGIT}|{UNDERSCORE}){0,30}

/* String Literal: "([ ^"\\\n]|\\["\\ntr])*" */
STRING_CHAR     = [^\"\\\n]
ESCAPE_SEQ      = \\[\"\\\ntr]
STRING          = \"({STRING_CHAR}|{ESCAPE_SEQ})*\"

/* Character Literal: '([ ^'\\\n]|\\['\\ntr])' */
CHAR_LITERAL    = '([^'\\\n]|\\['\\\ntr])'

/* Comments */
SINGLE_COMMENT  = "##"[^\n]*
MULTI_COMMENT   = "#*"([^*]|\*+[^*#])*\*+"#"

/* ============================================================================
 * LEXICAL RULES
 * Pattern matching rules in priority order (CRITICAL for avoiding ambiguity)
 * ============================================================================
 */
%%

/* ----------------------------------------------------------------------------
 * 1. MULTI-LINE COMMENTS (Highest Priority)
 * ---------------------------------------------------------------------------- */
{MULTI_COMMENT}     { 
                        commentCount++; 
                        /* Skip - don't return token */ 
                    }

/* ----------------------------------------------------------------------------
 * 2. SINGLE-LINE COMMENTS
 * ---------------------------------------------------------------------------- */
{SINGLE_COMMENT}    { 
                        commentCount++; 
                        /* Skip - don't return token */ 
                    }

/* ----------------------------------------------------------------------------
 * 3. MULTI-CHARACTER OPERATORS (Before single-character ones)
 * ---------------------------------------------------------------------------- */
"**"                { return createToken(TokenType.POWER, yytext()); }
"=="                { return createToken(TokenType.EQUAL, yytext()); }
"!="                { return createToken(TokenType.NOT_EQUAL, yytext()); }
"<="                { return createToken(TokenType.LESS_EQUAL, yytext()); }
">="                { return createToken(TokenType.GREATER_EQUAL, yytext()); }
"&&"                { return createToken(TokenType.LOGICAL_AND, yytext()); }
"||"                { return createToken(TokenType.LOGICAL_OR, yytext()); }
"++"                { return createToken(TokenType.INCREMENT, yytext()); }
"--"                { return createToken(TokenType.DECREMENT, yytext()); }
"+="                { return createToken(TokenType.PLUS_ASSIGN, yytext()); }
"-="                { return createToken(TokenType.MINUS_ASSIGN, yytext()); }
"*="                { return createToken(TokenType.MULT_ASSIGN, yytext()); }
"/="                { return createToken(TokenType.DIV_ASSIGN, yytext()); }

/* ----------------------------------------------------------------------------
 * 4. KEYWORDS (Case-Sensitive, Exact Match)
 * Must be checked before identifiers to avoid keyword-identifier conflict
 * ---------------------------------------------------------------------------- */
"start"             { return createToken(TokenType.START, yytext()); }
"finish"            { return createToken(TokenType.FINISH, yytext()); }
"loop"              { return createToken(TokenType.LOOP, yytext()); }
"condition"         { return createToken(TokenType.CONDITION, yytext()); }
"declare"           { return createToken(TokenType.DECLARE, yytext()); }
"output"            { return createToken(TokenType.OUTPUT, yytext()); }
"input"             { return createToken(TokenType.INPUT, yytext()); }
"function"          { return createToken(TokenType.FUNCTION, yytext()); }
"return"            { return createToken(TokenType.RETURN, yytext()); }
"break"             { return createToken(TokenType.BREAK, yytext()); }
"continue"          { return createToken(TokenType.CONTINUE, yytext()); }
"else"              { return createToken(TokenType.ELSE, yytext()); }

/* ----------------------------------------------------------------------------
 * 5. BOOLEAN LITERALS (Before identifiers)
 * ---------------------------------------------------------------------------- */
"true"              { return createToken(TokenType.BOOLEAN, yytext()); }
"false"             { return createToken(TokenType.BOOLEAN, yytext()); }

/* ----------------------------------------------------------------------------
 * 6. IDENTIFIERS
 * Must be after keywords and booleans
 * ---------------------------------------------------------------------------- */
{IDENTIFIER}        { return createToken(TokenType.IDENTIFIER, yytext()); }

/* ----------------------------------------------------------------------------
 * 7. FLOATING-POINT LITERALS (Before integers - longest match)
 * ---------------------------------------------------------------------------- */
{FLOAT}             { return createToken(TokenType.FLOAT, yytext()); }

/* ----------------------------------------------------------------------------
 * 8. INTEGER LITERALS
 * ---------------------------------------------------------------------------- */
{INTEGER}           { return createToken(TokenType.INTEGER, yytext()); }

/* ----------------------------------------------------------------------------
 * 9. STRING AND CHARACTER LITERALS
 * ---------------------------------------------------------------------------- */
{STRING}            { return createToken(TokenType.STRING, yytext()); }
{CHAR_LITERAL}      { return createToken(TokenType.CHAR, yytext()); }

/* ----------------------------------------------------------------------------
 * 10. SINGLE-CHARACTER OPERATORS
 * ---------------------------------------------------------------------------- */
"+"                 { return createToken(TokenType.PLUS, yytext()); }
"-"                 { return createToken(TokenType.MINUS, yytext()); }
"*"                 { return createToken(TokenType.MULTIPLY, yytext()); }
"/"                 { return createToken(TokenType.DIVIDE, yytext()); }
"%"                 { return createToken(TokenType.MODULO, yytext()); }
"<"                 { return createToken(TokenType.LESS_THAN, yytext()); }
">"                 { return createToken(TokenType.GREATER_THAN, yytext()); }
"!"                 { return createToken(TokenType.LOGICAL_NOT, yytext()); }
"="                 { return createToken(TokenType.ASSIGN, yytext()); }

/* ----------------------------------------------------------------------------
 * 11. PUNCTUATORS
 * ---------------------------------------------------------------------------- */
"("                 { return createToken(TokenType.LPAREN, yytext()); }
")"                 { return createToken(TokenType.RPAREN, yytext()); }
"{"                 { return createToken(TokenType.LBRACE, yytext()); }
"}"                 { return createToken(TokenType.RBRACE, yytext()); }
"["                 { return createToken(TokenType.LBRACKET, yytext()); }
"]"                 { return createToken(TokenType.RBRACKET, yytext()); }
","                 { return createToken(TokenType.COMMA, yytext()); }
";"                 { return createToken(TokenType.SEMICOLON, yytext()); }
":"                 { return createToken(TokenType.COLON, yytext()); }

/* ----------------------------------------------------------------------------
 * 12. WHITESPACE (Skip but track for line/column numbers)
 * ---------------------------------------------------------------------------- */
{WHITESPACE}        { /* Skip whitespace - JFlex automatically tracks line/col */ }

/* ----------------------------------------------------------------------------
 * ERROR HANDLING
 * Catch any unrecognized characters
 * ---------------------------------------------------------------------------- */
.                   { return createToken(TokenType.ERROR, yytext()); }

/* End of File */
<<EOF>>             { return createToken(TokenType.EOF, "EOF"); }
