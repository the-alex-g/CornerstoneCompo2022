extends Control


func _on_Button_pressed()->void:
	#$AudioStreamPlayer.play()
	get_tree().change_scene("res://Main.tscn")


func _on_AudioStreamPlayer_finished()->void:
	# warning-ignore:return_value_discarded
	pass
