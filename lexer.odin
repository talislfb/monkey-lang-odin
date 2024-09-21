package monkey

import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:unicode/utf8"

Lexer :: struct {
	input:         string,
	position:      int,
	read_position: int,
	ch:            u8,
}

new_lexer :: proc(input: string) -> ^Lexer {
	lexer := new(Lexer)
	lexer.input = input
	read_char(lexer)
	return lexer
}

read_char :: proc(lexer: ^Lexer) {
	if lexer.read_position >= len(lexer.input) {
		lexer.ch = 0x0
	} else {
		lexer.ch = lexer.input[lexer.read_position]
	}

	lexer.position = lexer.read_position
	lexer.read_position += 1
}

next_token :: proc(lexer: ^Lexer) -> Token {
	token: Token

	switch lexer.ch {
	case '=':
		token = new_token(ASSIGN, "=")
	case ';':
		token = new_token(SEMICOLON, ";")
	case '(':
		token = new_token(LPAREN, "(")
	case ')':
		token = new_token(RPAREN, ")")
	case '{':
		token = new_token(LBRACE, "{")
	case '}':
		token = new_token(RBRACE, "}")
	case ',':
		token = new_token(COMMA, ",")
	case '+':
		token = new_token(PLUS, "+")
	case 0x0:
	case:
		token = new_token(EOF, "")
	}

	read_char(lexer)
	return token
}

@(test)
test_next_token :: proc(t: ^testing.T) {
	input := "=+(){},;"

	Tests :: struct {
		expected_type:    TokenType,
		expected_literal: string,
	}

	tests := [8]Tests {
		{expected_type = ASSIGN, expected_literal = "="},
		{expected_type = PLUS, expected_literal = "+"},
		{expected_type = LPAREN, expected_literal = "("},
		{expected_type = RPAREN, expected_literal = ")"},
		{expected_type = LBRACE, expected_literal = "{"},
		{expected_type = RBRACE, expected_literal = "}"},
		{expected_type = COMMA, expected_literal = ","},
		{expected_type = SEMICOLON, expected_literal = ";"},
	}

	fmt.println(tests)

	l := new_lexer(input)
	defer free(l)

	for tt, i in tests {
		tok := next_token(l)

		testing.expectf(
			t,
			tok.type == tt.expected_type,
			"TokenType wrong. Expected [%s] got [%s]",
			tok.type,
			tt.expected_type,
		)
		testing.expectf(
			t,
			tok.literal == tt.expected_literal,
			"Literal wrong. Expected [%s] got [%s]",
			tok.literal,
			tt.expected_literal,
		)
	}

}
