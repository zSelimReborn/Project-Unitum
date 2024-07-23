class_name Enemy

extends BaseCharacter

enum EnemyState { PATROL, FOLLOWING }

# Variables
var rng = RandomNumberGenerator.new()
var directions = [-1, 1]
var state = EnemyState.PATROL

# Properties
@export var player : Player
@export var patrol_distance = 200
@export var aggro_player_dist = 500
@export var push_force = 50
@export var element : Types.Elements
@export var counter_element : Types.Elements

# On Ready
@onready var aggro_player_dist_sqr = aggro_player_dist * aggro_player_dist
@onready var left_point = position + Vector2.LEFT * patrol_distance
@onready var right_point = position + Vector2.RIGHT * patrol_distance
@onready var destinations = {-1: left_point, 1: right_point}
@onready var direction = directions[rng.randi() % directions.size()]
@onready var current_destination = destinations[direction]

@onready var hit_collision = $HitCollisionArea


func _ready():
	add_to_group("enemy")
	hit_collision.body_entered.connect(hit_something)

func process_movement_input():
	calc_destination()
	add_movement(direction)
	handle_sprite(direction)

	var distance = abs(position.x - current_destination.x)
	if distance <= Types.DISTANCE_INTERNAL_EPSILON && state == EnemyState.PATROL:
		flip_direction()

func flip_direction():
	if direction == -1:
		direction = 1
		current_destination = right_point
	else:
		direction = -1
		current_destination = left_point
		
func calc_destination():
	if state == EnemyState.FOLLOWING:
		if player != null:
			current_destination = player.position
			direction = roundf((current_destination - position).normalized().x) as int
			return
	current_destination = destinations[direction]
	
func check_state():
	if state == EnemyState.FOLLOWING:
		return
	if player != null and player.position.distance_squared_to(position) <= aggro_player_dist_sqr:
		state = EnemyState.FOLLOWING
		return
	state = EnemyState.PATROL

func _physics_process(delta):
	check_state()
	process_movement_input()
	position += velocity * delta

	process_animation(delta)
	
func hit_player(p: Player):
	if p == null:
		return
	var impulse = Vector2(direction * push_force, 0)
	p.add_impulse(impulse)
	
func hit_something(body):
	if not body.is_in_group("player"):
		return
	var p = body as Player
	hit_player(p)
