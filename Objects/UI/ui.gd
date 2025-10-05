extends CanvasLayer


@export var player: CharacterBody2D
var text : String

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	text += "Health: " + str(round(player.health))
	if player.regeneration > 0: text += "\nregeneration : " + player.regeneration
	if player.armor_bonus > 0: text += "\nextra armor: " + player.armor_bonus
	if player.attack_cooldown_multiplier < 1: text += "\nhaste"
	if player.attack_cooldown_multiplier > 1: text += "\nattack slowness"	
	if player.knockback_multiplier > 1: text += "\nstronger knockback"
	if player.knockback_resistance_multiplier > 1: text += "\nknockback resistance"
	if player.speed_multiplier > 1: text += "\nspeed"
	$Label.text = text.to_upper()
	text = ""
