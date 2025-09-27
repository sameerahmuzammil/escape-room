# === START SCENE SCRIPT (StartScene.gd) ===
# (Attach to your start scene main node)

extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var rules_button = $VBoxContainer/RulesButton
@onready var rules_panel = $RulesPanel
@onready var back_button = $RulesPanel/VBoxContainer/BackButton
@onready var rules_text = $RulesPanel/VBoxContainer/ScrollContainer/RulesLabel

func _ready():
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	rules_button.pressed.connect(_on_rules_pressed)
	
	# Hide rules panel initially
	rules_panel.visible = false
	
	# Set up rules text
	setup_rules_text()

func _on_start_pressed():
	print("Starting game...")
	# Change to main game scene
	get_tree().change_scene_to_file("res://Main.tscn")  # Adjust path to your main scene

func _on_rules_pressed():
	print("Showing rules...")
	rules_panel.visible = true



func setup_rules_text():
	var rules = """
🧪 FLASK MIXING RULES 🧪

OBJECTIVE:
Collect C, F, and G flasks in your inventory!

MIXING RECIPES:
• A + B = C (in order)
• D + E = F (in order)
• G can be collected directly

HOW TO PLAY:
1. Click flasks to collect them
2. Flasks disappear when clicked
3. Must complete recipes in sequence
4. Only C, F, G go to your inventory

⚠️ DANGER:
• Red objects are BANNED!
• Clicking banned items removes 1 heart
• You have 3 hearts - don't lose them all!

STRATEGY:
• Click A, then B to create C
• Click D, then E to create F  
• Avoid red banned objects
• Collect C, F, G for victory!

Good luck! 🍀
"""
	rules_text.text = rules

# === ALTERNATIVE: SIMPLE START SCENE ===
# (If you prefer a simpler version without rules panel)

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

# ===================================================================
# === SCENE STRUCTURE GUIDE ===
# ===================================================================

# OPTION 1: Full Rules Panel Scene Structure:
# StartScene (Control)
# ├── Background (ColorRect or TextureRect)
# ├── VBoxContainer
# │   ├── TitleLabel ("Flask Mixer Game")
# │   ├── StartButton
# │   └── RulesButton  
# └── RulesPanel (Panel)
#     └── VBoxContainer
#         ├── TitleLabel ("Rules")
#         ├── ScrollContainer
#         │   └── RulesLabel (rich text enabled)
#         └── BackButton

# OPTION 2: Simple Scene Structure:
# StartScene (Control)
# └── CenterContainer
#     └── VBoxContainer
#         ├── TitleLabel
#         ├── StartButton
#         └── RulesButton

# ===================================================================
# === GAME SCENE TRANSITION SCRIPT ===
# (Add this to your main game scene if you want a back to menu option)
# ===================================================================

extends Node

func _input(event):
	# Press ESC to return to main menu
	if event.is_action_pressed("ui_cancel"):
		return_to_menu()

func return_to_menu():
	get_tree().change_scene_to_file("res://StartScene.tscn")

# You can also add a pause menu with back to main menu option
# === GAME MANAGER SCRIPT (Main Scene) ===
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


# ===================================================================
# === INVENTORY UI SCRIPT (InventoryUI.gd) ===
# (Attach to inventory UI container in top corner)
# ===================================================================

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

# ===================================================================
# === HEALTH UI SCRIPT (HealthUI.gd) ===
# (Attach to hearts container in top corner)
# ===================================================================

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
