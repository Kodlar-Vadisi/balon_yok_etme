extends CanvasLayer

@onready var gss = $GameSuccessScreen
@onready var gps = $GamePausedScreen


@onready var hud_score = $Panel/Score:
	set(value):
		hud_score.text = "Score: " + str(value)


func _on_pause_pressed() -> void:
	get_tree().paused = true
	gps.visible = true
