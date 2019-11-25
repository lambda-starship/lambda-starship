extends Reference


class LispList extends Reference:
	var val = []


class LispString extends Reference:
	var val = ""


class LispSymbol extends Reference:
	var val = ""
	
	func _init(val):
		self.val = val
