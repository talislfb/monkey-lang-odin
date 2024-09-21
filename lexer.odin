package monkey

import "core:fmt"
import "core:mem"
import "core:strconv"
import "core:strings"
import "core:testing"
import "core:unicode"
import "core:unicode/utf8"

Lexer :: struct {
	input:         string,
	position:      int,
	read_position: int,
	ch:            rune,
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
		lexer.ch = utf8.rune_at(lexer.input, lexer.read_position)
	}

	lexer.position = lexer.read_position
	lexer.read_position += 1
}

read_number :: proc(lexer: ^Lexer) -> string {
	position := lexer.position

	for is_digit(lexer.ch) {
		read_char(lexer)
	}

	return lexer.input[position:lexer.position]
}

read_identifier :: proc(lexer: ^Lexer) -> string {
	position := lexer.position

	for is_letter(lexer.ch) {
		read_char(lexer)
	}

	return lexer.input[position:lexer.position]
}

is_letter :: proc(r: rune) -> bool {
	return 'a' <= r && r <= 'z' || 'A' <= r && r <= 'Z' || r == '_'
}

is_digit :: proc(r: rune) -> bool {
	return '0' <= r && r <= '9'
}

skip_white_spaces :: proc(lexer: ^Lexer) {
	for lexer.ch == ' ' || lexer.ch == '\t' || lexer.ch == '\n' || lexer.ch == '\r' {
		read_char(lexer)
	}
}

next_token :: proc(lexer: ^Lexer) -> Token {
	token: Token

	skip_white_spaces(lexer)

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
		token = new_token(EOF, "")
	case:
		if is_letter(lexer.ch) {
			token.literal = read_identifier(lexer)
			token.type = lookup_identifier(token.literal)
			return token
		} else if is_digit(lexer.ch) {
			token.literal = read_number(lexer)
			token.type = INT
			return token
		} else {
			illegal := fmt.aprintf("{0}", lexer.ch)
			defer delete(illegal)
			token = new_token(ILLEGAL, illegal)
		}
	}

	read_char(lexer)
	return token
}

Tests :: struct {
	expected_type:    TokenType,
	expected_literal: string,
}

@(test)
test_next_token :: proc(t: ^testing.T) {
	input := "=+(){},;"

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

@(test)
test_next_token_advanced :: proc(t: ^testing.T) {
	input := `let five = 5;
		let ten = 10;

		let add = fn(x, y) {
			x + y;
		};
		
		let result = add(five, ten);
	`

	tests := [?]Tests {
		{expected_type = LET, expected_literal = "let"},
		{expected_type = IDENT, expected_literal = "five"},
		{expected_type = ASSIGN, expected_literal = "="},
		{expected_type = INT, expected_literal = "5"},
		{expected_type = SEMICOLON, expected_literal = ";"},
		{expected_type = LET, expected_literal = "let"},
		{expected_type = IDENT, expected_literal = "ten"},
		{expected_type = ASSIGN, expected_literal = "="},
		{expected_type = INT, expected_literal = "10"},
		{expected_type = SEMICOLON, expected_literal = ";"},
		{expected_type = LET, expected_literal = "let"},
		{expected_type = IDENT, expected_literal = "add"},
		{expected_type = ASSIGN, expected_literal = "="},
		{expected_type = FUNCTION, expected_literal = "fn"},
		{expected_type = LPAREN, expected_literal = "("},
		{expected_type = IDENT, expected_literal = "x"},
		{expected_type = COMMA, expected_literal = ","},
		{expected_type = IDENT, expected_literal = "y"},
		{expected_type = RPAREN, expected_literal = ")"},
		{expected_type = LBRACE, expected_literal = "{"},
		{expected_type = IDENT, expected_literal = "x"},
		{expected_type = PLUS, expected_literal = "+"},
		{expected_type = IDENT, expected_literal = "y"},
		{expected_type = SEMICOLON, expected_literal = ";"},
		{expected_type = RBRACE, expected_literal = "}"},
		{expected_type = SEMICOLON, expected_literal = ";"},
		{expected_type = LET, expected_literal = "let"},
		{expected_type = IDENT, expected_literal = "result"},
		{expected_type = ASSIGN, expected_literal = "="},
		{expected_type = IDENT, expected_literal = "add"},
		{expected_type = LPAREN, expected_literal = "("},
		{expected_type = IDENT, expected_literal = "five"},
		{expected_type = COMMA, expected_literal = ","},
		{expected_type = IDENT, expected_literal = "ten"},
		{expected_type = RPAREN, expected_literal = ")"},
		{expected_type = SEMICOLON, expected_literal = ";"},
		{expected_type = EOF, expected_literal = ""},
	}

	l := new_lexer(input)
	defer free(l)

	for tt, i in tests {
		tok := next_token(l)

		testing.expectf(
			t,
			tt.expected_type == tok.type,
			"TokenType wrong. Expected [%s] got [%s]",
			tt.expected_type,
			tok.type,
		)
		testing.expectf(
			t,
			tt.expected_literal == tok.literal,
			"Literal wrong. Expected [%s] got [%s]",
			tt.expected_literal,
			tok.literal,
		)
	}
}
