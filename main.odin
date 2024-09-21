package monkey

import "core:fmt"

main :: proc() {

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

	l := new_lexer(input)
	defer free(l)

	for tt, i in tests {
		tok := next_token(l)

		fmt.println("[%s] [%s]", tt.expected_literal, tok.literal)
		fmt.println("[%s] [%s]", tt.expected_type, tok.type)
	}
}
