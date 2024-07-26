class_name SecretWall

extends PuzzlePiece

# Properties
@export var num_hits = 3
@export var element : Types.Elements
@export var hit_flash_duration : float = 0.4

# OnReady
@onready var hits = num_hits
@onready var sprite_container = $SpriteContainer

func try_solve_piece(interactable):
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

func on_solved_piece():
	queue_free()

func hit_flash():
	if not sprite_container:
		return
	sprite_container.material.set_shader_parameter("hit_flash", true)
	await get_tree().create_timer(hit_flash_duration).timeout
	sprite_container.material.set_shader_parameter("hit_flash", false)
