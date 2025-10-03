extends "res://Scripts/entities.gd"


@onready var vision_area = $FOV
@onready var navigation_agent = $NavigationAgent2D
@export var speed : int = 50;

var is_triggered = false
var in_sight = false
var is_fighting

func _ready() -> void:
	init()
	health = 10
	armor = 3
	attack_cooldown_node = $attack_cooldown #setzt Timer node
	AnimatedSprite = $AnimatedSprite2D
	max_health = 10
	#attack_cooldown = 5
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
	if not is_attacking: update_animation()
	update_fov()
	find_path()
	move_extra()
	move_and_slide()


func _on_update_path_timeout() -> void:
	if navigation_agent.target_position != target.global_position:
		navigation_agent.target_position = target.global_position

func find_path(): #und start attack
	is_moving = true
	var distance_to_player = global_position.distance_to(target.global_position);
	
	if !is_triggered:
		is_moving = false;
		velocity = Vector2(0,0)
		return
		
	if distance_to_player < 20:
		if  target.is_dead == false && attack_allowed == true: 
			attack(5, 50, 3)
		velocity = Vector2(0,0)
		is_moving = false
		return
		
	if is_fighting: 
		pass #in anderen Pathfinding Algorithmus übergehen -> dodgen, umkreisen, verstecken...
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	velocity = direction * speed

# fight block start
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown_node.stop()
	attack_allowed = true
	print("cooldown vorbei Enemy")

func _on_melee_hit_body_entered(body: Node2D) -> void: #TODO für mehrere Objekte in Hitbox gleichzeitig umgestalten
	in_melee = body

func _on_melee_hit_body_exited(body: Node2D) -> void:
	in_melee = false
#fight block end

func update_fov() -> void:
	$MeleeHit.global_rotation_degrees = (direction_to_rotation()); #Attack hitbox wird ausgerichtet
	if(is_triggered):
		rotation_to_direction()
		$FOV.rotation_degrees = direction_to_rotation()
		$RayCast2D.rotation_degrees = direction_to_rotation()

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


func _on_node_2d_ready() -> void:
	pass # Replace with function body.
