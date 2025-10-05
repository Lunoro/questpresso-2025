extends CanvasLayer


@export var player: CharacterBody2D
var text : String

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	text += "Health: " + str(round(player.health))
	if player.regeneration > 0: text += "\nregeneration : " + str(player.regeneration)
	if player.armor_bonus > 0: text += "\nextra armor: " + str(player.armor_bonus)
	if player.attack_cooldown_multiplier < 1: text += "\nhaste" + str(round(1 / player.attack_cooldown_multiplier))
	if player.attack_cooldown_multiplier > 1: text += "\nattack slowness" + str(round(1 / player.attack_cooldown_multiplier))
	if player.knockback_multiplier != 1: text += "\nstronger knockback" + str(player.knockback_multiplier)
	if player.knockback_resistance_multiplier != 1: text += "\nknockback resistance"+ str(player.knockback_resistance_multiplier)
	if player.speed_multiplier > 1: text += "\nspeed" + str(player.speed_multiplier)
	if player.speed_multiplier < 1: text += "\nslowness" + str(player.speed_multiplier)
	$Label.text = text.to_upper()
	text = ""
