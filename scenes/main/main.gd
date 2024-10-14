extends Node2D


var balloon_scene = load("res://scenes/balloon/balloon.tscn")

var score_scene = load("res://scenes/score/score.tscn")

var selected_balloon_type :int = 0

var balloons_to_pop = []

###############################
var balloons_to_pop_for_hint = []
var balloons_to_pop_for_hint_all = []
var selected_balloon_type_for_hint :int = 0
###############################

var score :int = 0 # anlık

var total_score := 0: # total
	set(value):
		total_score = value
		$HUD.hud_score = total_score

var empty_columns = []


var match_count = 0
#
var highscore = 0
#
var counter = 0

func _ready() -> void:
	read_high_score()
	create_balloons()

func read_high_score():
	var save_file = FileAccess.open("user://save.data", FileAccess.READ)
	if save_file != null:
		highscore = save_file.get_32()
	else:
		highscore = 0
		# dosyayı oluştur ve kaydet
		save_data()
	
func save_data():
	var save_file = FileAccess.open("user://save.data", FileAccess.WRITE)
	save_file.store_32(highscore)

func create_balloons():
	for j in range(10):
		for i in range(20):
			var balloon = balloon_scene.instantiate()
			Globals.coordinates[i][j] = Vector2(24 + 48*i, 84 + 48*j)
			balloon.position = Globals.coordinates[i][j]
			
			balloon.id = counter
			counter += 1
			
			balloon.pos_x = i
			balloon.pos_y = j
			balloon.hit.connect(_on_balloon_hit)
			$BalloonContainer.add_child(balloon)
			Globals.balloon_array[i][j] = balloon

func _on_balloon_hit(Balloon) -> void:
	selected_balloon_type = Balloon.balloon_type
	balloons_to_pop.append(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y])
	# check neighbours
	
	check_neighbours(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y])
	
	if balloons_to_pop.size()>=2:
	
		pop_balloons(balloons_to_pop)
		
		score = balloons_to_pop.size() * balloons_to_pop.size() * 10
		total_score += score
		
		show_score(Balloon, score)
		
		balloons_to_pop.clear()
		
		await get_tree().create_timer(0.5).timeout
		control_balloons_new_coordinate()
		
		find_empty_columns()
		
		union_all_columns()
	
	else:
		balloons_to_pop.clear()
	

	balloons_to_pop_for_hint.clear()
	balloons_to_pop_for_hint_all.clear()
	await get_tree().create_timer(0.5).timeout
	game_over()
	
	if match_count == 0:
		show_game_over()

func check_neighbours(Bal):
	Bal.controlled = 1
	# posx+1, posy
	if Bal.pos_x+1 <= 19:
		if Globals.balloon_array[Bal.pos_x+1][Bal.pos_y] != null:
			if selected_balloon_type == Globals.balloon_array[Bal.pos_x+1][Bal.pos_y].balloon_type && Globals.balloon_array[Bal.pos_x+1][Bal.pos_y].controlled == 0:
				balloons_to_pop.append(Globals.balloon_array[Bal.pos_x+1][Bal.pos_y])
				check_neighbours(Globals.balloon_array[Bal.pos_x+1][Bal.pos_y])
	# posx, posy-1
	if Bal.pos_y-1 >= 0:
		if Globals.balloon_array[Bal.pos_x][Bal.pos_y-1] != null:
			if selected_balloon_type == Globals.balloon_array[Bal.pos_x][Bal.pos_y-1].balloon_type && Globals.balloon_array[Bal.pos_x][Bal.pos_y-1].controlled == 0:
				balloons_to_pop.append(Globals.balloon_array[Bal.pos_x][Bal.pos_y-1])
				check_neighbours(Globals.balloon_array[Bal.pos_x][Bal.pos_y-1])
	# posx-1, posy
	if Bal.pos_x-1 >= 0:
		if Globals.balloon_array[Bal.pos_x-1][Bal.pos_y] != null:
			if selected_balloon_type == Globals.balloon_array[Bal.pos_x-1][Bal.pos_y].balloon_type && Globals.balloon_array[Bal.pos_x-1][Bal.pos_y].controlled == 0:
				balloons_to_pop.append(Globals.balloon_array[Bal.pos_x-1][Bal.pos_y])
				check_neighbours(Globals.balloon_array[Bal.pos_x-1][Bal.pos_y])
	# posx, posy+1
	if Bal.pos_y+1 <= 9:
		if Globals.balloon_array[Bal.pos_x][Bal.pos_y+1] != null:
			if selected_balloon_type == Globals.balloon_array[Bal.pos_x][Bal.pos_y+1].balloon_type && Globals.balloon_array[Bal.pos_x][Bal.pos_y+1].controlled == 0:
				balloons_to_pop.append(Globals.balloon_array[Bal.pos_x][Bal.pos_y+1])
				check_neighbours(Globals.balloon_array[Bal.pos_x][Bal.pos_y+1])

