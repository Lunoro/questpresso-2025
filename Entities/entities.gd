extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}
var direction : Direction = Direction.DOWN
@onready var target = %player
var armor_class = { # wird mit Damage multipliziert
	0: 1.0,
	1: 0.8,
	2: 0.5,
	3: 0.25,
	4: 0.1,
	5: 0.05
}
var health = 10
var is_dead = false
var armor = 0
var knockback_resistance = 0
var is_moving = false
var is_attacking = false
var attack_allowed = true #es gibt einen cooldown nach jedem Schlag
var attack_cooldown = 5 # wird an %attack_cooldown.start() übergeben
var in_melee 
@onready var attack_cooldown_node #= $attack_cooldown

func damage_taken(amount):
	health -= amount * armor_class[armor]
	if health <= 0 && is_dead == false:
		is_dead = true
		health = 0
		update_animation()
	if health < 0: health = 0;

#TODO smooth machen
func knockback(amount:float, source:Vector2, knockback_target):
	var direction : Vector2 = Vector2((knockback_target.global_position.x - source.x), (knockback_target.global_position.y - source.y)).normalized()
	direction *= amount*(1-knockback_target.knockback_resistance)
	knockback_target.move_local_x(direction.x)
	knockback_target.move_local_y(direction.y)

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

func attack() -> void: 
	attack_allowed = false
	is_attacking = true
	update_animation()
	await $AnimatedSprite2D.animation_finished
	if typeof(in_melee) == 24: # wenn in_melee vom Typ object ist --> falls in_melee das objekt player ist, ist es insgesamt das selbe wie %player
		in_melee.damage_taken(5) #dem objekt, dass sich in melee hitbox aufhält, Schaden machen
		knockback(30,position,in_melee)
	is_attacking = false
	attack_cooldown_node.start(-(attack_cooldown)) #für attack_cooldown sekunden warten
