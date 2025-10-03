extends "res://Scripts/entities.gd"

# TODO: Bossfight -> Boss teleports infront of player
#			-> Brainstorm some attacks maybe spikes
#			-> Just get a working bossfight till tomorow
#			-> add attack to spawn 

@onready var player : CharacterBody2D = %player
@export var enemy_scene: PackedScene = preload("res://Entities/Enemy.tscn")

var player_position:Vector2

func _ready() -> void:
	health = 300
	armor = 5
	attack_cooldown_node = $attack_cooldown
	AnimatedSprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	position_check()
	player_position = player.global_position
	
	if(Input.is_action_just_pressed("Debug")):
		summon_enemy_attack()
	
func position_check():
	if (player_position.y < global_position.y):
		teleport()
	
func teleport():
	$AnimatedSprite2D.play("teleport")
	await $AnimatedSprite2D.animation_finished
	var new_pos : Vector2 = Vector2(player_position.x, player_position.y - 30)
	global_position = new_pos
	$AnimatedSprite2D.play_backwards("teleport")
	
func _on_timer_timeout() -> void:
	teleport()

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("idle")
	$Summon1.play("default")
	$Summon2.play("default")
	
func summon_enemy_attack():
	$AnimatedSprite2D.play("summon")
	$Summon1.play("summon")
	$Summon2.play("summon")
	spawn_enemy(Vector2(50, 0))
	spawn_enemy(Vector2(-50, 0))
	await $AnimatedSprite2D.animation_finished

func spawn_enemy(position_to_boss: Vector2):
	if enemy_scene:  # extra safety
		var enemy = enemy_scene.instantiate()
		enemy.position = position + Vector2(position_to_boss)
		get_tree().current_scene.add_child(enemy)
	else:
		push_error("Enemy scene not set!")
	
