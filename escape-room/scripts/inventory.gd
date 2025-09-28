extends Control

@onready var c_label = $VBoxContainer/CLabel
@onready var f_label = $VBoxContainer/FLabel
@onready var g_label = $VBoxContainer/GLabel

func _ready():
	# Connect to game manager
	var game_manager = get_node("/root/Main")  # Adjust path
	if game_manager:
		game_manager.inventory_changed.connect(_on_inventory_changed)
	
	# Initialize labels
	update_display("C", 0)
	update_display("F", 0)
	update_display("G", 0)

func _on_inventory_changed(item: String, count: int):
	update_display(item, count)

func update_display(item: String, count: int):
	var text = item + ": " + str(count)
	match item:
		"C":
			c_label.text = text
		"F":
			f_label.text = text
		"G":
			g_label.text = text
