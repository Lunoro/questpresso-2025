extends CharacterBody2D

@onready var vision_area = $Area2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	var distance = body.global_position - global_position;
	print(distance)
