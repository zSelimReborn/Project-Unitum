class_name PuzzleListenerComponent

extends Node

signal on_puzzle_solved

@export var pieces: Array[Node2D]

var valid_pieces = 0
var solved_pieces = 0
var is_solved = false

func _ready():
	prepare()

func is_puzzle_solved():
	return is_solved

func on_solved_piece():
	solved_pieces += 1
	if solved_pieces >= valid_pieces:
		is_solved = true
		on_puzzle_solved.emit()

func prepare():
	if not pieces or pieces.is_empty():
		return
	for piece in pieces:
		if not piece:
			continue
		var puzzle_piece = piece as PuzzlePiece
		if not puzzle_piece:
			printerr("unable to find puzzle piece on: ", piece.get_name())
			continue
		puzzle_piece.on_solved.connect(on_solved_piece)
		valid_pieces += 1
