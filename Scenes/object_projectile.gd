extends Area2D

var is_rolling : bool
var sprite_original_position

# Variables de fisicas
var object_gravity = 15
var object_y_velocity : float
var is_grounded : bool
var direction : int = 0

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	sprite_original_position = $Sprite_Position.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_grounded:
		sprite_physics(delta)
		slide_object(delta)


func slide_object(delta):
	if direction > 0 : $".".position.x += 150 * delta
	elif direction < 0 : $".".position.x += -150 * delta
	else : return

func sprite_physics(delta):
	object_y_velocity += object_gravity * delta
	if $Sprite_Position.position.y + object_y_velocity < sprite_original_position:
		$Sprite_Position.position.y += object_y_velocity
	else:
		$Sprite_Position.position.y = sprite_original_position
		is_grounded = true
		$Lifetime.start()
		explode()

func launch_object(value : int):
	object_y_velocity = value

# Funcion que inicia el lanzamiento
func toss(toss_direction : int, sprite : Sprite2D):
	$Sprite_Position.add_child(sprite.duplicate())
	if toss_direction > 0:
		direction = 1
		$".".position.x += 26
		launch_object(-5)
	elif toss_direction < 0:
		direction = -1
		$".".position.x -= 26
		launch_object(-5)
	else:
		launch_object(0)
		
	$Sprite_Position.position.y -= 85

func explode():
	var tween = get_tree().create_tween()
	tween.tween_property($".", "visible", false, 0.6)
	tween.tween_property($".", "visible", true, 0.2)
	tween.tween_property($".", "visible", false, 0.6)
	tween.tween_property($".", "visible", true, 0.2)
	tween.tween_interval(0.3)
	if $".".has_overlapping_bodies():
		var bodies = $".".get_overlapping_bodies()
		for y in bodies.size():
			if bodies[y].has_method("hit"):
				bodies[y].hit(20, true)


func _on_lifetime_timeout():
	$".".queue_free()
