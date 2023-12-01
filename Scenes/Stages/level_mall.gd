extends Node2D

var object_projectile : PackedScene = preload("res://Scenes/object_projectile.tscn")
var enemy_1 : PackedScene = preload("res://Scenes/Enemies/MallEnemies/mall_enemy_1.tscn")
var enemy_2 : PackedScene = preload("res://Scenes/Enemies/MallEnemies/mall_enemy_2.tscn")
var enemy_3 : PackedScene = preload("res://Scenes/Enemies/StreetEnemies/street_enemy_2.tscn")
var rounds : int = 0

@onready var player_camera : Camera2D = $YSortingLayer/Player/Camera2D

signal send_sprite(sprite : Sprite2D)

func _ready():
	# Conecta la senal de cada uno de los objetos de suelo
	for ground_object in get_tree().get_nodes_in_group('ground_objects_group'):
		ground_object.connect("got_picked_up", _on_object_got_picked_up)
	for trigger_area in get_tree().get_nodes_in_group('battle_trigger_group'):
		trigger_area.connect("spawn_enemies", _on_area_spawn_enemies)
		trigger_area.connect("get_enemy_tree", _on_area_get_enemy_tree)
		trigger_area.connect("battle_update", _on_area_battle_update)

func summon_enemies(enemy_positions : Array):
	for i in enemy_positions.size():
		var random = randi() % 3
		var new_enemy
		match random:
			0:
				new_enemy = enemy_1.instantiate()
			1:
				new_enemy = enemy_2.instantiate()
			2:
				new_enemy = enemy_3.instantiate()
		new_enemy.position = enemy_positions[i].global_position
		$YSortingLayer/Enemies.call_deferred("add_child", new_enemy)


func _on_object_got_picked_up(sprite : Sprite2D):
	send_sprite.emit(sprite)

func _on_player_toss_object(sprite, direction, pos):
	var projectile = object_projectile.instantiate()
	projectile.position = pos
	$YSortingLayer/Projectiles.add_child(projectile)
	if projectile.has_method("toss"):
		projectile.toss(direction, sprite)

# funcion para congelar la camara durante combates
func fix_camera(pos):
	player_camera.limit_right = (pos)
	player_camera.limit_left = (pos - 640)
	var value = player_camera.get_screen_center_position()
	$Barriers/LimitBarriers/StaticBody2D.global_position.x = value.x
	$Barriers/LimitBarriers/StaticBody2D/CollisionShape2D.call_deferred("set_disabled", false)
	$Barriers/LimitBarriers/StaticBody2D/CollisionShape2D2.call_deferred("set_disabled", false)

func free_camera():
	var tween = get_tree().create_tween()
	tween.tween_property(player_camera, "limit_right", player_camera.limit_right + 300, 0.8)
	tween.tween_property(player_camera, "limit_right", player_camera.limit_right + 10000000, 0)
	$Barriers/LimitBarriers/StaticBody2D/CollisionShape2D.disabled = true
	$Barriers/LimitBarriers/StaticBody2D/CollisionShape2D2.disabled = true

# Senales
func _on_area_spawn_enemies(children : Array):
	summon_enemies(children)
func _on_area_get_enemy_tree():
	Globals.enemy_tree = $YSortingLayer/Enemies.get_children()
func _on_area_battle_update(flag : bool, end : bool):
	if flag:
		fix_camera($YSortingLayer/Player/Camera2D/Marker2D.global_position.x)
	else:
		free_camera()
		if not end:
			$UI.stage_clear()
		else:
			TransitionLayer.change_scene("res://Scenes/Menus/main_menu.tscn")


func _on_player_update_health_ui():
	$UI.update_player_health()


func _on_health_pack_heal_player():
	$YSortingLayer/Player.heal()
