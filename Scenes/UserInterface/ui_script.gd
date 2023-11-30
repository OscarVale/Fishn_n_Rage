extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_player_health():
	$HealthBar/TextureProgressBar.value = Globals.player_health
	var tween = get_tree().create_tween()
	tween.tween_property($HealthBar/TextureProgressBar, "tint_progress", Color("ff0000"), 0)
	tween.tween_property($HealthBar/TextureProgressBar, "tint_progress", Color("ffffff"), 0.3)

func stage_clear():
	var tween = get_tree().create_tween()
	tween.tween_property($Arrow, "visible", true, 0.2)
	tween.tween_property($Arrow, "visible", false, 0.7)
	tween.tween_property($Arrow, "visible", true, 0.4)
	tween.tween_property($Arrow, "visible", false, 0.7)
	tween.tween_property($Arrow, "visible", true, 0.4)
	tween.tween_property($Arrow, "visible", false, 0.7)
	tween.tween_property($Arrow, "visible", true, 0.4)
	tween.tween_property($Arrow, "visible", false, 0.7)
