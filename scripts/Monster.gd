extends Node
class_name Monster

var room = null

var emotions = []

var target_emotion
var room_emotion

var queue_sprite
var potential_names = ["monster1", "monster2", "monster3", "monster4", "monster5"]
var current_name

func _init():
	emotions.resize(6)
	emotions.fill(0)
	target_emotion = randi_range(0, 5)
	current_name = potential_names.pick_random()
	var dir = DirAccess.open("res://assets/monster_sprites/")
	if dir:
		var images = []
		var files = dir.get_files()
		for f in files:
			if f.ends_with(".png") or f.ends_with(".png.import"):
				var clean_path = "res://assets/monster_sprites/" + f.replace(".import", "")
				images.append(clean_path)
				
		var random = images.pick_random()
		queue_sprite = random
	else:
		print("error")
