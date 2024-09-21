package monkey

TokenType :: string

ILLEGAL: TokenType : "ILLEGAL"
EOF: TokenType : "EOF"

IDENT: TokenType : "IDENT"
INT: TokenType : "INT"

ASSIGN: TokenType : "="
PLUS: TokenType : "+"

COMMA: TokenType : ","
SEMICOLON: TokenType : ";"

LPAREN: TokenType : "("
RPAREN: TokenType : ")"
LBRACE: TokenType : "{"
RBRACE: TokenType : "}"

FUNCTION: TokenType : "FUNCTION"
LET: TokenType : "LET"

keywords: map[string]TokenType = {
	"fn"  = FUNCTION,
	"let" = LET,
}

Token :: struct {
	type:    TokenType,
	literal: string,
}

new_token :: proc(t: TokenType, l: string) -> Token {
	return Token{type = t, literal = l}
}

lookup_identifier :: proc(ident: string) -> TokenType {
	if token, ok := keywords[ident]; ok {
		return token
	}
	return IDENT
}
