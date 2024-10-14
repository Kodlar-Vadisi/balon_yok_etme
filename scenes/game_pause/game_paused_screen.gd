extends Control


func _on_go_to_menu_button_pressed():
	get_tree().paused = false
	#Evrensel.game_paused = 0
	visible = false
	get_tree().quit()
	#Evrensel.life_booster_used = 0
	#Evrensel.shield_booster_used = 0
	#Evrensel.laser_booster_used = 0


func _on_continue_button_pressed():
	get_tree().paused = false
	#Evrensel.game_paused = 0
	visible = false
