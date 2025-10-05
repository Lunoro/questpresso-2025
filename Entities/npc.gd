extends "res://Scripts/entities.gd"

@export var player : CharacterBody2D
var in_interaction = false

func interact():
	if(in_interaction):
		close_interaction()
		return
	
	$RichTextLabel.visible = true
	in_interaction = true
	
func close_interaction():
	$RichTextLabel.visible = false
	in_interaction = false
	
#https://www.youtube.com/watch?v=QEHOiORnXIk -> Better Style
