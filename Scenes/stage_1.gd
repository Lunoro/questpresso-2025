extends Node2D
@onready var lib = preload("res://Scripts/game_manager.gd").new()
enum Direction {LEFT, RIGHT, UP, DOWN}
#@onready var player = get_tree().get_first_node_in_group("player")

var enemies = [
	[Vector2(1336,-315), Direction.DOWN, "standard",[["health", 20]] ]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = %player
	print_tree()
	await get_tree().create_timer(1).timeout
	for e in enemies: 
		lib.spawn_enemy(e[0], e[1], e[2], e[3])#, player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
