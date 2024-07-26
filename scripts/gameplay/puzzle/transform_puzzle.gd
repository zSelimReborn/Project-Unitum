class_name TransformPuzzle

extends PuzzlePiece

enum TransformState { NotTransformed, Transformed, Destroyed }

# Properties
@export var num_hits = 3
@export var element : Types.Elements
@export var hit_flash_duration : float = 0.4
@export var next_state : TransformState = TransformState.Destroyed
@export var animated_sprite : AnimatedSprite2D
@export var not_transformed_anim : String
@export var transformed_anim : String
@export var block_projectiles : bool = true

# OnReady
@onready var hits = num_hits
@onready var sprite_container = $SpriteContainer

func _ready():
	if animated_sprite:
		animated_sprite.play(not_transformed_anim)

func try_solve_piece(interactable):
	if is_solved:
		return false
	if not solve_piece(interactable):
		return false
	if hits <= 0:
		is_solved = true	
		on_solved_piece()
		on_solved.emit()

	return true

func solve_piece(interactable):
	if not interactable or is_solved:
		return false
	var projectile = interactable as Projectile
	if not projectile or projectile.instigator_group != "player":
		return false
	if projectile.element == element:
		hits -= 1
		hit_flash()
		return true
	return block_projectiles

func on_solved_piece():
	match next_state:
		TransformState.NotTransformed:
			pass
		TransformState.Transformed:
			activate_transformed_animation()
			disable_highlight_shader()
		TransformState.Destroyed:
			queue_free()
			
func activate_transformed_animation():
	if not animated_sprite:
		printerr("unable to transform, no animated sprite ", get_name())
		return
	animated_sprite.play(transformed_anim)

func hit_flash():
	if not sprite_container:
		return
	sprite_container.material.set_shader_parameter("hit_flash", true)
	await get_tree().create_timer(hit_flash_duration).timeout
	sprite_container.material.set_shader_parameter("hit_flash", false)
	
func disable_highlight_shader():
	if not sprite_container:
		return
	sprite_container.material.set_shader_parameter("enabled", false)
