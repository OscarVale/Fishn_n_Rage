extends CharacterBody2D

var max_health : int
var health : int

var speed = 5000
var direction : Vector2

var takagi_state : String
var attack_state : String
@onready var takagi_animation = $MidPoint/AnimatedSprite2D
var current_animation : String = "walking"

var is_retreating : bool = false

signal get_jump_position


# Called when the node enters the scene tree for the first time.
func _ready():
	takagi_state = "roaming"
	max_health = 200
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	match takagi_state:
		"wait":
			pass
		"roaming":
			velocity = direction * speed * delta
			move_and_slide()
		"special_attack":
			pass
		"hit":
			pass
		"defeated":
			pass
	
	look_at_player()
	takagi_animation.play(current_animation)


func look_at_player():
	if Globals.player_position > global_position:
		if $MidPoint.scale.x < 0:
			$MidPoint.scale.x *= -1
	elif Globals.player_position < global_position:
		if $MidPoint.scale.x > 0:
			$MidPoint.scale.x *= -1

func hit(damage : int, _knockback : bool):
	health -= damage
	print(health)

func _on_calculate_timeout():
	direction = $".".position.direction_to(Globals.player_position)

func _on_take_action_timeout():
	pass

func _on_hurt_box_body_entered(body):
	pass
