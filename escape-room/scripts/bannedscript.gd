extends Area2D

@export var flask_type: String = "bannedflask1"  # Set this for each banned item
signal flask_touched(type: String)

func _ready():
	# Add to specific banned group AND generic group
	add_to_group("banned_items")
	add_to_group("banned_" + flask_type.to_lower())
	
	# Connect collision
	body_entered.connect(_on_body_entered)
	
	# Visual indicator (red tint)
	modulate = Color(1, 0.5, 0.5)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player touched banned item: ", flask_type)
		flask_touched.emit(flask_type)
