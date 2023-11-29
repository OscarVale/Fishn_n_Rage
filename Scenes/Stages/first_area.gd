extends Area2D

@export var waves_count : int = 1

signal spawn_enemies(children : Array)

# Para comenzar la batalla, mandar true.
# Para terminar la batalla, mandar false
signal battle_update(flag : bool)


func finish_battle():
	battle_update.emit(false)


func call_enemies_spawn():
	var position_markers = $SpawnPositions.get_children()
	spawn_enemies.emit(position_markers)
	print("Invocando")
	waves_count -= 1


func _on_calculate_timeout():
	var children_count = $"../../YSortingLayer/Enemies".get_child_count()
	if children_count <= 0:
		if waves_count > 0:
			call_enemies_spawn()
		else:
			finish_battle()


func _on_body_entered(_body):
	$".".set_deferred("monitoring", false)  
	battle_update.emit(true)
	call_enemies_spawn()








