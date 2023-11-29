extends Node2D

signal fight_started(point_array : Array)
var enemy_positions : Array

func _ready():
	enemy_positions = $SpawnPositions.get_children()

func _on_area_2d_body_entered(body):
	$Area2D.monitoring = false
	fight_started.emit(enemy_positions)
