extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}

@export var speed = 125.0
var health = 10.0

var direction : Direction = Direction.DOWN
var is_moving = false;
var is_attacking = false;
var is_dead = health <= 0;

var input_direction

func get_input():
	if(is_attacking):
		velocity = Vector2(0, 0);
		return
		
	input_direction = Input.get_vector("left", "right", "up", "down")
	listen_for_attack()
	velocity = input_direction * speed
	is_moving = velocity.x != 0 || velocity.y != 0
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	change_direction(input_direction.x, input_direction.y)
	change_animation()

func change_animation():
	var animation_name = "idle_" + Direction.keys()[direction].to_lower()
	
	if(is_moving):
		animation_name = "move_" + Direction.keys()[direction].to_lower()
	
	if(is_attacking):
		animation_name = "attack_" + Direction.keys()[direction].to_lower()
	
	if(is_dead):
		animation_name = "death_" + Direction.keys()[direction].to_lower()
	
	$AnimatedSprite2D.play(animation_name)
	await $AnimatedSprite2D.animation_finished
	is_attacking = false
	
func listen_for_attack():
	if Input.is_action_just_released("click"):
		$AnimatedSprite2D/SwordHit/CollisionShape2D.disabled = false
		is_attacking = true
		attack()
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D/SwordHit/CollisionShape2D.disabled = true
		
func attack():
	$AnimatedSprite2D/SwordHit.global_rotation_degrees = (get_attack_rotation());

func get_attack_rotation() -> int:
	var attack_rotation = 0; 
	
	if(direction == Direction.LEFT) :
		attack_rotation = 90
	if(direction == Direction.RIGHT) :
		attack_rotation = -90
	if(direction == Direction.UP) :
		attack_rotation = 180
		
	return attack_rotation

func _on_sword_hit_area_entered(area: Area2D) -> void:
	if is_attacking && area.is_in_group("hitbox"):
		print("hit")
	
func change_direction(x : int, y : int):
	if x > 0:
		direction = Direction.RIGHT
	if x < 0:
		direction = Direction.LEFT
	if y > 0:
		direction = Direction.DOWN
	if y < 0:
		direction = Direction.UP


func damage_taken(amount):
	health -= amount
	if health < 0:
		health = 0
