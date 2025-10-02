extends CharacterBody2D

# TODO: Bossfight -> Boss teleports infront of player
#			-> Brainstorm some attacks maybe spikes
#			-> Just get a working bossfight till tomorow

@onready var target : CharacterBody2D= %player

var player_position:Vector2

func _physics_process(delta: float) -> void:
	player_position = target.global_position
	
func teleport():
	$AnimatedSprite2D.play("teleport")
	await $AnimatedSprite2D.animation_finished
	var new_pos : Vector2 = Vector2(player_position.x, player_position.y - 30)
	global_position = new_pos
	$AnimatedSprite2D.play_backwards("teleport")
	

func _on_timer_timeout() -> void:
	teleport()
