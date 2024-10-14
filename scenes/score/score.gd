extends Label

@onready var score = $"."

var type = 0

func _ready() -> void:
	if type == 0:
		label_settings.font_color = Color.RED
	if type == 1:
		label_settings.font_color = Color.BLUE
	if type == 2:
		label_settings.font_color = Color.GREEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += 100 * Vector2.UP * delta


func _on_timer_timeout() -> void:
	$".".queue_free()
