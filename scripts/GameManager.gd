extends Node
@export var button_manager: GridContainer
signal fill_room(room, tex)

var num_monsters = 3
var monsters: Array[Monster] = []
var monster_queue: Array[Monster] = []
var rooms: Array[int] = []
var room_emotions: Array[int] = []
var monster_sprites: Array[Sprite2D] = []
var timelines = []
var curr_timeline

func _init():
	init_timelines()
	rooms.resize(25)
	rooms.fill(0)
	room_emotions.resize(25)
	for i in range(25):
		room_emotions[i] = randi_range(0, 5)
	
func _ready():
	spawn_monster()
	Dialogic.VAR.monster_name = monster_queue[0].current_name
	Dialogic.VAR.character = monster_queue[0].queue_sprite.get_file().get_basename()
	random_timeline()
	Dialogic.start(curr_timeline)

func spawn_monster():
	for i in range(num_monsters):
		var new_monster = Monster.new()
		var new_sprite = Sprite2D.new()
		new_sprite.texture = load(new_monster.queue_sprite)
		new_sprite.global_position = Vector2(100+i*150, 900)
		new_sprite.global_scale = Vector2(0.15, 0.15)
		add_child(new_sprite)
		monster_sprites.append(new_sprite)
		monsters.append(new_monster)
		monster_queue.append(new_monster)
		add_child(new_monster)

func _on_assign_room(room: Variant) -> void:
	if rooms[room] == 1:
		print("room already occupied")
	elif monster_queue.is_empty():
		print("no more monsters")
	else:
		rooms[room] = 1
		monster_queue[0].room = room
		monster_queue[0].room_emotion = room_emotions[room]
		fill_room.emit(room, monster_queue[0].queue_sprite)
		monster_sprites[0].queue_free()
		monster_sprites.pop_front()
		monster_queue.pop_front()
		if (!monster_queue.is_empty()):
			for m in monster_sprites:
				m.global_position.x -= 150
			Dialogic.VAR.monster_name = monster_queue[0].current_name
			Dialogic.VAR.character = monster_queue[0].queue_sprite.get_file().get_basename()
			random_timeline()
			Dialogic.start(curr_timeline)
		#print(rooms)
		
func init_timelines():
	var dir = DirAccess.open("res://timelines/")
	if dir:
		var files = dir.get_files()
		for f in files:
			if f.ends_with(".dtl") or f.ends_with(".dtl.uid"):
				var clean_path = "res://timelines/" + f.replace(".uid", "")
				timelines.append(clean_path)
	else:
		print("error")

func random_timeline():
	var random = timelines.pick_random()
	curr_timeline = random
