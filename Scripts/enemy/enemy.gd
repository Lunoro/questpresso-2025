extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var direction = Direction.DOWN

@onready var vision_area = $Area2D
@onready var navigation_agent = $NavigationAgent2D
@export var target : CharacterBody2D
@export var speed : int = 125;

var is_triggered = false
var in_sight = false

var is_attacking = false
var is_moving = false

func _physics_process(delta: float) -> void:
	update_animation()
	update_rotation()
	update_fov()
	find_path()
	move_and_slide()
	
func find_path():
	var distance_to_player = global_position.distance_to(target.global_position);
	
	if !is_triggered:
		is_moving = false;
		return
		
	if(distance_to_player < 20):
		is_attacking = true
		attack()
		return
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	is_moving = true
	
	velocity = direction * speed
	
	if is_attacking:
		velocity = Vector2(0,0)
	
func update_animation():
	var animation_name = "idle_" + Direction.keys()[direction].to_lower()
	
	if(is_moving):
		animation_name = "move_" + Direction.keys()[direction].to_lower()
		
	if(is_attacking):
		animation_name = "attack_" + Direction.keys()[direction].to_lower()

	$AnimatedSprite2D.play(animation_name)
	await $AnimatedSprite2D.animation_finished
	is_attacking = false

func update_fov() -> void:
	$FOV.rotation_degrees = get_fov_rotation()
	

func get_fov_rotation() -> int:
	var fov_rotation = 0; 
	
	if(direction == Direction.LEFT) :
		fov_rotation = 90
	if(direction == Direction.RIGHT) :
		fov_rotation = -90
	if(direction == Direction.UP) :
		fov_rotation = 180
		
	return fov_rotation
		
func attack():
	$MeleeHit/CollisionShape2D.disabled = false
	is_attacking = true
	$MeleeHit.global_rotation_degrees = (get_attack_rotation());
	await $AnimatedSprite2D.animation_finished
	$MeleeHit/CollisionShape2D.disabled = true

func get_attack_rotation() -> int:
	var attack_rotation = 0; 
	
	if(direction == Direction.LEFT) :
		attack_rotation = 90
	if(direction == Direction.RIGHT) :
		attack_rotation = -90
	if(direction == Direction.UP) :
		attack_rotation = 180
		
	return attack_rotation
		
func update_rotation():
	var angle = rad_to_deg((target.position - position).angle())
	
	if(angle > -45 && angle < 45):
		direction = Direction.RIGHT
		
	if(angle > 45 && angle < 135):
		direction = Direction.DOWN
		
	if(angle > -135 && angle < -45):
		direction = Direction.UP
		
	if(angle > 135 || angle < -135):
		direction = Direction.LEFT
		
func _on_melee_hit_area_entered(area: Area2D) -> void:
	if is_attacking && area.is_in_group("hitbox"):
		print("hit")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = true
		is_triggered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_sight = false

func _on_timer_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position
