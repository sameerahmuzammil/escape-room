extends Area2D

@export var flask_type: String = "A"
signal flask_touched(type: String)

func _ready():
	add_to_group("flasks")
	add_to_group("flask_" + flask_type.to_lower())  # For specific group detection
	
	# Use mouse input detection
	input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):  # FIXED: Proper underscores
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Mouse clicked on flask: ", flask_type)
			flask_touched.emit(flask_type)
