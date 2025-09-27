extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980
@onready var anim = $AnimatedSprite2D
@export var speed := 200


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("Move Up"):
		input_vector.y -= 1 
		anim.play("move_up")
	elif Input.is_action_pressed("Move Down"):
		input_vector.y += 1 
		anim.play("move_down")
	elif Input.is_action_pressed("Move Right"):
		input_vector.x += 1 
		anim.play("move_right")
	elif Input.is_action_pressed("Move Left"):
		input_vector.x -= 1 
		anim.play("move_left")
	else:
		anim.play("idle")
	input_vector = input_vector.normalized()
	velocity = input_vector * speed

	move_and_slide()
