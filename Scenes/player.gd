extends CharacterBody2D

# Variables del juegador
var max_health
var health

# Variables de movimiento
var can_run : bool = false
var is_player_running : bool = false
var last_key_pressed : String = ("right")
var speed : float = 10000

#Variables de animacion
@onready var player_animation = $MidPoint/CharacterSprite
var current_animation : String = "idle"

# Areglos con los movimientos de ataque
const quick_attack : Array = ["punch_1", "punch_2", "punch_3", "punch_4", "punch_5"]
const heavy_attack : Array = ["heavy_1", "heavy_1", "heavy_2", "heavy_2", "heavy_3"]
var attack_marker : int

# Variables para levantar y lanzar objetos
signal toss_object(sprite : Sprite2D, direction : bool, pos : Vector2)
var picked_object : PhysicsBody2D
var is_player_carrying_object : bool = false
var picked_sprite : Sprite2D

var player_is_stunned : bool = false
var player_is_defeated : bool = false

signal update_health_ui

func _ready():
	max_health = 100
	health = max_health
	Globals.player_health = max_health


func _process(delta):
	if player_is_stunned:
		player_animation.play("stun")
		return
	elif player_is_defeated:
		player_animation.play("defeated")
		return
	
	if movement_is_not_pressed() and $Timers/AttackWindow.is_stopped():
		if Input.is_action_just_pressed("third action"):
			if not is_player_carrying_object:
				pick_up()
			else:
				toss()
	
	if not is_player_carrying_object:
		if $Timers/AttackWindow.is_stopped():
			attack_marker = 0
			if Input.is_action_just_pressed("primary action") or Input.is_action_just_pressed("secondary action"):
				attack()
				is_player_running = false
		elif not $Timers/AttackWindow.is_stopped() and $Timers/AttackCooldown.is_stopped() and attack_marker < 5:
			if Input.is_action_just_pressed("primary action") or Input.is_action_just_pressed("secondary action"):
				attack()
				is_player_running = false
	
	if is_player_carrying_object:
		if movement_is_pressed():
			current_animation = "walking_object"
			move_player(delta)
		else:
			current_animation = "idle_object"
	elif $Timers/AttackWindow.is_stopped():
		if movement_is_pressed():
			current_animation = "walking"
		else:
			current_animation = "idle"
		
		if is_player_running and movement_is_not_pressed():
			is_player_running = false
		
		if movement_is_pressed():
			move_player(delta)
			
	
	player_animation.play(current_animation)
	Globals.player_position = global_position


# Funciones de movimiento
func get_movement_input():
	var input_pressed : String
	if movement_is_pressed():
		if Input.is_action_just_pressed("move up"):
			input_pressed = ("up")
		elif Input.is_action_just_pressed("move down"):
			input_pressed = ("down")
		elif Input.is_action_just_pressed("move right"):
			input_pressed = ("right")
		elif Input.is_action_just_pressed("move left"):
			input_pressed = ("left")
		else:
			input_pressed = last_key_pressed
	return input_pressed
func move_player(delta):
	var direction = Input.get_vector("move left", "move right", "move up", "move down")
	direction.y *= 0.6
	if is_player_running:
		velocity = direction * (speed * 2) * delta
	else:
		velocity = direction * speed * delta
	
	if not is_player_running and not is_player_carrying_object:
		check_if_player_can_run()
	flip_sprite()
	move_and_slide()
func movement_is_pressed():
	if Input.is_action_pressed("move up") or Input.is_action_pressed("move down") or Input.is_action_pressed("move left") or Input.is_action_pressed("move right"):
		return true
	else:
		return false
func movement_is_not_pressed():
	if not Input.is_action_pressed("move up") and not Input.is_action_pressed("move down") and not Input.is_action_pressed("move left") and not Input.is_action_pressed("move right"):
		return true
	else:
		return false
func flip_sprite():
	if velocity.x > 0 and $MidPoint.scale.x < 0:
		$MidPoint.scale.x *= -1
	elif velocity.x < 0 and $MidPoint.scale.x > 0:
		$MidPoint.scale.x *= -1
func check_if_player_can_run():
	var input_pressed : String = get_movement_input()
	
	if Input.is_action_just_pressed("move right") or Input.is_action_just_pressed("move left"):
		if last_key_pressed == input_pressed and not $Timers/RunTimer.is_stopped():
			is_player_running = true
		else:
			$Timers/RunTimer.start()
	last_key_pressed = get_movement_input()

