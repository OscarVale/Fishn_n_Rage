extends Area2D

@onready var arena_positions = $ArenaPositions.get_children()
@onready var takagi = $Sort/Takagi

signal jump_takagi(position : Vector2)

func get_safe_position():
	var point_1_position : Vector2 = $ArenaPositions/KeyPosition1.position
	var point_2_position : Vector2 = $ArenaPositions/KeyPosition2.position
	if point_1_position.distance_to(takagi.position) > point_2_position.distance_to(takagi.position):
		return point_1_position
	else:
		return point_2_position



func _on_takagi_get_jump_position():
	takagi.jump_to_position(get_safe_position())
	
