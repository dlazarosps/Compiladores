%{
int yylex(void);
void yyerror (char const *s);
%}

%token TK_PR_INT
%token TK_PR_FLOAT
%token TK_PR_BOOL
%token TK_PR_CHAR
%token TK_PR_STRING
%token TK_PR_IF
%token TK_PR_THEN
%token TK_PR_ELSE
%token TK_PR_WHILE
%token TK_PR_DO
%token TK_PR_INPUT
%token TK_PR_OUTPUT
%token TK_PR_RETURN
%token TK_PR_CONST
%token TK_PR_STATIC
%token TK_PR_FOREACH
%token TK_PR_FOR
%token TK_PR_SWITCH
%token TK_PR_CASE
%token TK_PR_BREAK
%token TK_PR_CONTINUE
%token TK_PR_CLASS
%token TK_PR_PRIVATE
%token TK_PR_PUBLIC
%token TK_PR_PROTECTED
%token TK_OC_LE
%token TK_OC_GE
%token TK_OC_EQ
%token TK_OC_NE
%token TK_OC_AND
%token TK_OC_OR
%token TK_OC_SL
%token TK_OC_SR
%token TK_OC_FORWARD_PIPE
%token TK_OC_BASH_PIPE
%token TK_LIT_INT
%token TK_LIT_FLOAT
%token TK_LIT_FALSE
%token TK_LIT_TRUE
%token TK_LIT_CHAR
%token TK_LIT_STRING
%token TK_IDENTIFICADOR
%token TOKEN_ERRO

// precedencia de operadores

//TODO associativide a direita '&' e '*' ponteiro
%left '*' '/'
%left '+' '-'
%right '['']'
%right '('')'
%left '<' TK_OC_LE
%left '>' TK_OC_GE
%left '!' TK_OC_EQ TK_OC_NE
%left TK_OC_AND
%left TK_OC_OR
%left TK_OC_SL TK_OC_SR



%%

programa: elemento;

elemento: decGlobal | decTipo | decFunc | elemento | ;

optStatic: TK_PR_STATIC | ;
optConst: TK_PR_CONST | ;

decGlobal: optStatic varGlobal ';';
varGlobal: TK_IDENTIFICADOR  tipo | varVetor tipo;
varVetor: TK_IDENTIFICADOR '[' TK_LIT_INT ']';

tipo:  TK_PR_INT | TK_PR_FLOAT | TK_PR_BOOL | TK_PR_CHAR | TK_PR_STRING | TK_IDENTIFICADOR; 

decTipo: TK_PR_CLASS TK_IDENTIFICADOR '[' listaTipo ']' ';';

listaTipo: campoTipo | campoTipo ':' listaTipo;
campoTipo: encaps tipo TK_IDENTIFICADOR;
encaps:  TK_PR_PROTECTED | TK_PR_PRIVATE | TK_PR_PUBLIC | ;

decFunc: cabecalhoFun corpoFun ';';
cabecalhoFun: optStatic tipo TK_IDENTIFICADOR listaFun;
listaFun: '(' parmsFun ')';
parmsFun: parms | parms ',' parmsFun;
parms: optConst tipo TK_IDENTIFICADOR;

corpoFun: cmdBlock;
cmdBlock: '{' cmdSimples '}' ';';
cmdSimples: decVar | cmdAtr | cmdIO | callFun | shift | rbcc | fluxo | pipes | ;
decVar: defaultVar ';' | initVar;
defaultVar: optStatic optConst tipo TK_IDENTIFICADOR;
initVar: defaultVar '<=' valueVar ';';
valueVar: TK_IDENTIFICADOR | literal;

literal: literalNum | literalChar | litBool;
literalNum: TK_LIT_INT | TK_LIT_FLOAT;
literalChar: TK_LIT_CHAR | TK_LIT_STRING;
litBool: TK_LIT_FALSE | TK_LIT_TRUE;

cmdAtr: atrVar | atrVet | atrClass | atrVetClass;
atrVar: TK_IDENTIFICADOR '=' expr;
atrVet: TK_IDENTIFICADOR '[' expr ']' '=' expr;
atrClass: TK_IDENTIFICADOR '$' TK_IDENTIFICADOR '=' expr;
atrVetClass: TK_IDENTIFICADOR '[' expr ']' '$' TK_IDENTIFICADOR '=' expr;

cmdIO: cmdin | cmdout;
cmdin: TK_PR_INPUT expr;
cmdout: TK_PR_OUTPUT listaOut;
listaOut: expr | expr ',' listaOut;

callFun: {/*TO DO */ };

shift: shiftVar | shiftVet | shiftClass | shiftVetClass;
opShift:  TK_OC_SL | TK_OC_SR;
shiftVar: TK_IDENTIFICADOR opShift TK_LIT_INT;
shiftVet: TK_IDENTIFICADOR '[' expr ']' opShift TK_LIT_INT;
shiftClass: TK_IDENTIFICADOR '$' TK_IDENTIFICADOR opShift TK_LIT_INT;
shiftVetClass: TK_IDENTIFICADOR '[' expr ']' '$' TK_IDENTIFICADOR opShift TK_LIT_INT;

rbcc: TK_PR_RETURN expr ';' | TK_PR_CONTINUE ';' | TK_PR_BREAK ';' | TK_PR_CASE TK_LIT_INT ':';

fluxo: ifst | foreach | for | while | dowhile | switch;
bloco: "{" cmdSimples "}";

stmt: bloco | ifst {/* shift reduce conflict */};
ifst: TK_PR_IF '(' expr ')' TK_PR_THEN stmt | TK_PR_IF '(' expr ')' TK_PR_THEN stmt TK_PR_ELSE stmt;

foreach: TK_PR_FOREACH '(' TK_IDENTIFICADOR ':' listaForeach ')' bloco;
listaForeach: expr | expr ',' listaForeach;

for: TK_PR_FOR '(' listaFor ':' expr ':' listaFor ')' bloco;
listaFor: cmdSimples2 | cmdSimples2 ',' listaFor {/*TODO CMDSIMPLES2 não pode ter ';' no final nem comandos com ',' */};

while: TK_PR_WHILE '(' expr ')' TK_PR_DO bloco;
dowhile: TK_PR_DO bloco TK_PR_WHILE '(' expr ')';

switch: TK_PR_SWITCH '(' expr ')' bloco;

pipes: {/*TO DO */ };

expr: id | literal | callFun | unario | binario | ternario | wpipe | expr | '(' expr ')';
id: TK_IDENTIFICADOR | TK_IDENTIFICADOR '[' expr ']';

unop: '+' | '-' | '!' | '&' | '*' | '?' | '#'; 
biop: '+' | '-' | '*' | '/' | '%' | '|' | '&' | '^' | oprel;
oprel: TK_OC_LE | TK_OC_GE | TK_OC_EQ | TK_OC_NE | TK_OC_AND | TK_OC_OR | TK_OC_SL |  TK_OC_BASH_PIPE | TK_OC_FORWARD_PIPE; 
unario: unop expr;
binario: expr biop expr;
ternario: expr '?' expr ':' expr; 

wpipes: {/*TO DO */ };

%%

int yyerror(char const *s){
	fprintf(stderr,"[ERRO] Houve erro na linha %d: %s\n",get_line_number(), s); //printa msg padrão de erro seguido do número da linha e parametro (s)
	exit(3); // terminar o programa normalmente
}