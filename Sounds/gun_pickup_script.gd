extends Node3D
var Gun_body : StaticBody3D

@export var dialog_key : String
var area_active = false


func _ready():
	pass 

func _process(delta):
	pass
	

func _on_static_body_3d_mouse_entered() -> void:
	area_active = true


func _on_static_body_3d_mouse_exited() -> void:
	area_active = false
