extends CharacterBody3D

# For dialogue later, this is an empty string
var dialog_key = ""

var current_object

# setting up the fact that camera 3D is a variable that can exist in the world, but also the fov of the camera 
var _camera : Camera3D
# declaring a variable for if the player is using a controler and a vector2 also audio
var look_delta : Vector2
var Footsteps : AudioStreamPlayer3D
var cocking : AudioStreamPlayer3D
var foot_timer : Timer
var Reach : RayCast3D
var gun : Node3D

#Base values of the game that will change around
var gun_is_active = false
var _is_camera_scoped = false
var SPEED = 3
var Sprinting = 5
const mouse_sense = 0.1
const mouse_sense_pad = 5
var mouse_dead = 0.3
var _noHit
var _zoom_fov = 20.0
var _default_fov = 75.0
var _zoom_speed = 4.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#locks the mouse in the center and makes it invisible (makes it an issue if there's a controler)
func _ready():
	get_node ("Sounds/Timer").timeout.connect(_play_sound)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#just remember to wake this line up when you're done testing

#This code acknologes the colision between the floor gun and the player then awakening the gun their carrying
func _pick_up_gun():
	Reach = get_node("Camera3d/Reach")
	gun = get_node("Camera3d/rifle3")
	cocking = get_node("Sounds/Gun loading")
	
#This just checks for the gun if in range with the collider and perform all the gun 'pickup' actions
	if Reach.is_colliding():
		
		var hit = Reach.get_collider()
		print(hit)
		
		if hit.get_name() == "Gun_body":
			hit.free()
			gun.visible = true
			cocking.volume_db = -15
			cocking.play()

func _input(event):
	_camera = get_node("Camera3d")
	
	if event is InputEventMouseMotion:
# Actually selecting the variable for the camera in the tree while the game runs
		rotate_y(deg_to_rad(event.relative.x * -mouse_sense))
		_camera.rotate_x(deg_to_rad(event.relative.y * -mouse_sense))
		_camera.rotation.x = clamp(_camera.rotation.x,deg_to_rad(-89),deg_to_rad(89))
# Ok degree to radians is actually good
		
#opens up the menu if you're in the middle of the game
func _open_menu():
	pass
		
func _interact():
	Reach = get_node("Camera3d/Reach")
	var hit = Reach.get_collider()
	
#checks if it hits anything
	if Reach.is_colliding():
		
#checks if hit is null or doesnt get an object with the method "_on static body 3d"
		
		if hit == null or !hit.get_parent().has_method("_on_static_body_3d_mouse_entered"):
			gun_is_active = true
#checks if hit is not null or doesnt get an object with the method "_on static body 3d"
#this is so that it can claim it left the detection zone so that it could pick up the gun
			
#if it hits something but also doesnt have the exit function of the parent then hit is set to exiting the hit item as if it hits nothing
			if hit != null and !hit.get_parent().has_method("_on_static_body_3d_mouse_exited"):
				hit.get_parent()._on_static_body_3d_mouse_exited()
				
#if it hit anything that has those values (isnt null and has enter or exit method) it activates get parent entered and starts the chain reaction to open the dialogue box
#also saves the hit values to no_hit a global variable that can get called later
		else:
			hit.get_parent()._on_static_body_3d_mouse_entered()
			_noHit = hit
#if nohit is stored as anything then it is called and it gets the exit function of the interact script then sets itself back to null
	else:
		if _noHit != null :
			_noHit.get_parent()._on_static_body_3d_mouse_exited()
			_noHit = null
		
#code for the gun scope
func _gun_controls_zoom():
	_camera = get_node("Camera3d")
	var fov_camera : float = _camera.fov
#calls two camera variables and makes two if statements, if the camera is zoomed in then it performs the lerp zoom at a max length
	if _is_camera_scoped == true:
		_camera.set_fov(lerp(_camera.fov, _zoom_fov, get_process_delta_time() * _zoom_speed))
#if the camera is not zoomed then it goes back to default field of vision
	if _is_camera_scoped == false:
		_camera.set_fov(lerp(_camera.fov, _default_fov, get_process_delta_time() * _zoom_speed))
	
# This code just plays sounds
func _play_sound():
	Footsteps = get_node("Sounds/Walk")
	Footsteps.pitch_scale = randf_range(0.8,1.3)
	Footsteps.play()
	
# Walking portion that also adds the sound and resets the delay between footsteps
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
# Some very basic running mechanics, all it does is call the game objects and change them to a faster speed before changing them back
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
	
	if Input.is_action_just_pressed("Use") and gun_is_active == false:
		_pick_up_gun()
	
#checks if the player has the gun and if they are scoped or not. The zoom function is always being called but just stoped by a bunch of bools
	if Input.is_action_pressed("Scope") and gun_is_active == true:
		_is_camera_scoped = true
	else:
		_is_camera_scoped = false
	
	_gun_controls_zoom()
	_Controler_controls()
	_sprinting()
	_interact()
	
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
