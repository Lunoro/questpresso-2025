extends "res://Entities/entities.gd"

# TODO: Bossfight -> Boss teleports infront of player
#			-> Brainstorm some attacks maybe spikes
#			-> Just get a working bossfight till tomorow
#			-> add attack to spawn 
#			-> Phase: one and two
#				-> one: normal attacks and spawns
#				-> two: shuriken and spawns, sometimes normal attacks

@onready var player : CharacterBody2D = %player
@export var enemy_scene: PackedScene = preload("res://Entities/Enemy/Enemy.tscn")

var player_position:Vector2
func _ready() -> void:
	$Entrance.start()
	health = 50
	max_health = 50
	armor = 5
	attack_cooldown_node = $attack_cooldown
	AnimatedSprite = $AnimatedSprite2D
	collision_shape_diameter = 35
	
	await $AnimatedSprite2D.animation_finished
	fight()

func _physics_process(delta: float) -> void:
	if(is_dead):
		despawn()
		return

	position_check()
	player_position = player.global_position
	
	if collide: 
		for i in in_collision_area:
			no_clipping_collisionShape2D(i, self, true)
		
func spawn():
	$AnimatedSprite2D.play_backwards("teleport")
	
func despawn():
	$AnimatedSprite2D.play("teleport")
	
func position_check():
	if (player_position.y < global_position.y):
		teleport()
	
func teleport():
	$AnimatedSprite2D.play("teleport")
	await $AnimatedSprite2D.animation_finished
	var new_pos : Vector2 = Vector2(player_position.x, player_position.y - 30)
	global_position = new_pos
	$AnimatedSprite2D.play_backwards("teleport")
	
func fight() -> void:
	if ((health / max_health) < 0.5):
		attack_random(1, 2)
		return

	attack_random(0, 1)
	print("pre timeout")
	await $Attack_Timer.timeout
	print("timeout")
	$Attack_Timer.start()

func attack_random(x: int, y: int):
	match randi_range(x, y):
		0: attack(0, 0, 0)
		1: summon_enemy_attack()
		2: shuriken_circle_attack()
	
# override because of unique moveset
func attack(damage: float, knockback_amount: float, attack_cooldown: float) -> void:
	await teleport();
	
	var random = randi_range(0, 1)
	var direction_of_anim: Dictionary[int, String] = {
		0: "left",
		1: "right"
	}
	
	var animation_name = "attack_" + direction_of_anim[random]
	$AnimatedSprite2D.play(animation_name)
	
	for frame in range(4):
		await $AnimatedSprite2D.frame_changed
	for i in $Attack_Range.get_overlapping_areas():
		if(i.get_parent().name == player.name && i.is_in_group("hitbox") && !is_dead):
			player.damage_taken(damage) #dem objekt, dass sich in melee hitbox aufhält, Schaden machen
			knockback(knockback_amount * knockback_multiplier,position,player)
				
	await AnimatedSprite.animation_finished
	$Attack_Timer.set_wait_time(2)
	
func summon_enemy_attack():
	$AnimatedSprite2D.play("summon")
	$Summon1.play("summon")
	$Summon2.play("summon")
	spawn_enemy(Vector2(50, 0))
	spawn_enemy(Vector2(-50, 0))
	await $AnimatedSprite2D.animation_finished
	$Attack_Timer.set_wait_time(15)
	
func spawn_enemy(position_to_boss: Vector2):
	if enemy_scene:
		var enemy = enemy_scene.instantiate()
		enemy.position = position + Vector2(position_to_boss)
		get_tree().current_scene.add_child(enemy)
	else:
		push_error("Enemy scene not set!")
		
func shuriken_circle_attack():
	var num_shuriken = 10
	var radius = 30
	
	for i in num_shuriken:
		var angle = (TAU / num_shuriken + randi_range(0, 20)) * i
		var shuriken = preload("res://Entities/Boss/shuriken.tscn").instantiate()
		
		shuriken.global_position = global_position + Vector2(cos(angle), sin(angle)) * radius
		shuriken.direction = Vector2(cos(angle), sin(angle)).normalized()
		shuriken.speed = 100
		
		get_tree().current_scene.add_child(shuriken)
	$Attack_Timer.set_wait_time(2)
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if(is_dead):
		queue_free()
		return
	$AnimatedSprite2D.play("idle")
	$Summon1.play("default")
	$Summon2.play("default")
	
func _on_attack_timer_timeout() -> void:
	print("attack")
	fight()
	
func _on_entrance_timeout() -> void:
	spawn()

func _on_boss_marker_area_entered(area: Area2D) -> void:
	if  (area.name.contains("enemy_marker") || area.name.contains("player_marker") ) && in_collision_area.find(area.get_parent()) == -1: # && area.get_parent().name == "enemy":
		#print("Nun ist es also soweit..." + str(area.get_parent()) + "    sagte: " + str(self))
		in_collision_area.append(area.get_parent())
		#no_clipping_collisionShape2D(area.get_parent(), self )
		collide = true

func _on_boss_marker_area_exited(area: Area2D) -> void:
	if (area.name.contains("enemy_marker") || area.name.contains("player_marker") ) && in_collision_area.find(area.get_parent()) != -1:
		in_collision_area.erase(area.get_parent())
	if in_collision_area.is_empty(): 
		collide = false
