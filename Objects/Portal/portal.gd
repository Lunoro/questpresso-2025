extends Area2D

@export var teleport_point : Marker2D;

	# if player in area 
	# button pressed
	# player global_postion = marker global_position
	

func _on_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		body.global_position = teleport_point.global_position
