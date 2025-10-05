extends Area2D

var entered = false

func _on_body_entered(body: Node2D) -> void:
	print("entered")
	entered = true
	
func _on_body_exited(body: Node2D) -> void:
	entered = false
	
func _process(delta):
	if entered == true:
		get_tree().change_scene_to_file("res://Scenes/stage2.tscn")
