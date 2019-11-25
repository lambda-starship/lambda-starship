extends MarginContainer

const Scanner = preload("res://lisp/Scanner.gd")
const Lexer = preload("res://lisp/Lexer.gd")
const Parser = preload("res://lisp/Parser.gd")
const ParseError = preload("res://lisp/ParseError.gd")
const LispList = preload("res://lisp/Types.gd").LispList

onready var prompt = $Container/Prompt
onready var console = $Container/Console


func _on_Submit_pressed():
	var scanner = Scanner.new()
	scanner.add(prompt.get_text())
	
	var lexer = Lexer.new(scanner)
	
	var parser = Parser.new(lexer)
	
	var ast = parser.generate_ast()
	if ast is ParseError:
		print("ParseError: " + ast.message)
		return
	
	print_ast(ast)
	

func print_ast(ast, prefix=""):
	for item in ast:
		if item is LispList:
			print_ast(item.val, prefix+"-")
		else:
			print(prefix+str(item.val))
