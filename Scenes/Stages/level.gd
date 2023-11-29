extends Node2D

var object_projectile : PackedScene = preload("res://Scenes/object_projectile.tscn")

signal send_sprite(sprite : Sprite2D)

func _ready():
	# Conecta la senal de cada uno de los objetos de suelo
	for ground_object in get_tree().get_nodes_in_group('ground_objects_group'):
		ground_object.connect("got_picked_up", _on_object_got_picked_up)
	


func _on_object_got_picked_up(sprite : Sprite2D):
	send_sprite.emit(sprite)


func _on_player_toss_object(sprite, direction, pos):
	var projectile = object_projectile.instantiate()
	projectile.position = pos
	$YSortingLayer/Projectiles.add_child(projectile)
	if projectile.has_method("toss"):
		projectile.toss(direction, sprite)
