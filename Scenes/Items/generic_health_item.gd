extends Area2D

signal heal_player()

func _on_body_entered(_body):
	heal_player.emit()
	queue_free()
