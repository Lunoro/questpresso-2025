extends CanvasLayer


@export var player: Node

func _process(delta: float) -> void:
	$Label.text = "Health: " + str(player.get_parent().health)
