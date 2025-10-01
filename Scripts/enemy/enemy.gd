extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var direction = Direction.DOWN

@onready var vision_area = $FOV
@onready var navigation_agent = $NavigationAgent2D
@export var target : CharacterBody2D
@export var speed : int = 50;

var is_triggered = false
var in_sight = false
var in_melee = false

var is_attacking = false
var is_moving = false
var is_dead = false

var armor = 3
var health = 10.0
var armor_class = {
	0: 1.0,
	1: 0.8,
	2: 0.5,
	3: 0.25,
	4: 0.1,
	5: 0.05
}

func damage_taken(amount):
	health -= amount * armor_class[armor]
	if health <= 0 && is_dead == false:
		is_dead = true
		health = 0
		update_animation()
	if health < 0: 
		health = 0

func _physics_process(delta: float) -> void:
	if(is_dead): return
	update_animation()
	update_fov()
	find_path()
	move_and_slide()
	
func find_path():
	var distance_to_player = global_position.distance_to(target.global_position);
	
	if !is_triggered:
		is_moving = false;
		velocity = Vector2(0,0)
		return
		
	if distance_to_player < 20:
		attack()
		velocity = Vector2(0,0)
		return
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	is_moving = true
	
	velocity = direction * speed
	
func update_animation():
	var animation_name = "idle_" + Direction.keys()[direction].to_lower()
	
	if(is_moving):
		animation_name = "move_" + Direction.keys()[direction].to_lower()
		
	if(is_attacking):
		animation_name = "attack_" + Direction.keys()[direction].to_lower()
		
	if(is_dead):
		animation_name = "die_" + Direction.keys()[direction].to_lower()

	$AnimatedSprite2D.play(animation_name)
	await $AnimatedSprite2D.animation_finished
	is_attacking = false

func update_fov() -> void:
	$MeleeHit.global_rotation_degrees = (get_attack_rotation()); #Attack hitbox wird ausgerichtet
	if(is_triggered):
		update_rotation()
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

func attack() -> void: 
	is_attacking = true
	update_animation()
	await $AnimatedSprite2D.animation_finished
	if in_melee == "Player": 
		%Player.damage_taken(5)
	is_attacking = false

func _on_melee_hit_area_entered(area: Area2D) -> void:
	in_melee = "Player"

func _on_melee_hit_area_exited(area: Area2D) -> void:
	in_melee = "false"

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entered")
	if body.name == "Player":
		in_sight = true
		is_triggered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("left")
	if body.name == "Player":
		in_sight = false
		$Update_Aggro.start(-1)

func _on_update_path_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position

func _on_update_aggro_timeout() -> void:
	if(in_sight): return
	print("triggered")
	is_triggered = false
	$Update_Aggro.stop()
