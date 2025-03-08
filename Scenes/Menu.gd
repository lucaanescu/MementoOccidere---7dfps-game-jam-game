extends CanvasLayer

#Variables for setting the background and checking wether the game is paused or not at any given state
@onready var background = self
@onready var is_paused = false

#Resets the player animation for the menu popin in and out and loads the background by default to be invisible
func _ready():
	$AnimationPlayer.play("RESET")
	background.visible = false
	
#The resume function, it does many things
#boolean for detecting if the game is paused is false, background is still not-visible, 
#engine built function for pausing the game timer is also false, makes the mouse hidden and centered again
#plays the blur animation and bringing menu in and out

func resume():
	is_paused = false
	background.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$AnimationPlayer.play("new_animation")
	$MarginContainer2.visible = false
	
#pauses the game function
#boolean for detecting if the game is paused is true, background is visible,
#pauses the game
#turns the mouse visiblr and unlocked from the center
#grabs the resume button first too, just in case you're on a controler

func pause():
	is_paused = true
	background.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$MarginContainer/MarginContainer/VBoxContainer/Resume.grab_focus()
	$AnimationPlayer.play_backwards("new_animation")
	
#function that checks wether the game is actively paused or not and flips the switch at the press of a button

func _Pausing():
	if Input.is_action_just_pressed("pause") and is_paused == false:
		pause()
		print("I'm pressed")
			
	elif Input.is_action_just_pressed("pause") and is_paused == true:
		resume()
		print("I'm pressed")
		
#Signal on the press of the Resume button that activates the resume function
	
func _on_resume_pressed():
	resume()
	
#Options menu tha does nothing for now
	
func _on_options_pressed():
	pass
	
#Should bring up a sub-menu to ask if the player is sure thats what they want to do
	
func _on_quit_pressed():
	$MarginContainer2.visible = true
	$MarginContainer2/Panel/MarginContainer/VBoxContainer/Yes.grab_focus()
	
#By default the yes and no option are invisible and once active they can be pressed to either resume the game or quit it.

func _on_no_pressed() -> void:
	$MarginContainer2.visible = false
	$MarginContainer/MarginContainer/VBoxContainer/Resume.grab_focus()
	
func _on_yes_pressed() -> void:
	get_tree().quit()
	
#The running physics function, it plays the pausing function
	
func _physics_process(delta):
	_Pausing()
