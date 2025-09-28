extends Node2D

# Define your mixing recipes (order matters!)
var recipes = {
	["A", "B"]: "C",
	["B", "A"]: "C",  # Same result, different order
	["D", "E"]: "F",
	["E", "D"]: "F"   # Same result, different order
}

var current_sequence = []
var blocked_flasks = []

# INVENTORY TRACKING - Only C, F, G
var inventory = {
	"C": 0,
	"F": 0,
	"G": 0
}

# HEALTH SYSTEM
@export var max_health: int = 3
var current_health: int = 3

# BANNED ITEMS
var banned_items = ["bannedflask1", "bannedflask2", "bannedjar", "bannedcomputer"]  # Add your banned item names

signal inventory_changed(item: String, count: int)
signal health_changed(new_health: int)

func _ready():
	# Initialize health
	current_health = max_health
	
	# Connect all flask signals
	connect_all_objects()

func connect_all_objects():
	# Connect regular flasks
	var flasks = get_tree().get_nodes_in_group("flasks")
	for flask in flasks:
		flask.flask_touched.connect(_on_flask_touched)
	
	# Connect banned items
	var banned_objects = get_tree().get_nodes_in_group("banned_items")
	for banned in banned_objects:
		banned.flask_touched.connect(_on_flask_touched)

func _on_flask_touched(flask_type: String):
	print("Touched: ", flask_type)
	
	# Check if banned item
	if flask_type in banned_items:
		handle_banned_item(flask_type)
		return
	
	# Check if inventory item (C, F, G) - collect immediately
	if flask_type in inventory.keys():
		collect_inventory_item(flask_type)
		return
	
	# Check if blocked
	if flask_type in blocked_flasks:
		print(flask_type, " is blocked! Complete current recipe first.")
		return
	
	# Add to sequence for mixing
	current_sequence.append(flask_type)
	print("Current sequence: ", current_sequence)
	
	# Remove clicked flask immediately
	remove_flask_from_scene(flask_type)
	
	# Check for recipe completion
	check_for_recipe()

func remove_flask_from_scene(flask_type: String):
	var flasks = get_tree().get_nodes_in_group("flasks")
	for flask in flasks:
		if flask.flask_type == flask_type:
			# Visual feedback
			flask.modulate = Color.GREEN
			var tween = create_tween()
			tween.tween_property(flask, "scale", Vector2.ZERO, 0.3)
			tween.tween_callback(flask.queue_free)
			break

func collect_inventory_item(item_type: String):
	# Add to inventory
	inventory[item_type] += 1
	print("Collected ", item_type, "! Total: ", inventory[item_type])
	
	# Remove from scene
	remove_flask_from_scene(item_type)
	
	# Update UI
	inventory_changed.emit(item_type, inventory[item_type])
	print_inventory()

func handle_banned_item(item_type: String):
	print("Hit banned item: ", item_type, "! Losing 1 heart!")
	
	# Decrease health
	current_health -= 1
	current_health = max(current_health, 0)
	
	# Update UI
	health_changed.emit(current_health)
	print("Hearts remaining: ", current_health)
	
	# Remove banned item with red effect
	var banned_objects = get_tree().get_nodes_in_group("banned_items")
	for banned in banned_objects:
		if banned.flask_type == item_type:
			banned.modulate = Color.RED
			var tween = create_tween()
			tween.tween_property(banned, "modulate:a", 0.0, 0.5)
			tween.tween_callback(banned.queue_free)
			break
	
	# Check game over
	if current_health <= 0:
		game_over()

func check_for_recipe():
	# Check if we have a complete recipe
	for recipe_ingredients in recipes.keys():
		if arrays_equal(current_sequence, recipe_ingredients):
			var result = recipes[recipe_ingredients]
			print("Recipe complete! Created: ", result)
			spawn_result(result)
			reset_sequence()
			return
		
		# Check if current sequence is start of this recipe
		if is_sequence_start(current_sequence, recipe_ingredients):
			block_other_flasks(recipe_ingredients)
			return
	
	# No matching recipe found
	print("No recipe matches, resetting...")
	reset_sequence()

func is_sequence_start(current: Array, recipe: Array) -> bool:
	if current.size() > recipe.size():
		return false
	
	for i in range(current.size()):
		if current[i] != recipe[i]:
			return false
	return true

func arrays_equal(arr1: Array, arr2: Array) -> bool:
	if arr1.size() != arr2.size():
		return false
	for i in range(arr1.size()):
		if arr1[i] != arr2[i]:
			return false
	return true

func block_other_flasks(recipe_ingredients: Array):
	blocked_flasks.clear()
	
	# Block all flasks not in current recipe
	var all_types = ["A", "B", "C", "D", "E", "F", "G"]
	for flask_type in all_types:
		if not flask_type in recipe_ingredients:
			blocked_flasks.append(flask_type)
	
	print("Blocked flasks: ", blocked_flasks)

func spawn_result(result_type: String):
	print("Spawning ", result_type)
	
	# Create new flask
	var new_flask = preload("res://Flask.tscn").instantiate()
	new_flask.flask_type = result_type
	
	# Position it somewhere visible
	new_flask.position = Vector2(400, 300)  # Adjust as needed
	
	add_child(new_flask)
	new_flask.flask_touched.connect(_on_flask_touched)
	
	# Visual spawn effect
	new_flask.scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(new_flask, "scale", Vector2.ONE, 0.5)

func reset_sequence():
	current_sequence.clear()
	blocked_flasks.clear()
	print("Sequence reset - all flasks available again")

func print_inventory():
	print("=== INVENTORY ===")
	for item in inventory.keys():
		if inventory[item] > 0:
			print(item, ": ", inventory[item])
	print("================")

func game_over():
	print("GAME OVER! No hearts left!")
	# Add your game over logic:
	# get_tree().change_scene_to_file("res://GameOver.tscn")
