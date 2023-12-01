extends Node2D

@onready var dummy = $Dummies
@onready var jump_point = $Jump_point
var paso1 : bool = true

func _process(delta):
	if paso1:
		if dummy.position.x < jump_point.position.x:
			dummy.position.x += 1.5
			return
		else:
			dummy.visible = false
			$AnimationDummy/Sprite2D.visible = true
			paso1 = false
			var tween = get_tree().create_tween()
			tween.tween_property(dummy, "position.y", 30, 1)
