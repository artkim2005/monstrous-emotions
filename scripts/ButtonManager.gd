extends GridContainer
@export var game_manager : Node
signal assign_room(room)
var buttons

var emotions = ["A", "S", "U", "D", "F", "R"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttons = get_children()
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
		buttons[i].text = emotions[game_manager.room_emotions[i]]

func _on_button_pressed(index: int):
	assign_room.emit(index)

func _on_fill_room(room: Variant, tex: Variant) -> void:
	buttons[room].icon = load(tex)
	buttons[room].text = ""
