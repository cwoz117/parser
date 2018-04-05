%option noyywrap
%option never-interactive
%option nounput
%option yylineno

%{
	#include "grammar.tab.h"
	int linecount = 1;
	int charcount = 1;
	int multicomment(void);
	int inputpos(char value);	
%}

digit			[0-9]
alpha			[a-zA-Z]
quote			["]
char			[^_A-Za-z0-9]
identifier		({alpha}({alpha}|{digit})*)

%%
([%](.)*)	{}
("/*")		{ int i = multicomment(); 
			  if (i) printf("Hit EOF in a comment\n");	}
"\n"		{ charcount = 1; linecount++; }
[ \t|" "]	{ charcount++;		}

"+"		{ return ADD; 		}
"-"		{ return SUB; 		}
"*"		{ return MUL; 		}
"/"		{ return DIV; 		}
"=>"		{ return ARROW; 	}
"&&"		{ return AND; 		}
"||"		{ return OR; 		}
"not"		{ return NOT; 		}

"="		{ return EQUAL; 	}
"<"		{ return LT; 		}
">"		{ return GT; 		}
"=<"		{ return LE; 		}
">="		{ return GE; 		}

":="		{ return ASSIGN; 	}
"("		{ return LPAR; 		}
")"		{ return RPAR; 		}
"{"		{ return CLPAR; 	}
"}"		{ return CRPAR; 	}
"["		{ return SLPAR; 	}
"]"		{ return SRPAR; 	}
'|'		{ return SLASH; 	}

":"		{ return COLON; 	}
";"		{ return SEMICOLON;	}
","		{ return COMMA; 	}

"if"		{ return IF; 		}
"then"		{ return THEN; 		}
"while"		{ return WHILE; 	}
"do"		{ return DO; 		}
"read"		{ return READ; 		}
"else"		{ return ELSE; 		}
"begin"		{ return BEGI; 		}
"end"		{ return END; 		}
"case"		{ return CASE; 		}
"of"		{ return OF; 		}
"print"		{ return PRINT; 	}
"int"		{ return INT; 		}
"bool"		{ return BOOL; 		}
"char"		{ return CHAR; 		}
"real"		{ return REAL; 		}
"var"		{ return VAR; 		}
"data"		{ return DATA; 		}
"size"		{ return SIZE; 		}
"float"		{ return FLOAT; 	}
"floor"		{ return FLOOR; 	}
"ceil"		{ return CEIL; 		}
"fun"		{ return FUN; 		}
"return"	{ return RETURN; 	}

"false"			{ return BVAL;  }
"true"			{ return BVAL;  }
"#"[{digit}{alpha}]*	{ return CID;   }
{identifier}		{ return ID;    }
{digit}+"."{digit}+	{ return RVAL;  }
{digit}+		{ return IVAL;  }
{quote}{char}{quote}	{ return CVAL;  }
{quote}'\n'{quote}	{ return CVAL;  }
{quote}'\t'{quote}	{ return CVAL;  }

%%

int inputpos(char value){
	switch (value){
		case '*': return 0;
		case '/': return 1;
		case '\n':
			linecount++; 
			return 2;
		case '%': return 3;
		case EOF: return -1;
		default: return 4;
	}
}

int multicomment(void){
	int transition[6][5] = {
		{1,3,0,2,0},
		{1,5,0,2,0},
		{2,2,0,2,2},
		{4,3,0,2,0},
		{0,0,0,0,0},
		{0,0,0,0,0},
	};
	int error = 0;
	int accept = 5;
	int state = 0;

	int ch = inputpos(input());
	while ((state != accept) && !error){
		if (ch == -1){
			error = 1;
		}else{
			if (state == 4){
				error = multicomment();
				state = 0;
			}
			int newstate = transition[state][ch];
			if (newstate == state){
				ch = inputpos(input());
			} else if (state == 4){
				error = multicomment();
				state = 0;
				ch = inputpos(input());
			} else {
				state = newstate;
				
			}
			if (ch == EOF)
				error = 1;
		}
	}
	return error;
}

/*
							   '*'  '%' '\n'  '/'  other
	base_comment			0|  1    2    0    0     0
	maybe end of comment	1|  1    0    0    3     0
	one line comment		2|  2    2    0    2     2
	accept					3|  0    0    0    0     0     

	state = 1
	ch = next input character
	while not accept-state and not error do
		newstate = T[state, ch]
		if state advances
			ch = next input char
		state = newstate
	end while
	if accept and not error
		accept
*/
