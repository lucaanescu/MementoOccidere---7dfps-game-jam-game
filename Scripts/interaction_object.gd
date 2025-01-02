extends Node3D

@export var dialog_key : String
@export var area_active = false

func _input(event):
	if area_active == true and event.is_action_pressed("Use"):
		Text.emit_signal("display_dialog", dialog_key)


func _on_static_body_3d_mouse_entered() -> void:
	area_active = true


func _on_static_body_3d_mouse_exited() -> void:
	area_active = false
