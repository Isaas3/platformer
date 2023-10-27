extends Node2D



func _on_interact_body_entered(body):
	if body.is_in_group("Player"):
		body.die()
