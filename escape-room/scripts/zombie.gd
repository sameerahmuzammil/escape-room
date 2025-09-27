extends CharacterBody2D

@export var speed: float = 100
@export var change_interval: float = 2.0

var direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	pick_new_direction()
	timer = change_interval

func _physics_process(delta):
	timer -= delta
	if timer <= 0:
		pick_new_direction()
		timer = change_interval

	velocity = direction * speed
	move_and_slide()

	# Agar collision hua, direction change kar do
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and not collider.is_in_group("player"):
			pick_new_direction()
			timer = change_interval
			break

func pick_new_direction():
	var choices = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	direction = choices[randi() % choices.size()]

func _on_AttackArea_body_entered(body):
	if body.is_in_group("player"):
		anim.play("attack")
		$AttackArea/AudioStreamPlayer2D.play()  # <-- if you added an AudioStreamPlayer2D node
