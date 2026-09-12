extends Node
@export var button_manager: GridContainer
@export var background: TextureRect
@export var energy_label: Label
@export var a_s: Label
@export var d_u: Label
@export var f_r: Label
signal fill_room(room, tex)
signal change_state

var num_monsters = 3
var monsters: Array[Monster] = []
var monster_queue: Array[Monster] = []
var rooms: Array[Monster] = []
var room_emotions: Array[int] = []
var monster_sprites: Array[Sprite2D] = []
var queue_timelines = []
var room_timelines = []
var curr_timeline
var energy = 3

func _init():
	init_timelines()
	rooms.resize(25)
	room_emotions.resize(25)
	for i in range(25):
		room_emotions[i] = randi_range(0, 5)
	
func _ready():
	energy_label.hide()
	a_s.hide()
	d_u.hide()
	f_r.hide()
	energy_label.text = "Energy: " + str(energy)
	spawn_monster()
	Dialogic.VAR.monster_name = monster_queue[0].current_name
	Dialogic.VAR.character = monster_queue[0].queue_sprite.get_file().get_basename()
	random_queue_timeline()
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
	if rooms[room] != null:
		print("room already occupied")
	elif monster_queue.is_empty():
		print("no more monsters")
	else:
		rooms[room] = monster_queue[0]
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
			random_queue_timeline()
			Dialogic.start(curr_timeline)
		else:
			energy_label.show()
			change_state.emit()
			init_emotions()
		
func init_timelines():
	var dir = DirAccess.open("res://timelines/queue_timelines/")
	if dir:
		var files = dir.get_files()
		for f in files:
			if f.ends_with(".dtl") or f.ends_with(".dtl.uid"):
				var clean_path = "res://timelines/queue_timelines/" + f.replace(".uid", "")
				queue_timelines.append(clean_path)
	else:
		print("error")
		
	var dir2 = DirAccess.open("res://timelines/room_timelines/")
	if dir2:
		var files = dir2.get_files()
		for f in files:
			if f.ends_with(".dtl") or f.ends_with(".dtl.uid"):
				var clean_path = "res://timelines/room_timelines/" + f.replace(".uid", "")
				room_timelines.append(clean_path)
	else:
		print("error")

func random_queue_timeline():
	var random = queue_timelines.pick_random()
	curr_timeline = random
	
func random_room_timeline():
	var random = room_timelines.pick_random()
	curr_timeline = random

func _on_trigger_convo(room: Variant) -> void:
	if rooms[room] != null:
		if room_emotions[room] == 0:
			background.texture = load("res://assets/backgrounds/anxious_temp.jpg")
			background.scale = Vector2(0.96, 0.96)
		if room_emotions[room] == 1:
			background.texture = load("res://assets/backgrounds/serene_temp.jpg")
			background.scale = Vector2(1, 1)
		if room_emotions[room] == 2:
			background.texture = load("res://assets/backgrounds/disarray_temp.jpg")
			background.scale = Vector2(0.915, 0.915)
		if room_emotions[room] == 3:
			background.texture = load("res://assets/backgrounds/uniform_temp.webp")
			background.scale = Vector2(1, 1)
		if room_emotions[room] == 4:
			background.texture = load("res://assets/backgrounds/forgotten_temp.jpg")
			background.scale = Vector2(1.065, 1.065)
		if room_emotions[room] == 5:
			background.texture = load("res://assets/backgrounds/retrospective_temp.jpg")
			background.scale = Vector2(0.535, 0.535)
		var a_s_calculation = rooms[room].emotions[1] - rooms[room].emotions[0]
		var d_u_calculation = rooms[room].emotions[3] - rooms[room].emotions[2]
		var f_r_calculation = rooms[room].emotions[5] - rooms[room].emotions[4]
		a_s.text = "Anxiety-Serenity: " + str(a_s_calculation)
		d_u.text = "Disarray-Uniformity: " + str(d_u_calculation)
		f_r.text = "Forgotten-Retrospective: " + str(f_r_calculation)
		a_s.show()
		d_u.show()
		f_r.show()
		energy -= 1
		energy_label.text = "Energy: " + str(energy)
		button_manager.hide()
		energy_label.hide()
		Dialogic.VAR.monster_name = rooms[room].current_name
		Dialogic.VAR.character = rooms[room].queue_sprite.get_file().get_basename()
		random_room_timeline()
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start(curr_timeline)
	else:
		print("no occupant")
		
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	button_manager.show()
	energy_label.show()
	a_s.hide()
	d_u.hide()
	f_r.hide()
	background.texture = load("res://assets/backgrounds/temp_bg2.jpg")
	background.scale = Vector2(0.395, 0.395)
	
func init_emotions():
	for m in monsters:
		m.emotions[m.room_emotion] += 1
