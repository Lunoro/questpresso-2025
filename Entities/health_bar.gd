extends MeshInstance2D
var start_scale = scale.x
var start_pos = position.x
@onready var parent =  $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var max_health = parent.max_health
	var health = parent.health
	scale.x = start_scale * (health / max_health)
	position.x = start_pos - 0.5 * (start_scale - scale.x)
