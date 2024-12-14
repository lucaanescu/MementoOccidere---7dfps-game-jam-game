extends CharacterBody3D

# setting up the fact that camera 3D is a variable that can exist in the world
var _camera : Camera3D
# declaring a variable for if the player is using a controler and a vector2 also audio
var look_delta : Vector2
var Footsteps : AudioStreamPlayer3D
var foot_timer : Timer

#Base values of the game that will change around
var SPEED = 3
var Sprinting = 5
const mouse_sense = 0.1
const mouse_sense_pad = 5
var mouse_dead = 0.3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#locks the mouse in the center and makes it invisible (makes it an issue if there's a controler)
func _ready():
	get_node ("Sounds/Timer").timeout.connect(_play_sound)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#just remember to wake this line up when you're done testing

func _input(event):
	_camera = get_node("Camera3d")
	
	if event is InputEventMouseMotion:
		# Actually selecting the variable for the camera in the tree while the game runs
		rotate_y(deg_to_rad(event.relative.x * -mouse_sense))
		_camera.rotate_x(deg_to_rad(event.relative.y * -mouse_sense))
		_camera.rotation.x = clamp(_camera.rotation.x,deg_to_rad(-89),deg_to_rad(89))
		# Ok degree to radians is actually good
		
		
func _play_sound():
	Footsteps = get_node("Sounds/Walk")
	Footsteps.pitch_scale = randf_range(0.8,1.3)
	Footsteps.play()
	
# Walking portion that also adds the sound
func _walking_sfx(start = true):
	foot_timer = get_node("Sounds/Timer")
	
	if start:
		if foot_timer.is_stopped():
			print(foot_timer.wait_time)
			foot_timer.start()
			_play_sound()
	else:
		if not foot_timer.is_stopped():
			foot_timer.stop()
			foot_timer.wait_time = 0.5
	
# For running
func _sprinting():
		# Some very basic running mechanics
	foot_timer = get_node("Sounds/Timer")
	if Input.is_action_pressed("Sprint"):
		SPEED = Sprinting
		foot_timer.wait_time = 0.35
	else:
		SPEED = 3
		foot_timer.wait_time = 0.5
		
# if the player is using a controler it lets them control that
func _Controler_controls():
	# camera controls for the pad, they work mostly but are still kind of janky for some reason with the new pad
	_camera = get_node("Camera3d")

		
	var y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		
	if abs(y) > mouse_dead:
		rotate_y(deg_to_rad(y * -mouse_sense_pad))
	if abs(x) > mouse_dead:
		_camera.rotate_x(deg_to_rad(x * -mouse_sense_pad))
		_camera.rotation.x = clamp(_camera.rotation.x,deg_to_rad(-79),deg_to_rad(79))

func _physics_process(delta):
	
	_Controler_controls()
	
	_sprinting()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	# I dont remember exactly why direction doesn't have to specify that it doesn't equal Vector3.Zero but I sure am glad it doesn't! Makes my life easyer
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		_walking_sfx()
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		_walking_sfx(false)
		
	move_and_slide()


func _on_timer_timeout() -> void:
	pass # Replace with function body.
