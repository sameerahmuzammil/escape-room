extends Control

@onready var heart1 = $HBoxContainer/Heart1
@onready var heart2 = $HBoxContainer/Heart2
@onready var heart3 = $HBoxContainer/Heart3

var hearts = []

func _ready():
	hearts = [heart1, heart2, heart3]
	
	# Connect to game manager
	var game_manager = get_node("/root/Main")  # Adjust path
	if game_manager:
		game_manager.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int):
	print("Hearts remaining: ", new_health)
	
	# Show/hide hearts
	for i in range(hearts.size()):
		hearts[i].visible = (i < new_health)
