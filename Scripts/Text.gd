extends Node

#signal to display the dialog
signal display_dialog(text_key)

func _on_text_interact(key):
	print(key)
