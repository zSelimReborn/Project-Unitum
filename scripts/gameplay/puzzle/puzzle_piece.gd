class_name PuzzlePiece

extends StaticBody2D

signal on_solved()

var is_solved = false

func try_solve_piece(interactable):
	if not solve_piece(interactable):
		return false
	is_solved = true	
	on_solved.emit()
	return true
	
func solve_piece(_interactable):
	pass
