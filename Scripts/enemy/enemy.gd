extends CharacterBody2D

@onready var vision_area = $Area2D
var in_sight = false;

func _process(delta: float) -> void:
	# rotate NPC 360 degrees in 90 degrees ticks
	# update area 2d fov 
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var distance = body.global_position - global_position;
		print(distance.length());
		in_sight = true
