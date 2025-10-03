extends Node2D

var distance_to_player : float = -1
@onready var player = $"../../player"

var type : String
var parameter

func _ready() -> void:
	scale *= 2

#TODO custom textures and/or animations for different potion types
func _process(delta: float) -> void:
	distance_to_player = (player.position - position).length()
	if distance_to_player < 20: 
		if type == "heal": 
			if parameter == -1 || player.health + parameter >= player.max_health: 
				player.health = player.max_health
			else: 
				player.health += parameter
			queue_free()
			
		if type == "speed": 
			player.speed_multiplier = parameter[0]
			$Timer_Speed.start(parameter[1])
			$AnimatedSprite2D.hide()
			
		if type == "haste": 
			player.attack_cooldown_multiplier = parameter[0]
			$Timer_Haste.start(parameter[1])
			$AnimatedSprite2D.hide()
			
	if type == "heal": 
		$AnimatedSprite2D.play("heal")
	if type == "speed": 
		$AnimatedSprite2D.play("speed")
	if type == "haste": 
		$AnimatedSprite2D.play("speed")
	


func _on_timer_speed_timeout() -> void:
	player.speed_multiplier = 1
	print("timeout_speeds")
	queue_free()

func _on_timer_haste_timeout() -> void:
	player.attack_cooldown_multiplier = 1
	print("timeout_haste")
	queue_free()
