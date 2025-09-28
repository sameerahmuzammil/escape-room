extends Area2D

@export var flask_type: String = "C"
signal flask_touched(type: String)

func _ready():
	add_to_group("flasks")
	# Remove collision detection, use mouse instead
	input_event.connect(_on_input_event)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			flask_touched.emit(flask_type)
