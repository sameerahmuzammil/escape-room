extends Control

@onready var start_button = $CenterContainer/VBoxContainer/StartButton
@onready var rules_button = $CenterContainer/VBoxContainer/RulesButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	rules_button.pressed.connect(_on_rules_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_rules_pressed():
	# Show rules in a simple dialog
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Mix A+B=C, D+E=F. Collect C,F,G. Avoid red banned items!"
	add_child(dialog)
	dialog.popup_centered()
	
	# Auto remove dialog when closed
	dialog.confirmed.connect(dialog.queue_free)
