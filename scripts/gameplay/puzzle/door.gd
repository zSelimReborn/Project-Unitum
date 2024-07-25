class_name Door

extends BaseInteractable

# Properties
@export var spawn_point : Node2D

# On Ready
@onready var puzzle_listener_component = $PuzzleListenerComponent
@onready var sprite = $Sprite

func _ready():
	instant_interact = false
	if not puzzle_listener_component:
		printerr("door has no puzzle listener attached")
		on_solved()
		return
	puzzle_listener_component.on_puzzle_solved.connect(on_solved)
	
func on_solved():
	if not sprite:
		return
	sprite.play("opened")
	
func interact(player: Player):
	if not player:
		return false
	if not puzzle_listener_component:
		teleport(player)
		return true
	if puzzle_listener_component.is_puzzle_solved():
		teleport(player)
		return true
	return false
	
func teleport(player):
	if not spawn_point:
		printerr("door unable to teleport: ", get_name())
		return
	if not player:
		printerr("door unable to teleport, no player")
		return
	player.transform = spawn_point.transform
