extends StaticBody2D

var max_health : int
var health : int
var object_is_picked_up : bool = false

signal got_picked_up(sprite : Sprite2D)

func _ready():
	set_max_health(50)

func _process(_delta):
	pass

func set_max_health(value:int):
	max_health = value
	health = max_health

# Funcion necesaria para recibir dano de ataques
func hit(damage : int, _knocback):
	health = health - damage
	print(health)
	if health <= 0:
		queue_free()

func picked_up():
	got_picked_up.emit($ObjectSprite)
	queue_free()


