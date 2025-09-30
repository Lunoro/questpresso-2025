extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}

@export var speed = 125.0

var animations = {
	Direction.LEFT: {true: "idle_left", false: "move_left"},
	Direction.RIGHT: {true: "idle_right", false: "move_right"},
	Direction.UP: {true: "idle_up", false: "move_up"},
	Direction.DOWN: {true: "idle_down", false: "move_down"},
}

var direction = Direction.LEFT
var is_standing = true;

var input_direction

func get_input():
	input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	is_standing = velocity.x == 0 && velocity.y == 0

func _physics_process(delta):
	get_input()
	move_and_slide()
	change_direction(input_direction.x, input_direction.y)
	change_animation()
	
func change_direction(x : int, y : int):
	if x > 0:
		direction = Direction.RIGHT
	if x < 0:
		direction = Direction.LEFT
	if y > 0:
		direction = Direction.DOWN
	if y < 0:
		direction = Direction.UP
		
func change_animation():
	var animation_name = animations[direction][is_standing]
	$AnimatedSprite2D.play(animation_name)
