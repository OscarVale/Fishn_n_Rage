extends Node2D

@export var waves_count : int = 1
@export var end_level : bool = false

signal spawn_enemies(children : Array)
signal get_enemy_tree()
# Para comenzar la batalla, mandar true.
# Para terminar la batalla, mandar false
signal battle_update(flag : bool, ends_level : bool)

func finish_battle():
	battle_update.emit(false, end_level)
	$Calculate.stop()

func call_enemies_spawn():
	var position_markers = $SpawnPositions.get_children()
	spawn_enemies.emit(position_markers)
	print("Invocando")
	waves_count -= 1

func funcion():
	var children_count = Globals.enemy_tree.size()
	if children_count <= 0:
		if waves_count > 0:
			call_enemies_spawn()
		else:
			finish_battle()

func _on_calculate_timeout():
	get_enemy_tree.emit()
	call_deferred("funcion")

func _on_area_2d_body_entered(_body):
	$Area2D.set_deferred("monitoring", false)  
	$Calculate.start()
	get_enemy_tree.emit()
	battle_update.emit(true, end_level)
	call_enemies_spawn()
