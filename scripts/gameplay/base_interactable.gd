class_name BaseInteractable

extends Area2D

# Interact on player enter
@export var instant_interact : bool = false
@export var interaction_text : String = "Interact"
@export var interaction_hint : String

# Variables
var is_interactable : bool = true

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	add_to_group("interactable")

func interact(_player: Player):
	return true

func on_overlap_start(player: Player):
	if player == null:
		return
	player.set_interactable(self)

func on_overlap_leave(player: Player):
	if player == null:
		return
	player.set_interactable(null)

func _on_body_entered(body):
	var player := body as Player
	if player == null:
		return
	if instant_interact:
		if interact(player):
			queue_free()
	else:
		on_overlap_start(player)


func _on_body_exited(body):
	var player := body as Player
	if player == null:
		return
	if not instant_interact:
		on_overlap_leave(player)
