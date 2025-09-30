extends CharacterBody2D

@onready var vision_area = $Area2D
@onready var navigation_agent = $NavigationAgent2D
@export var target : CharacterBody2D
@export var speed : int = 50;

var in_sight = false
func _physics_process(delta: float) -> void:
	if in_sight:
		var direction = (target.position - position).normalized()
		velocity = direction * speed
		move_and_slide()
		print(velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = false
		
