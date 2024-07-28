class_name Relic

extends BaseInteractable

# On Ready
@onready var sprite = $Sprite

# Properties
@export var opened_anim : String = "opened"
@export var relic_type : Types.PlayerState
@export var ui_texture : Texture2D
@export var ui_text : String
@export var tag : String

# Variables
var opened = false

func _ready():
	super()
	instant_interact = false	
	print(PlayerStorage.opened_chest)
	if PlayerStorage.opened_chest.has(tag):
		open()
		return

func interact(player: Player):
	if opened:
		return false
	if not player:
		return false
	var relic_component = player.get_node("RelicComponent")
	if not relic_component:
		return false
	opened = relic_component.add_relic(self)
	if (opened):
		open()
	return opened

func open():
	opened = true
	on_opened()
	is_interactable = false
	PlayerStorage.opened_chest.append(tag)
	
func on_opened():
	if not sprite:
		printerr("relic cannot change state, no sprite")
		return
	sprite.play(opened_anim)
