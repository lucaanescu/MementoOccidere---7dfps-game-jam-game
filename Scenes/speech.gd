extends CanvasLayer

#Dont think this works so ill just load it the old fashioned way
#@export_enum(String, FILE, "*Json") var scene_text_file

var Scene_text_file = load("res://Jsons/Descriptions Memento Occidere.json")

var scene_text = {}
var selected_text = []
var in_progress = false

@onready var background = $Textbox
@onready var text_label = $Dialogue

func _ready():
	background.visible = false
	scene_text = load_scene_text()
	Text.connect("display_dialog",self, "on_display_dialog")
	
func load_scene_text():
	var file = FileAccess.new()
	if file.file_exists(Scene_text_file):
		file.open(Scene_text_file, FileAccess.READ)
		return JSON.parse(file.get_as_text())
		
func show_text():
	text_label.text = selected_text.pop_front()
		
func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish():
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false

func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
	
