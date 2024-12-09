extends CharacterBody3D

# setting up the fact that camera 3D is a variable that can exist in the world
var _camera : Camera3D

#Base values of the game that will change around
var SPEED = 4
var Sprinting = 7
const JUMP_VELOCITY = 4.5
const mouse_sense = 0.1

# declaring a variable for if the player is using a controler and a vector2
var look_delta : Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#locks the mouse in the center and makes it invisible (makes it an issue if there's a controler)
#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#just remember to wake this line up when you're done testing

func _input(event):
	_camera = get_node("Head/Camera3d")
	
	if event is InputEventJoypadMotion:
		print("I'm reading this")
		rotate_y(deg_to_rad(event.x * -mouse_sense))
		_camera.rotate_x(deg_to_rad(event.y * -mouse_sense))
		_camera.rotation.x = clamp(_camera.rotation.x,deg_to_rad(-79),deg_to_rad(79))
	
	if event is InputEventMouseMotion:
		# Actually selecting the variable for the camera in the tree while the game runs
		rotate_y(deg_to_rad(event.relative.x * -mouse_sense))
		_camera.rotate_x(deg_to_rad(event.relative.y * -mouse_sense))
		_camera.rotation.x = clamp(_camera.rotation.x,deg_to_rad(-79),deg_to_rad(79))
		# Ok degree to radians is actually good

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Some very basic running mechanics
	if Input.is_action_pressed("Sprint"):
		SPEED = Sprinting
	else:
		SPEED = 4

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	# I dont remember exactly why direction doesn't have to specify that it doesn't equal Vector3.Zero but I sure am glad it doesn't! Makes my life easyer
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
