extends Control


func _on_Button_pressed()->void:
	$AudioStreamPlayer.play()


func _on_AudioStreamPlayer_finished()->void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Main.tscn")
