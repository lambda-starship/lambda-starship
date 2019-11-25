extends Label

export(NodePath) var player_path
onready var player = get_node(player_path)


func _ready():
	clear_prompt()


func interact_prompt():
	"""Displays a prompt telling the user they can interact with something.
	"""
	# Find the interaction key name for a keyboard user
	var interaction_key_name = ""
	for input_event in InputMap.get_action_list("ui_interact"):
		if input_event is InputEventKey:
			interaction_key_name = input_event.as_text()
			break
	if interaction_key_name == "":
		print("Error: No interaction key found in InputMap")
	
	set_text("Press [" + interaction_key_name + "] to interact")


func clear_prompt():
	"""Clears any perviously displayed prompt."""
	set_text("")


func _process(delta):
	var interaction_ray_cast = player.interaction_ray_cast
	
	var collider = interaction_ray_cast.get_collider()
	if collider != null and collider.has_method("interact"):
		# The node is an interactable object. Display the option to the user.
		interact_prompt()
	else:
		clear_prompt()