func pop_balloons(arr):
	if arr.size() >= 2:
		for i in range(arr.size()):
			arr[i].queue_free()

func show_score(Bal, value):
	var s = score_scene.instantiate()
	s.type = selected_balloon_type
	s.text = str(value)
	s.position = Globals.coordinates[Bal.pos_x][Bal.pos_y]
	$ScoreContainer.add_child(s)

func control_balloons_new_coordinate():
	Globals.balloon_array = Globals.balloon_array_reset
	
	for b in $BalloonContainer.get_children():
		b.pos_x = int(b.position.x / 48)
		#b.pos_y = int(b.position.y / 48) - 1
		
		b.pos_y = int((b.position.y-60) / 48)
		
		b.coordinate.text = str(b.pos_x) + "," + str(b.pos_y)
		Globals.balloon_array[b.pos_x][b.pos_y] = b

func find_empty_columns():
	var empty = 0
	for i in range(20):
		empty = 0
		for j in range(10):
			if Globals.balloon_array[i][j] == null:
				empty += 1
		if empty == 10:
			empty_columns.append(i)

func union_all_columns():
	if empty_columns.size() > 0:
		for i in range(empty_columns.size()):
			var hold = 0
			for j in range(empty_columns[i]):
				hold = empty_columns[i]-j
				for z in range(10):
					var old_index = Globals.balloon_array[hold-1][z]
					var new_index = Globals.balloon_array[hold][z]
					new_index = old_index
					Globals.balloon_array[hold][z] = old_index
					Globals.balloon_array[hold-1][z] = null
					if new_index != null:
						PhysicsServer2D.body_set_state(
							new_index,
							PhysicsServer2D.BODY_STATE_TRANSFORM,
							Transform2D.IDENTITY.translated(Globals.coordinates[hold][z])
						)
						#Globals.balloon_array[hold][z].set_global_position(Globals.coordinates[hold][z])
	
	empty_columns.clear()
	
	await get_tree().create_timer(0.2).timeout
	control_balloons_new_coordinate()
	

func game_over():
	match_count = 0
	for i in range(20):
		for j in range(10):
			if Globals.balloon_array[i][j] != null:
				selected_balloon_type_for_hint = Globals.balloon_array[i][j].balloon_type
				balloons_to_pop_for_hint.append(Globals.balloon_array[i][j])
				check_neighbours_for_hint(Globals.balloon_array[i][j])
				if balloons_to_pop_for_hint.size() >= 2:
					match_count = 1
					
					var arr = balloons_to_pop_for_hint.duplicate()
					var id_array = []
					for t in range(arr.size()):
						id_array.append(arr[t].id)
					id_array.sort()
					
					if id_array not in balloons_to_pop_for_hint_all:
						balloons_to_pop_for_hint_all.append(id_array)
					
				for a in balloons_to_pop_for_hint:
					a.controlled_for_hint = 0
				balloons_to_pop_for_hint.clear()
					
				#for a in balloons_to_pop_for_hint:
					#a.controlled_for_hint = 0
				#balloons_to_pop_for_hint.clear()
		

