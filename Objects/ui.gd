extends CanvasLayer


@export var player: CharacterBody2D

func _process(delta: float) -> void:
	$Label.text = "Health: " + str(player.health)
