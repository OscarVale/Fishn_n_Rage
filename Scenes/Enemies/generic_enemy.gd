extends CharacterBody2D

var max_health : int
var health : int

var speed = 5000
var direction : Vector2

var player_body : CharacterBody2D


# Enemy states: idle, approach, retreat, attack, rush, stun_light, stun_heavy, defeated
var enemy_state : String = "approach"
var idle_state : String = "stop"

@onready var enemy_animation = $MidPoint/AnimatedSprite2D
var current_animation : String = "idle"

func _ready():
	max_health = 40
	health = max_health


func _physics_process(delta):
	if enemy_state == "defeated":
		current_animation = "defeated"
		enemy_animation.play(current_animation)
		return
	
	if enemy_state != "attack":
		if enemy_state != "retreat":
			if $StunTimerShort.is_stopped() and enemy_state != "rush":
				if $".".position.distance_to(Globals.player_position) > 200:
					enemy_state = "approach"
				elif $".".position.distance_to(Globals.player_position) < 100:
					enemy_state = "idle"
	
	match enemy_state:
		"idle": # idle tendra 3 acciones diferentes: closer, farther y stop
			match idle_state:
				"closer":
					current_animation = "walking"
					velocity = direction * speed * delta
					move_and_slide()
				"farther":
					current_animation = "walking_backwards"
					velocity = direction * speed * delta * -1
					move_and_slide()
				"stop":
					current_animation = "idle"
		"approach":
			velocity = direction * speed * delta
			current_animation = "walking"
			move_and_slide()
		"retreat":
			velocity = direction * speed * delta * -1
			current_animation = "walking_backwards"
			move_and_slide()
			if $".".position.distance_to(Globals.player_position) > 150:
				enemy_state = "idle"
		"attack":
			current_animation = "attacking"
		"rush": # El enemigo se dirigira al jugador hasta que el jugador este dentro del area de ataque
			velocity = direction * speed * delta
			current_animation = "walking"
			move_and_slide()
		"stun_light":
			current_animation = "hit"
		"stun_heavy":
			pass
		"defeated":
			current_animation = "defeated"
	
	look_at_player()
	enemy_animation.play(current_animation)


func look_at_player():
	if Globals.player_position > global_position:
		if $MidPoint.scale.x < 0:
			$MidPoint.scale.x *= -1
	elif Globals.player_position < global_position:
		if $MidPoint.scale.x > 0:
			$MidPoint.scale.x *= -1

func hit(damage : int, knockback : bool):
	health = health - damage
	$CalculateTimer.stop()
	$AttackDelay.stop()
	
	var pos
	if $MidPoint.scale.x < 0 : pos = 10
	else : pos = -10
	
	var tween = get_tree().create_tween()
	if not knockback : tween.tween_property($".", "position", $".".position + Vector2(pos ,0), 0.2)
	else : tween.tween_property($".", "position", $".".position + Vector2(pos*5 ,0), 0.2)
	
	if health <= 0:
		enemy_state = "defeated"
		$DefeatedTimer.start()
		$CollisionShape2D.disabled = true
		$CalculateTimer.stop()
		tween.tween_property($".", "visible", false, 0.6)
		tween.tween_property($".", "visible", true, 0.2)
		tween.tween_property($".", "visible", false, 0.6)
		tween.tween_property($".", "visible", true, 0.2)
		tween.tween_interval(0.3)
		tween.tween_callback($".".queue_free)
		return
	enemy_state = "stun_light"
	$MidPoint/EnemyArea.monitoring = false
	$StunTimerShort.start()

func attack(body : CharacterBody2D):
	if $MidPoint/EnemyArea.has_overlapping_bodies():
		body.hit(5, false)
	$MidPoint/EnemyArea.monitoring = false



func _on_calculate_timer_timeout():
	direction = $".".position.direction_to(Globals.player_position)
	if enemy_state == "idle":
		var ran = randi() % 4
		match ran:
			0 : idle_state = "closer"
			1 : idle_state = "farther"
			2 : idle_state = "stop"
			3:
				enemy_state = "rush"
				$MidPoint/EnemyArea.monitoring = true


func _on_stun_timer_short_timeout():
	if enemy_state != "defeated":
		enemy_state = "retreat"
		$CalculateTimer.start()


func _on_enemy_area_body_entered(body):
	enemy_state = "attack"
	player_body = body
	$AttackCooldown.start()
	$AttackDelay.start()


func _on_attack_cooldown_timeout():
	if enemy_state != "defeated":
		enemy_state = "retreat"


func _on_defeated_timer_timeout():
	#queue_free()
	pass


func _on_attack_delay_timeout():
	attack(player_body)
