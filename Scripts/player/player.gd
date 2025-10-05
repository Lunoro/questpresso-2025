extends "res://Scripts/entities.gd"

var is_interacting = false
var input_direction
var dodge_allowed = true
var dodge = 1
var dodge_cooldown = 5

func _ready() -> void:
	speed_base = 125
	max_health = 20
	health = 20
	armor = 1
	attack_cooldown_node = $attack_cooldown #setzt Timer node, bei enemy und player grad gleich benannt, bei Problemen umbenennen
	attack_cooldown_base = 1
	knockback_base = 100
	AnimatedSprite = $AnimatedSprite2D
	#attack_cooldown = 5
	#target = %player
	#is_dead = false
	#knockback_resistance = 0
	#is_moving = false
	#direction = Direction.DOWN
	#is_attacking = false
	#attack_allowed = true
	#in_melee
	collision_shape_diameter = 14

func get_input():
	if(is_attacking):
		velocity = Vector2(0, 0);
		return
	input_direction = Input.get_vector("left", "right", "up", "down")
	listen_for_attack()
	velocity = input_direction * speed_multiplier * speed_base * dodge
	is_moving = velocity.x != 0 || velocity.y != 0
	
func _physics_process(delta):
	if is_dead: 
		return
	if (!is_interacting):
		regenerate(regeneration)
		get_input()
		move_extra()
		listen_for_dodge()
		move_and_slide()
		change_direction(input_direction.x, input_direction.y)
		update_area_rotation()
		if not is_attacking: update_animation()
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
	if ( Input.is_action_just_released("click") || Input.is_key_pressed(KEY_J) ) && attack_allowed == true:
		attack(5.0, knockback_base * knockback_multiplier, attack_cooldown_base * attack_cooldown_multiplier)

func listen_for_dodge(): 
	if Input.is_action_just_pressed("ui_accept") && dodge_allowed == true:
		dodge_allowed = false
		$dodge_cooldown.start(dodge_cooldown)
		print("dodge!")
		dodge = 2.5
	if dodge > 1: 
		dodge -= 2.5 * get_process_delta_time()
		if dodge < 1.05: 
			dodge = 1

func update_area_rotation():
	$AnimatedSprite2D/SwordHit.global_rotation_degrees = (direction_to_rotation());
	$Interacting.global_rotation_degrees = (direction_to_rotation());

func _on_attack_cooldown_timeout() -> void:
	#attack_cooldown_node.stop()
	attack_allowed = true

func _on_melee_hit_area_entered(area: Node2D) -> void: #TODO für mehrere Objekte in Hitbox gleichzeitig umgestalten
	if area.name.contains("marker") && in_melee.find(area.get_parent()) == -1:
		in_melee.append(area.get_parent())
	#print(str(in_melee) + " in       " + area.name)

func _on_melee_hit_area_exited(area: Node2D) -> void:
	if area.name.contains("marker") && in_melee.find(area.get_parent()) != -1:
		in_melee.erase(area.get_parent())
	#print(str(in_melee) + " out       " + area.name)

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


func _on_dodge_cooldown_timeout() -> void:
	dodge_allowed = true
