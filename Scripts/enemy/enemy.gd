extends "res://Entities/entities.gd"


@onready var vision_area = $FOV
@onready var navigation_agent = $NavigationAgent2D
@export var speed : int = 50;

var is_triggered = false
var in_sight = false
var is_fighting

func _ready() -> void:
	health = 10
	armor = 3
	attack_cooldown_node = $attack_cooldown #setzt Timer node
	attack_cooldown = 5
	#target = %player
	#is_dead = false
	#knockback_resistance = 0
	#is_moving = false
	#direction = Direction.DOWN
	#is_attacking = false
	#attack_allowed = true
	#in_melee

func _physics_process(delta: float) -> void:
	if(is_dead): return
	update_animation()
	update_fov()
	find_path()
	move_and_slide()


func _on_update_path_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position

func find_path(): #und start attack
	var distance_to_player = global_position.distance_to(target.global_position);
	if !is_triggered:
		is_moving = false;
		velocity = Vector2(0,0)
		return
		
	if distance_to_player < 20:
		if  %player.is_dead == false && attack_allowed == true: 
			attack()
		velocity = Vector2(0,0)
		return
	
	if is_fighting: 
		pass #in anderen Pathfinding Algorithmus übergehen -> dodgen, umkreisen, verstecken...
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	is_moving = true
	
	velocity = direction * speed

func update_fov() -> void:
	$MeleeHit.global_rotation_degrees = (direction_to_rotation()); #Attack hitbox wird ausgerichtet
	if(is_triggered):
		rotation_to_direction()
		$FOV.rotation_degrees = direction_to_rotation()
		$RayCast2D.rotation_degrees = direction_to_rotation()

#func attack() -> void: 
	#attack_allowed = false
	#is_attacking = true
	#update_animation()
	#await $AnimatedSprite2D.animation_finished
	#if typeof(in_melee) == 24: # wenn in_melee vom Typ object ist --> falls in_melee das objekt player ist, ist es insgesamt das selbe wie %player
		#in_melee.damage_taken(5) #dem objekt, dass sich in melee hitbox aufhält, Schaden machen
		#knockback(30,position,in_melee)
	#is_attacking = false
	#$attack_cooldown.start(-(attack_cooldown)) #für attack_cooldown sekunden warten
	
func _on_attack_cooldown_timeout() -> void:
	attack_allowed = true
	print("cooldown vorbei")

func _on_melee_hit_body_entered(body: Node2D) -> void: #TODO für mehrere Objekte in Hitbox gleichzeitig umgestalten
	in_melee = body
	#print(typeof(in_melee)) ist 24

func _on_melee_hit_body_exited(body: Node2D) -> void:
	in_melee = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entered")
	if body.name == "player":
		in_sight = true
		is_triggered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("left")
	if body.name == "player":
		in_sight = false
		$Update_Aggro.start(-1)

func _on_update_aggro_timeout() -> void:
	if(in_sight): return
	print("triggered")
	is_triggered = false
	$Update_Aggro.stop()
