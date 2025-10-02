extends "res://Entities/entities.gd"

@export var speed = 125.0
@export var damage = 1

var is_interacting = false
var input_direction

func _ready() -> void:
	health = 10
	armor = 3
	attack_cooldown_node = $attack_cooldown #setzt Timer node, bei enemy und player grad gleich benannt, bei Problemen umbenennen
	attack_cooldown = 5
	#target = %player
	#is_dead = false
	#knockback_resistance = 0
	#is_moving = false
	#direction = Direction.DOWN
	#is_attacking = false
	#attack_allowed = true
	#in_melee

func get_input():
	if(is_attacking):
		velocity = Vector2(0, 0);
		return;
	input_direction = Input.get_vector("left", "right", "up", "down")
	listen_for_attack()
	velocity = input_direction * speed
	is_moving = velocity.x != 0 || velocity.y != 0
	
func _physics_process(delta):
	if is_dead: 
		return
	if (!is_interacting):
		get_input()
		move_and_slide()
		change_direction(input_direction.x, input_direction.y)
		update_area_rotation()
		update_animation()
		listen_for_interact()

func change_direction(x : int, y : int):
	if x > 0:
		direction = Direction.RIGHT
	if x < 0:
		direction = Direction.LEFT
	if y > 0:
		direction = Direction.DOWN
	if y < 0:
		direction = Direction.UP

# fight block

func listen_for_attack():
	if Input.is_action_just_released("click") && attack_allowed == true:
		attack()
		#$AnimatedSprite2D/SwordHit/CollisionShape2D.disabled = false
		#is_attacking = true
		#await $AnimatedSprite2D.animation_finished
		#$AnimatedSprite2D/SwordHit/CollisionShape2D.disabled = true

func update_area_rotation():
	$AnimatedSprite2D/SwordHit.global_rotation_degrees = (direction_to_rotation());
	$Interacting.global_rotation_degrees = (direction_to_rotation());

#func _on_sword_hit_area_entered(area: Area2D) -> void:
	#if is_attacking && area.is_in_group("hitbox") && area.get_parent().name != name:
		#area.get_parent().damage_taken(5);
		#print(area.get_parent().name)

func _on_attack_cooldown_timeout() -> void:
	attack_allowed = true
	print("cooldown vorbei player")

func _on_melee_hit_body_entered(body: Node2D) -> void: #TODO für mehrere Objekte in Hitbox gleichzeitig umgestalten
	in_melee = body

func _on_melee_hit_body_exited(body: Node2D) -> void:
	in_melee = false

# Interaction Block

#TODO do interaction handshake with interacting object and freeze player. If the player presses e the next text rolls in, if the interaction is finished unfreeze the player

func listen_for_interact():
	if Input.is_action_just_released("interact"):

		$Interacting/CollisionShape2D.disabled = false

		for area : Area2D in $Interacting.get_overlapping_areas():
			if(!area.is_in_group("interact")):
				$Interacting/CollisionShape2D.disabled = true
				return
		
		is_interacting = true
	
func _on_interacting_area_entered(area: Area2D) -> void:
	if (area.is_in_group("interact") && is_interacting):
		print("interacting")
		area.get_parent().interact()
	$Interacting/CollisionShape2D.disabled = true
