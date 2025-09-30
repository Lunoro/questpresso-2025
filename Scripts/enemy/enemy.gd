extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var direction = Direction.DOWN

@onready var vision_area = $Area2D
@onready var navigation_agent = $NavigationAgent2D
@export var target : CharacterBody2D
@export var speed : int = 200;

var in_sight = false
func _physics_process(delta: float) -> void:
	if !in_sight:
		return
		
	if navigation_agent.is_target_reached():
		return
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()

# if player was in sight for a few seconds -> npc rushes to him and chases him, if hes out of vision he stops

func get_fov_rotation() -> int:
	var fov_rotation = 0; 
	
	if(direction == Direction.LEFT) :
		fov_rotation = 90
	if(direction == Direction.RIGHT) :
		fov_rotation = -90
	if(direction == Direction.UP) :
		fov_rotation = 180
		
	return fov_rotation

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = false

func _on_timer_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position
