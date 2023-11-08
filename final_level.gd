extends Node2D




func _on_end_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://gameover.tscn")

