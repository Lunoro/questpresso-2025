extends Camera2D

@onready var player: CharacterBody2D = %Player

func _process(delta: float) -> void:
	$Label.text = "Health: " + str(player.health)
	
