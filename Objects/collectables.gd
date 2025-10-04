extends Node2D

var distance_to_player : float = -1
@onready var player = $"../player"

var type : String
var parameter
var posy
var offset

func _ready() -> void:
	scale *= 2
	var x = Time.get_ticks_usec()
	while x < Time.get_ticks_usec() - 1:
		pass

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
			
		if type == "armor": 
			player.armor_bonus = parameter[0]
			$Timer_Armor.start(parameter[1])
			$AnimatedSprite2D.hide()
			
		if type == "knockback": 
			player.knockback_multiplier = parameter[0]
			$Timer_Knockback.start(parameter[1])
			$AnimatedSprite2D.hide()
			
		if type == "knockback_resistance": 
			player.knockback_resistance_multiplier = parameter[0]
			$Timer_Knockback_Resistance.start(parameter[1])
			$AnimatedSprite2D.hide()
			
		if type == "regeneration": 
			player.regeneration = parameter[0]
			$Timer_Regeneration.start(parameter[1])
			$AnimatedSprite2D.hide()
		
			
	if type == "heal": 
		#$AnimatedSprite2D.play("heal")
		if parameter == -1: 
			$AnimatedSprite2D.animation = "heal_small"
		else: 
			$AnimatedSprite2D.animation = "heal_full"
	if type == "speed": 
		$AnimatedSprite2D.animation = "speed"
		#$AnimatedSprite2D.play("speed")
	if type == "haste": 
		$AnimatedSprite2D.animation = "haste"
	if type == "knockback": 
		$AnimatedSprite2D.animation = "knockback"
	if type == "knockback_resistance": 
		$AnimatedSprite2D.animation = "knockback_resistance"
	if type == "armor": 
		$AnimatedSprite2D.animation = "armor"
	if type == "regeneration": 
		$AnimatedSprite2D.animation = "regeneration"

	position.y = posy + 2.5*sin((Time.get_ticks_usec()) * 0.000003 * (offset + 0.5) + offset)
	


func _on_timer_speed_timeout() -> void:
	player.speed_multiplier = 1
	print("timeout_speeds")
	queue_free()

func _on_timer_haste_timeout() -> void:
	player.attack_cooldown_multiplier = 1
	print("timeout_haste")
	queue_free()


func _on_timer_regeneration_timeout() -> void:
	player.regeneration = 0
	player.health = ceil(player.health)
	print("timeout_regen")
	queue_free()

func _on_timer_armor_timeout() -> void:
	player.armor_bonus = 0
	print("timeout_armor")
	queue_free()

func _on_timer_knockback_timeout() -> void:
	player.knockback_multiplier = 1
	print("timeout_knockback")
	queue_free()

func _on_timer_knockback_resistance_timeout() -> void:
	player.knockback_resistance_multiplier = 1
	print("timeout_knockback_res")
	queue_free()
