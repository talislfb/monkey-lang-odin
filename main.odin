package monkey

import "core:fmt"

test_simple :: proc() {
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

test_advanced :: proc() {
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

		fmt.println("Expected: ", tt, " got: ", tok)
	}
}

main :: proc() {

	//test_simple()
	test_advanced()
}
