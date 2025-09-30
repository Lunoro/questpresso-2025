extends CharacterBody2D

@onready var vision_area = $Area2D

func _process(delta: float) -> void:
	# rotate NPC 360 degrees in 90 degrees ticks
	# update area 2d fov 
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	var distance = body.global_position - global_position;
	print(distance)
