extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")
	
func _on_goto_lv_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/lv_2.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
