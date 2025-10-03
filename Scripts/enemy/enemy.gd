extends "res://Scripts/entities.gd"


@onready var vision_area = $FOV
@onready var navigation_agent = $NavigationAgent2D

var is_triggered = false
var in_sight = false
var is_fighting

func _ready() -> void:
	init()
	speed_base = 50
	health = 10
	armor = 3
	attack_cooldown_node = $attack_cooldown #setzt Timer node
	attack_cooldown_base = 2
	knockback_base = 200
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
	collision_shape_diameter = 20

func _physics_process(delta: float) -> void:
	if(is_dead): return
	update_animation()
	update_fov()
	find_path()
	move_extra()
	if global_position.distance_to(target.global_position) < 40: # if Abfrage nur um Rechenleistung zu sparen -> geht nur wenn, die Collisionshapes es überhaupt zu lassen, dass entities sich sonahe kommen
		no_clipping_collisionShape2D(target, self)
	if collide: 
		for i in in_collision_area:
			no_clipping_collisionShape2D(i, self )
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
			attack(5, knockback_base * knockback_multiplier, attack_cooldown_base * attack_cooldown_multiplier)
		velocity = Vector2(0,0)
		is_moving = false
		return

	if is_fighting: 
		pass #in anderen Pathfinding Algorithmus übergehen -> dodgen, umkreisen, verstecken...
	
	var next_position = navigation_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()
	
	velocity = direction * speed_base * speed_multiplier

# fight block start
func _on_attack_cooldown_timeout() -> void:
	attack_cooldown_node.stop()
	attack_allowed = true

func _on_melee_hit_area_entered(area: Node2D) -> void: #TODO für mehrere Objekte in Hitbox gleichzeitig umgestalten
	if area.name.contains("player_marker") && in_melee.find(area.get_parent()) == -1:
		in_melee.append(area.get_parent())
	#print(str(in_melee) + " in       " + area.name)

func _on_melee_hit_area_exited(area: Node2D) -> void:
	if area.name.contains("player_marker") && in_melee.find(area.get_parent()) != -1:
		in_melee.erase(area.get_parent())
	#print(str(in_melee) + " out       " + area.name)

#fight block end

func update_fov() -> void:
	$MeleeHit.global_rotation_degrees = (direction_to_rotation()); #Attack hitbox wird ausgerichtet
	if(is_triggered):
		rotation_to_direction()
		$FOV.rotation_degrees = direction_to_rotation()
		$RayCast2D.rotation_degrees = direction_to_rotation()

func _on_area_2d_body_entered(area: Node2D) -> void:
	#print("entered")
	if area.name.contains("marker") && area.get_parent().name == "player":
		in_sight = true
		is_triggered = true
	#print("in fov: " + area.name)

func _on_area_2d_body_exited(area: Node2D) -> void:
	#print("left")
	if area.name.contains("marker") && area.get_parent().name == "player":
		in_sight = false
		$Update_Aggro.start(-1)
	#print("out fov: " + area.name)

func _on_update_aggro_timeout() -> void:
	if(in_sight): return
	#print("triggered")
	is_triggered = false
	$Update_Aggro.stop()


func _on_enemy_marker_area_entered(area: Area2D) -> void:
	if area.name.contains("enemy_marker") && in_collision_area.find(area.get_parent()) == -1: # && area.get_parent().name == "enemy":
		print("Nun ist es also soweit..." + str(area.get_parent()) + "    sagte: " + str(self))
		in_collision_area.append(area.get_parent())
		#no_clipping_collisionShape2D(area.get_parent(), self )
		collide = true


func _on_enemy_marker_area_exited(area: Area2D) -> void:
	if area.name.contains("enemy_marker") && in_collision_area.find(area.get_parent()) != -1:
		in_collision_area.erase(area.get_parent())
	if in_collision_area.is_empty(): 
		collide = false
