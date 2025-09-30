extends CharacterBody2D

@onready var vision_area = $Area2D
@onready var navigation_agent = $NavigationAgent2D
@export var target : CharacterBody2D
@export var speed : int = 200;

var in_sight = false

func _physics_process(delta: float) -> void:
	if in_sight:
		navigation_agent.target_position = target.global_position
		velocity = global_position.direction_to(navigation_agent.get_next_path_position()) * speed;
		move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = false
		
