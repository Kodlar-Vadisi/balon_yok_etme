extends Control

@onready var high_score = $Panel/HighScore
@onready var game_score = $Panel/Score


func _on_goto_menu_button_pressed():
	get_tree().paused = false
	#Evrensel.game_paused = 0
	visible = false
	
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	#Evrensel.life_booster_used = 0
	#Evrensel.shield_booster_used = 0
	#Evrensel.laser_booster_used = 0
