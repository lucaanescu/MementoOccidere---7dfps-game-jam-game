extends Node

#signal to display the dialog from the display_dialog function in Interaction_object script
signal display_dialog(text_key)

func _on_text_interact(key):
	print(key)
