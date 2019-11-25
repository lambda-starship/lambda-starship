extends Reference


# Generates an AST by parsing lexemes of various types.


const ParseError = preload("res://lisp/ParseError.gd")
const Types = preload("res://lisp/Types.gd")


var lexer


func _init(lexer):
	self.lexer = lexer
	

func generate_ast():
	var ast = []
	
	while lexer.has_next():
		var lexeme = lexer.next()
		
		var item
		
		if lexeme.val == '(':
			item = parse_list(lexer)
		elif lexeme.val[0] == '"':
			item = parse_string(lexeme)
		elif is_number(lexeme):
			item = parse_number(lexeme)
		else:
			item = parse_symbol(lexeme)
		
		# Return early if there was a parse error
		if item is ParseError:
			return item

		ast.append(item)

	return ast


# Parses and returns a list until its termination by consuming elements from
# the given lexer.
#
# This function may return a ParseError.
func parse_list(lexer):
	var list = Types.LispList.new()
	
	while lexer.has_next():
		var lexeme = lexer.next()
		
		var item
		
		if lexeme.val == '(':
			item = parse_list(lexer)
		elif lexeme.val == ')':
			return list
		elif lexeme.val == '\'':
			# TODO: How will I parse this?
			pass
		elif is_number(lexeme):
			item = parse_number(lexeme)
		elif lexeme.val[0] == '"':
			item = parse_string(lexeme)
		else:
			item = parse_symbol(lexeme)
	
		# Return early if there was a parse error
		if item is ParseError:
			return item
	
		list.val.append(item)
			
	return ParseError.new("Unterminated list")
	
	
func parse_string(lexeme):
	# TODO: Implement this
	pass
	
	
func parse_number(lexeme):
	# TODO: Implement this
	pass
	

func parse_symbol(lexeme):
	return Types.LispSymbol.new(lexeme.val)


func is_number(lexeme):
	# TODO: Implement this
	return false
