/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_GRAMMAR_TAB_H_INCLUDED
# define YY_YY_GRAMMAR_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 47 "grammar.y" /* yacc.c:1909  */

	#include <stdbool.h>

#line 48 "grammar.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    ADD = 258,
    OR = 259,
    NOT = 260,
    EQUAL = 261,
    LT = 262,
    GT = 263,
    LE = 264,
    GE = 265,
    ASSIGN = 266,
    AND = 267,
    ARROW = 268,
    DIV = 269,
    MUL = 270,
    SUB = 271,
    LPAR = 272,
    RPAR = 273,
    CLPAR = 274,
    CRPAR = 275,
    SLPAR = 276,
    SRPAR = 277,
    SLASH = 278,
    COLON = 279,
    SEMICOLON = 280,
    COMMA = 281,
    IF = 282,
    THEN = 283,
    WHILE = 284,
    DO = 285,
    READ = 286,
    ELSE = 287,
    BEGI = 288,
    END = 289,
    CASE = 290,
    OF = 291,
    PRINT = 292,
    FLOOR = 293,
    CEIL = 294,
    INT = 295,
    BOOL = 296,
    CHAR = 297,
    REAL = 298,
    VAR = 299,
    DATA = 300,
    SIZE = 301,
    FLOAT = 302,
    FUN = 303,
    RETURN = 304,
    CID = 305,
    ID = 306,
    RVAL = 307,
    IVAL = 308,
    BVAL = 309,
    CVAL = 310
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 51 "grammar.y" /* yacc.c:1909  */

	struct ast *n;
	int ival;
	char *sval;
	float rval;
	bool bval;

#line 124 "grammar.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_GRAMMAR_TAB_H_INCLUDED  */
