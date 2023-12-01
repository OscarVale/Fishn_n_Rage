extends Control
var make_sound : bool = true

func _on_start_button_pressed():
	$SelectSound.play()
	make_sound = false
	TransitionLayer.change_scene("res://Scenes/Stages/level_beach.tscn")


func _on_exit_button_pressed():
	get_tree().quit()




func _on_start_button_mouse_entered():
	if make_sound:
		$HoverSound.play()


func _on_exit_button_mouse_entered():
	if make_sound:
		$HoverSound.play()
