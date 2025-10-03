extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var direction : Direction = Direction.DOWN
var target
var AnimatedSprite : AnimatedSprite2D

var armor_class = { # wird mit Damage multipliziert
	0: 1.0,
	1: 0.8,
	2: 0.5,
	3: 0.25,
	4: 0.1,
	5: 0.05
}

var health = 10
var max_health = 10
var is_dead = false
var armor = 0
var attack_cooldown_base = 1
var attack_cooldown_multiplier = 1
var knockback_base # wie stark das Knockback der Entität bei Attacke ist, nicht wie stark sie selbst zurückgestoßen wird
var knockback_multiplier = 1
var knockback_resistance = 0
var is_moving = false
var is_attacking = false
var attack_allowed = true #es gibt einen cooldown nach jedem Schlag
#var attack_cooldown = 5 # wird an %attack_cooldown.start() übergeben
var in_melee : Array = []
var melee_hitbox_node
var attack_cooldown_node
var in_collision_area : Array = []
var collide = false
#@onready var attack_cooldown_node = $attack_cooldown
var move_extra_input = Vector2(0,0)
var move_extra_buffer = Vector2(0,0)
var collision_shape_diameter = 20
var speed_base = 125
var speed_multiplier = 1

func init():
	target = get_tree().get_first_node_in_group("player")
	print("Target is: ", target)

func damage_taken(amount):
	health -= amount * armor_class[armor]
	if health <= 0 && is_dead == false:
		is_attacking = false
		is_dead = true
		health = 0
		update_animation()
	if health < 0: health = 0;

#TODO smooth machen
func knockback(amount:float, source:Vector2, knockback_target):
	var knockback_direction : Vector2 = Vector2((knockback_target.global_position.x - source.x), (knockback_target.global_position.y - source.y)).normalized()
	knockback_direction = knockback_direction * amount*(1-knockback_target.knockback_resistance)
	knockback_target.move_extra_input = knockback_direction

func move_extra():
	move_extra_buffer += move_extra_input
	move_extra_input = Vector2(0,0)
	var magnitude = move_extra_buffer.length()
	move_extra_buffer /= 1.05
	if -10 < magnitude && magnitude < 10 : 
		move_extra_buffer = Vector2(0,0)
	velocity += move_extra_buffer

func update_animation():
	if typeof(AnimatedSprite) == 0 || is_attacking == true: return #update_animation nicht ausführen, wenn es kein Objekt gibt, was das kann, denn sonst Fehler; wenn is_attacking true ist, wird Animation schon von attack() gehandelt
	var animation_name = "idle_" + Direction.keys()[direction].to_lower()
	if(is_moving):
		animation_name = "move_" + Direction.keys()[direction].to_lower()
	# Attacken Animation wird von attack() ausgeführt
	#if(is_attacking):
		#animation_name = "attack_" + Direction.keys()[direction].to_lower()
	if(is_dead):
		animation_name = "die_" + Direction.keys()[direction].to_lower()
	AnimatedSprite.play(animation_name)
	await AnimatedSprite.animation_finished

func direction_to_rotation() -> int:
	var angle = 0;
	if(direction == Direction.LEFT) :
		angle = 90
	if(direction == Direction.RIGHT) :
		angle = -90
	if(direction == Direction.UP) :
		angle = 180
	return angle
	
func rotation_to_direction(): 
	var angle = rad_to_deg((target.position - position).angle())
	if(angle > -45 && angle < 45):
		direction = Direction.RIGHT
	if(angle > 45 && angle < 135):
		direction = Direction.DOWN
	if(angle > -135 && angle < -45):
		direction = Direction.UP
	if(angle > 135 || angle < -135):
		direction = Direction.LEFT

func attack(damage: float, knockback_amount: float, attack_cooldown: float) -> void: 
	attack_allowed = false
	is_attacking = true
	
	var animation_name = "attack_" + Direction.keys()[direction].to_lower()
	if attack_cooldown_multiplier != 0: 
		AnimatedSprite.speed_scale = 1 / attack_cooldown_multiplier
	else:
		print("Haste muss > 0 sein")
	#print(str(AnimatedSprite.speed_scale) + "     " + str(attack_cooldown_multiplier)) #DEBUG
	AnimatedSprite.play(animation_name)
	for frame in range(4):
		await AnimatedSprite.frame_changed #Schaden schon in frame 4 austeilen
	#print(AnimatedSprite.frame)
	for i in in_melee:
		if typeof(i) == 24 && i != self: # wenn in_melee vom Typ object ist --> falls in_melee das objekt player ist, ist es insgesamt das selbe wie %player
			i.damage_taken(damage) #dem objekt, dass sich in melee hitbox aufhält, Schaden machen
			knockback(knockback_amount,position,i)
	await AnimatedSprite.animation_finished
	is_attacking = false
	attack_cooldown_node.start(attack_cooldown_base * attack_cooldown_multiplier) #für attack_cooldown sekunden warten

func no_clipping_collisionShape2D(object1 : CharacterBody2D, object2 : CharacterBody2D): #nur Kreise, hat collision shape der entities ersetzt
	var pos1 : Vector2 = object1.position
	var pos2 : Vector2 = object2.position
	var min_distance : float = 0.5*(object1.collision_shape_diameter + object2.collision_shape_diameter) + 1 #0.1 als kleine Lücke
	print(pos1.distance_to(pos2))
	if pos1.distance_to(pos2) < min_distance: 
		var difference : float = min_distance - pos1.distance_to(pos2)
		var shift : Vector2 = 0.5 * difference * (pos1 - pos2).normalized()
		object1.position += shift
		object2.position -= shift
		#print(str(Time.get_ticks_usec()) + ": Test    " + str(pos1.distance_to(pos2)))