#func game_over():
	#match_count = 0
	#for i in range(20):
		#for j in range(10):
			#if Globals.balloon_array[i][j] != null:
				#selected_balloon_type_for_hint = Globals.balloon_array[i][j].balloon_type
				#balloons_to_pop_for_hint.append(Globals.balloon_array[i][j])
				#check_neighbours_for_hint(Globals.balloon_array[i][j])
			#if balloons_to_pop_for_hint.size() >= 2:
				#match_count = 1
				#
				#var arr = balloons_to_pop_for_hint.duplicate()
				#var id_array = []
				#for t in range(arr.size()):
					#id_array.append(arr[t].id)
				#id_array.sort()
				#
				#if id_array not in balloons_to_pop_for_hint_all:
					#balloons_to_pop_for_hint_all.append(id_array)
			#for a in balloons_to_pop_for_hint.size():
				#balloons_to_pop_for_hint[a].controlled_for_hint = 0
			##print(str(balloons_to_pop_for_hint_all.size()))
			#balloons_to_pop_for_hint.clear()

func check_neighbours_for_hint(Balloon):
	Balloon.controlled_for_hint = 1
	#posx+1, posy
	if Balloon.pos_x+1 < 20:
		if Globals.balloon_array[Balloon.pos_x+1][Balloon.pos_y] != null:
			if Globals.balloon_array[Balloon.pos_x+1][Balloon.pos_y].balloon_type == selected_balloon_type_for_hint && Globals.balloon_array[Balloon.pos_x+1][Balloon.pos_y].controlled_for_hint == 0:
				balloons_to_pop_for_hint.append(Globals.balloon_array[Balloon.pos_x+1][Balloon.pos_y])
				check_neighbours_for_hint(Globals.balloon_array[Balloon.pos_x+1][Balloon.pos_y])
	#posx, posy-1
	if Balloon.pos_y-1 >= 0:
		if Globals.balloon_array[Balloon.pos_x][Balloon.pos_y-1] != null:
			if Globals.balloon_array[Balloon.pos_x][Balloon.pos_y-1].balloon_type == selected_balloon_type_for_hint && Globals.balloon_array[Balloon.pos_x][Balloon.pos_y-1].controlled_for_hint == 0:
				balloons_to_pop_for_hint.append(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y-1])
				check_neighbours_for_hint(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y-1])
	#posx-1, posy
	if Balloon.pos_x - 1 >= 0:
		if Globals.balloon_array[Balloon.pos_x-1][Balloon.pos_y] != null:
			if Globals.balloon_array[Balloon.pos_x-1][Balloon.pos_y].balloon_type == selected_balloon_type_for_hint && Globals.balloon_array[Balloon.pos_x-1][Balloon.pos_y].controlled_for_hint == 0:
				balloons_to_pop_for_hint.append(Globals.balloon_array[Balloon.pos_x-1][Balloon.pos_y])
				check_neighbours_for_hint(Globals.balloon_array[Balloon.pos_x-1][Balloon.pos_y])
	#posx, posy+1
	if Balloon.pos_y+1 < 10:
		if Globals.balloon_array[Balloon.pos_x][Balloon.pos_y+1] != null:
			if Globals.balloon_array[Balloon.pos_x][Balloon.pos_y+1].balloon_type == selected_balloon_type_for_hint && Globals.balloon_array[Balloon.pos_x][Balloon.pos_y+1].controlled_for_hint == 0:
				balloons_to_pop_for_hint.append(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y+1])
				check_neighbours_for_hint(Globals.balloon_array[Balloon.pos_x][Balloon.pos_y+1])

func show_game_over():
		get_tree().paused = true
		if total_score > highscore:
			highscore = total_score
		save_data()
		$HUD.gss.high_score.text = "HighScore: " + str(highscore)
		$HUD.gss.game_score.text = "GameScore: " + str(total_score)
		$HUD.gss.visible = true
