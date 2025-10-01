extends CharacterBody2D

@export var player : CharacterBody2D
var in_interaction = false

func interact():
	$RichTextLabel.visible = true
	var in_interaction = true
	
func close_interaction():
	$RichTextLabel.visible = false
	var in_interaction = false
	
#https://www.youtube.com/watch?v=QEHOiORnXIk -> Better Style