# Funciones de ataque
func attack_table(value : String):
	var damage : int = 0
	if value == "punch_1":
		damage = damage + 5
		$Timers/AttackCooldown.start()
		$Timers/AttackWindow.start()
	elif value == "punch_2":
		damage = damage + 5
		$Timers/AttackCooldown.start()
		$Timers/AttackWindow.start()
	elif value == "punch_3":
		damage = damage + 5
		$Timers/AttackCooldown.start()
		$Timers/AttackWindow.start()
	elif value == "punch_4":
		damage = damage + 5
		$Timers/AttackCooldown.start()
		$Timers/AttackWindow.start()
	elif value == "punch_5":
		damage = damage + 10
		$Timers/AttackWindow.start()
	elif value == "heavy_1":
		damage = damage + 10
		$Timers/AttackWindow.start()
	elif value == "heavy_2":
		damage = damage + 15
		$Timers/AttackWindow.start()
	elif value == "heavy_3":
		damage = damage + 20
		$Timers/AttackWindow.start()
	
	return damage
func attack():
	var damage : int
	if Input.is_action_just_pressed("primary action"):
		damage = attack_table(quick_attack[attack_marker])
		current_animation = quick_attack[attack_marker]
		if attack_marker != 5:
			hit_bodies_in_hurtbox(damage, false)
			if check_hurtbox_collision():
				attack_marker = attack_marker + 1
				var pos
				if $MidPoint.scale.x < 0 : pos = -5
				else : pos = 5
				var tween = get_tree().create_tween()
				tween.tween_property($".", "position", $".".position + Vector2(pos ,0), 0.2)
			else:
				attack_marker = 5
	elif Input.is_action_just_pressed("secondary action"):
		damage = attack_table(heavy_attack[attack_marker])
		current_animation = heavy_attack[attack_marker]
		hit_bodies_in_hurtbox(damage, true)
		attack_marker = 5
func check_hurtbox_collision():
	if $MidPoint/PlayerArea.has_overlapping_bodies():
		return true
	else:
		return false
func hit_bodies_in_hurtbox(damage : int, knockback : bool):
	var bodies = $MidPoint/PlayerArea.get_overlapping_bodies()
	for x in bodies.size():
		#print(bodies[x])
		if bodies[x].has_method("hit"):
			bodies[x].hit(damage, knockback)

# Funciones de agarrar objetos
func pick_up():
	if check_hurtbox_collision():
		var bodies = $MidPoint/PlayerArea.get_overlapping_bodies()
		picked_object = bodies[0]
		if picked_object.has_method("picked_up"):
			picked_object.picked_up()
			is_player_carrying_object = true
func toss():
	is_player_carrying_object = false
	
	var player_direction
	if $MidPoint.scale.x > 0 : player_direction = 1
	else : player_direction = -1
	
	toss_object.emit(picked_sprite, player_direction, $".".global_position)
	var child_in_object = $MidPoint/ObjectPositionInPlayer.get_child(0)
	child_in_object.queue_free()
func drop():
	print("soltando objeto")
	is_player_carrying_object = false
	toss_object.emit(picked_sprite, 0, $".".global_position)
	var child_in_object = $MidPoint/ObjectPositionInPlayer.get_child(0)
	child_in_object.queue_free()

func hit(damage, _knockback):
	health -= damage
	player_is_stunned = true
	Globals.player_health = health
	update_health_ui.emit()
	$Timers/StunTimer.start()
	reset_player_state()
	var tween = get_tree().create_tween()
	tween.tween_property($".", "modulate", Color.CRIMSON, 0)
	tween.tween_interval(0.2)
	tween.tween_property($".", "modulate", Color.WHITE, 0)
	if is_player_carrying_object:
			drop()
	if health <= 0:
		player_is_defeated = true
		$CollisionShape2D.disabled = true

func reset_player_state():
	$Timers/RunTimer.stop()
	$Timers/AttackCooldown.stop()
	$Timers/AttackWindow.stop()
	can_run = false
	is_player_running = false
	attack_marker = 0

func _on_run_timer_timeout():
	pass


func _on_attack_cooldown_timeout():
	pass # Replace with function body.


func _on_attack_window_timeout():
	pass # Replace with function body.


func _on_level_send_sprite(sprite):
	picked_sprite = sprite.duplicate()
	$MidPoint/ObjectPositionInPlayer.add_child(picked_sprite)


func _on_stun_timer_timeout():
	player_is_stunned = false
