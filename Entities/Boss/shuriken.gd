extends Area2D

@export var speed: float = 200
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	print("start timer")
	$Timer.start()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
func _on_timer_timeout() -> void:
	queue_free()
	print("freed shuriken")
	$Timer.stop()


func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("hitbox") && area.owner.name == "player"):
		var player = area.owner
		player.damage_taken(10)
