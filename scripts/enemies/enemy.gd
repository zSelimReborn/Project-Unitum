class_name Enemy

extends BaseCharacter

enum EnemyState { PATROL, FOLLOWING }

# Variables
var rng = RandomNumberGenerator.new()
var directions = [-1, 1]
var state = EnemyState.PATROL
var initial_sprite_scale = Vector2(1,1)

# Properties
@export var player : Player
@export var patrol_distance = 200
@export var aggro_player_dist = 500
@export var push_force = 50
@export var element : Types.Elements
@export var counter_element : Types.Elements
@export var projectile_class : PackedScene
@export var fire_rate_max = 5
@export var fire_rate_min = 3
@export var target_sprite_scale_loading_shoot = 1.5
@export var main_group = "enemy"
@export var spawn_heal_probability = 0.7
@export var heal_y_offset = 10
@export var heal_class : PackedScene

# On Ready
@onready var aggro_player_dist_sqr = aggro_player_dist * aggro_player_dist
@onready var left_point = position + Vector2.LEFT * patrol_distance
@onready var right_point = position + Vector2.RIGHT * patrol_distance
@onready var destinations = {-1: left_point, 1: right_point}
@onready var direction = directions[rng.randi() % directions.size()]
@onready var current_destination = destinations[direction]

@onready var marker_anchor = $MarkerAnchor
@onready var marker = $MarkerAnchor/Marker
@onready var fire_rate_timer = $FireRate
@onready var fire_rate = rng.randf_range(fire_rate_min, fire_rate_max)
@onready var target_sprite_scale_vector = Vector2(target_sprite_scale_loading_shoot, target_sprite_scale_loading_shoot)

@onready var hit_collision = $HitCollisionArea
@onready var left_cast = $LeftCast
@onready var right_cast = $RightCast

func _ready():
	initial_sprite_scale = sprite.scale
	
	add_to_group(main_group)
	if not player:
		player = get_tree().get_nodes_in_group("player")[0]
	if hit_collision != null:
		hit_collision.body_entered.connect(hit_something)
	if fire_rate_timer != null:
		fire_rate_timer.wait_time = fire_rate
		fire_rate_timer.one_shot = false
		fire_rate_timer.timeout.connect(shoot)

func process_movement_input():
	calc_destination()
	add_movement(direction)
	handle_sprite(direction)

	var distance = abs(position.x - current_destination.x)
	if distance <= Types.DISTANCE_INTERNAL_EPSILON && state == EnemyState.PATROL:
		flip_direction()
		
func flip_sprite(left: bool):
	super(left)
	if not marker_anchor:
		printerr("enemy has no marker_anchor ", name)
		return
	var marker_rotation = 180 if left else 0
	marker_anchor.rotation_degrees = marker_rotation

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
		on_detect_player()
		return
	state = EnemyState.PATROL
	
func on_detect_player():
	fire_rate_timer.start()
	
func shoot():
	if not marker:
		printerr("enemy cannot shoot, no marker")
		return
	var projectile = Common.spawn_projectile(owner, projectile_class, self, main_group, damage, element, marker.global_transform)
	if not projectile:
		printerr("enemy tried to shoot but failed")

func _physics_process(delta):
	check_state()
	process_movement_input()
		
	if (hit_wall()):
		if state == EnemyState.PATROL:
			flip_direction()
	else:
		position += velocity * delta

	process_animation(delta)
	process_target_scale(delta)
	
func process_target_scale(_delta):
	if fire_rate_timer.is_stopped():
		sprite.scale = initial_sprite_scale
		return
	
	var wait_time = fire_rate_timer.wait_time
	var time_left = fire_rate_timer.time_left
	var ratio = time_left / wait_time
	var new_scale = lerp(target_sprite_scale_vector, initial_sprite_scale, ratio)
	sprite.scale = new_scale
	
func hit_player(p: Player):
	if p == null:
		return
	var impulse = Vector2(direction * push_force, 0)
	p.add_impulse(impulse)
	p.take_damage(damage)
	
func hit_something(body):
	if not body.is_in_group("player"):
		return
	var p = body as Player
	hit_player(p)
	
func die():
	super()
	spawn_heal()
	queue_free()
	
func spawn_heal():
	if not heal_class:
		return
	var prob = rng.randf()
	print(prob)
	if prob > spawn_heal_probability:
		return
	var new_heal = heal_class.instantiate()
	new_heal.transform = global_transform
	new_heal.position.y += (-heal_y_offset)
	print(new_heal.position)
	owner.add_child(new_heal)
	
func hit_wall():
	if not left_cast or not right_cast:
		return false
	return (direction <= -1 and left_cast.is_colliding()) or (direction >= 1 and right_cast.is_colliding())
	
func can_take_damage(instigator):
	if not instigator:
		return true
	var projectile = instigator as Projectile
	if not projectile:
		return true
	return projectile.element == counter_element
