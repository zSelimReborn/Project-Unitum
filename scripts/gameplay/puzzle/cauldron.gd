class_name Cauldron

extends PuzzlePiece

# Properties
@export var element : Types.Elements
@export var element_lit_color: Color

# OnReady
@onready var cauldron_top = $CauldronNode/CauldronTop
@onready var element_sprite = $ElementSprite
@onready var lit_cauldron = $CauldronNode/LitCauldron
@onready var collision = $Collision

func _ready():
	if not element_sprite:
		return
	element_sprite.texture = Types.ElementTextures[element]
	
func solve_piece(interactable):
	if not interactable or is_solved:
		return false
	var projectile = interactable as Projectile
	if not projectile or projectile.instigator_group != "player":
		return false
	if projectile.element != element:
		return false
	on_solved_piece()
	return true	

func on_solved_piece():
	disable_highlight_shader()
	enable_lit_cauldron()
	lit_element()
	
func disable_highlight_shader():
	if not cauldron_top:
		return
	cauldron_top.material.set_shader_parameter("enabled", false)

func enable_lit_cauldron():
	if not lit_cauldron:
		return
	var element_string = Types.ElementString[element]
	lit_cauldron.play(element_string)
	
func lit_element():
	if not element_sprite:
		return
	element_sprite.modulate = element_lit_color
