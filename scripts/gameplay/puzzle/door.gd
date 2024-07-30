class_name Door

extends BaseInteractable

# Properties
@export var is_fake : bool = false
@export var is_next_level : bool = false
@export var next_level_path : PackedScene
@export var spawn_point : Node2D
@export var opening_sound : AudioStream

# On Ready
@onready var sprite = $Sprite
@onready var audio = $Audio

# Variables
var puzzle_listener_component = null

func _ready():
	is_interactable = not is_fake
	if is_fake:
		return
	super()
	instant_interact = false
	puzzle_listener_component = $PuzzleListenerComponent
	if not puzzle_listener_component:
		printerr("door has no puzzle listener attached")
		on_solved()
		return
	puzzle_listener_component.on_puzzle_solved.connect(on_solved)
	
func on_solved():
	if not sprite:
		return
	if audio:
		audio.stream = opening_sound
		audio.play()
	sprite.play("opened")
	
func interact(player: Player):
	if not is_interactable:
		return false
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
	if is_next_level:
		go_new_level()
	else:
		go_new_room(player)

func go_new_room(player: Player):
	if not spawn_point:
		printerr("door unable to teleport: ", get_name())
		return false
	if not player:
		printerr("door unable to teleport, no player")
		return false
	player.transform = spawn_point.transform

func go_new_level():
	if not next_level_path:
		printerr("door unable to load next level, empty path")
		return false
	SceneManager.goto_scene(next_level_path.resource_path)
