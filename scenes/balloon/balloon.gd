extends RigidBody2D

signal hit

var pos_x = 0
var pos_y = 0

var balloon_type :int = 0

var controlled = 0
var controlled_for_hint = 0

var id = 0

@onready var coordinate = $Coordinate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	balloon_type = randi_range(0,2)
	$Sprite2D.texture = load(Globals.balloons[balloon_type])
	$Coordinate.text = str(pos_x) + "," + str(pos_y)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_pressed():
		hit.emit(self)
