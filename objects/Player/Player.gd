extends KinematicBody

const SPEED = 5
const MOUSE_SENSITIVITY = 0.1

onready var face_rotation_helper = $FaceRotationHelper
onready var interaction_ray_cast = $FaceRotationHelper/InteractionRayCast

var velocity = Vector3(0, 0, 0)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Control the camera by moving the mouse
		
		# The entire object rotates in the y axis, allowing the user to turn their
		# whole body around.
		rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		# Only the FaceRotationHelper portion of the object rotates in the x axis.
		# This can be thought of as the players head. After all, you don't tilt
		# your whole body back to look up.
		face_rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		
		# Clamp the x axis rotation. This prevents the player from looking
		# behind themselves, something human necks cannot naturally do.
		var helper_rotation = face_rotation_helper.rotation_degrees
		helper_rotation.x = clamp(helper_rotation.x, -70, 70)
		face_rotation_helper.rotation_degrees = helper_rotation
		

func _process(delta):
	if Input.is_action_just_pressed("ui_interact"):
		var collider = interaction_ray_cast.get_collider()
		if collider != null and collider.has_method("interact"):
			# The player is facing an interactable object. interact with it.
			collider.interact()


func _physics_process(delta):
	# Allow the player to walk.
	var walk_velocity = Vector3(0, 0, 0)
	if Input.is_action_pressed("ui_right"):
		walk_velocity.x += transform.basis.x.x
		walk_velocity.z += transform.basis.x.z
	elif Input.is_action_pressed("ui_left"):
		walk_velocity.x -= transform.basis.x.x
		walk_velocity.z -= transform.basis.x.z
	if Input.is_action_pressed("ui_up"):
		# Move forward
		walk_velocity.x -= transform.basis.z.x
		walk_velocity.z -= transform.basis.z.z
	elif Input.is_action_pressed("ui_down"):
		# Move backward
		walk_velocity.x += transform.basis.z.x
		walk_velocity.z += transform.basis.z.z
	walk_velocity = walk_velocity.normalized() * SPEED
	velocity.x = walk_velocity.x
	velocity.z = walk_velocity.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
