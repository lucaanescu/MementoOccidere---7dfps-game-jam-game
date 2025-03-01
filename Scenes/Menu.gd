extends CanvasLayer

@onready var background = self

func _ready():
	$AnimationPlayer.play("RESET")
	background.visible = false
	
func resume():
	background.visible = false
	get_tree().paused = false
	$AnimationPlayer.play("new_animation")
	
func pause():
	background.visible = true
	get_tree().paused = true
	$AnimationPlayer.play_backwards("new_animation")
	
func _Pausing():
	if Input.is_action_just_pressed("pause"):
		pause()
		print("I'm pressed")
	
func _on_resume_pressed():
	resume()
	
func _on_options_pressed():
	pass
	
func _on_quit_pressed():
	get_tree().quit()
	
func _physics_process(delta):
	_Pausing()
