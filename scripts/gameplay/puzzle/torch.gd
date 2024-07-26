class_name Torch

extends Node2D

@onready var sprite = $Sprite
@onready var puzzle_listener_component = $PuzzleListenerComponent

# Called when the node enters the scene tree for the first time.
func _ready():
	if not puzzle_listener_component:
		printerr("torch has no puzzle listener attached")
		on_solved()
		return
	puzzle_listener_component.on_puzzle_solved.connect(on_solved)
	
func on_solved():
	sprite.play("fire")
