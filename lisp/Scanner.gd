extends Reference

# The scanner takes text input and produces scanemes, which are characters
# with a small amount of positional metadata.

var scanemes = []

# If true, all characters in this line will be ignored. This happens after a
# comment starts.
var ignoring_line = false

# The current horizontal position of the scanner's cursor
var line_number = 0
# The current vertical position of the scanner's cursor
var line_pos = 0

# The index of the next scaneme in the list to output
var current_scaneme = 0


# Creates scanemes from the given data
func add(data):
	for c in data:
		if c == ';':
			# Beginning of a comment, ignore the rest of the line
			ignoring_line = true
		
		if not ignoring_line:
			var scaneme = Scaneme.new()
			scaneme.val = c
			scaneme.line_pos = line_pos
			scaneme.line_number = line_number
			scanemes.append(scaneme)
			
		line_pos += 1

		if c == '\n':
			# Go to the new line and reset the in-line position
			line_number += 1
			line_pos = 0
			# Newlines mark the end of a comment
			ignoring_line = false


# Returns the next scaneme
func next():
	var output = scanemes[current_scaneme]
	current_scaneme += 1
	return output
	

# Returns true if there are still non-whitespace scanemes to consume.
func has_next():
	# Read ahead to see if all future characters are whitespace. If so, the
	# scanner is basically complete as trailing whitespace has no semantic
	# meaning to the interpreter.
	var has_non_whitespace_char = false
	for i in range(current_scaneme, len(scanemes)):
		if scanemes[i].val != " ":
			has_non_whitespace_char = true
			break
	
	return current_scaneme < len(scanemes) and has_non_whitespace_char


# Moves the scanner cursor back one scaneme.
func back_up():
	current_scaneme -= 1


# A character with positional metadata
class Scaneme:
	# The character this scaneme refers to
	var val
	# The horizontal position of the character
	var line_pos
	# The line number of the character
	var line_number
