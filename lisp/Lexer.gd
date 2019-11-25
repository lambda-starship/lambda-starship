extends Reference

# Takes in scanemes from the scanner and produces lexemes. Lexemes are the most
# simple language elements. They're either parenthesis or an element of some
# kind.

# The scanner that the lexer is receiving data from
var scanner


func _init(scanner):
	self.scanner = scanner


# Lexes and returns the next lexeme.
func next():
	var state = State.WAITING
	var builder = LexemeBuilder.new()
	
	while scanner.has_next():
		var scaneme = scanner.next()
		
		if state == State.WAITING:
			if scaneme.val == '(' or scaneme.val == ')':
				# Parenthesis are themselves a complete lexeme
				builder.add(scaneme)
				return builder.lexeme
			elif scaneme.val == '"':
				# Marks the beginning of a string
				state = State.STRING
				builder.add(scaneme)
			elif scaneme.val == '\\':
				# Marks the beginning of an escaped character
				state = State.ESCAPE
			elif scaneme.val == '|':
				# Marks the beginning of a "piped" symbol
				state = State.PIPED_SYMBOL
				builder.add(scaneme)
			elif scaneme.val == '\'':
				# Shorthand for a call to the "quote" special operator. The
				# single quote is its own lexeme.
				builder.add(scaneme.val)
				return builder.lexeme
			elif scaneme.val != ' ':
				# Any other non-whitespace character marks the beginning of an
				# element
				state = State.ELEMENT
				# Back up one so the element lexing code doesn't miss the first
				# letter
				scanner.back_up()
		elif state == State.ELEMENT:
			if scaneme.val == ')' or scaneme.val == '(' or scaneme.val == ' ':
				# Any of these characters mark the end of the element
				scanner.back_up()
				return builder.lexeme
			builder.add(scaneme)
		elif state == State.STRING:
			builder.add(scaneme)
			if scaneme.val == '"':
				# An end-quote marks the termination of the string
				return builder.lexeme
		elif state == State.ESCAPE:
			# Escaped characters are always part of an element
			builder.add(scaneme)
			state = State.ELEMENT
		elif state == State.PIPED_SYMBOL:
			if scaneme.val == '\\':
				# Marks the beginning of an escaped character
				state = State.ESCAPED_IN_PIPED_SYMBOL
			elif scaneme.val == '|':
				# Marks the end of the piped symbol
				builder.add(scaneme)
				return builder.lexeme
			else:
				builder.add(scaneme)
		elif state == State.ESCAPED_IN_PIPED_SYMBOL:
			builder.add(scaneme)
			state = State.PIPED_SYMBOL
	
	# Emit whatever we have in the end once the scanner is out of scanemes
	return builder.lexeme


# Returns true if there are still lexemes available.
func has_next():
	return scanner.has_next()


# A single, basic unit of language consisting of one or more characters. In
# LISP, a lexeme can either be an open paranthesis, a closing paranthesis, or
# an element like a string or symbol.
class Lexeme:
	# The line number of the lexeme
	var line_number
	# The horizontal position of the first character of the lexeme
	var line_pos
	# The characters comprising the lexeme
	var val


# A utility that builds a lexeme from individual scanemes.
class LexemeBuilder:
	var lexeme: Lexeme
	
	func add(scaneme):
		if lexeme == null:
			lexeme = Lexeme.new()
			lexeme.line_number = scaneme.line_number
			lexeme.line_pos = scaneme.line_pos
			lexeme.val = scaneme.val
		else:
			lexeme.val += scaneme.val
	
	
enum State {
	# Not currently lexing anything yet
	WAITING,
	# Currently lexing a non-string element
	ELEMENT,
	# Currently lexing a string element
	STRING,
	# Currently reading an escaped character
	ESCAPED,
	# Currently reading a symbol that starts with a |, escaping all its
	# contents
	PIPED_SYMBOL,
	# Currently reading an escaped character within a piped symbol
	ESCAPED_IN_PIPED_SYMBOL,
}
