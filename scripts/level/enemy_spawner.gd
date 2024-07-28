class_name EnemySpawner

extends Node2D

# Properties
@export var enemy_classes : Array[PackedScene]
@export var spawn_points : Array[Node2D]
@export var total_enemies : int = 10
@export var enemy_per_stage : int = 2
@export var enemy_aggro : int = 500

# Variables
var rng = RandomNumberGenerator.new()
var enemy_remaining : int = 0
var completed = false

# On Ready

# Events
signal on_stage_completed()

func start_stage():
	if not can_start():
		on_error()
		return
	spawn_stage()
	
func spawn_stage():
	for i in enemy_per_stage:
		var enemy_class = pick_class()
		if not enemy_class:
			printerr("unable to spawn enemy class empty")
			continue
		var spawn_point = pick_spawn_point(i)
		if not spawn_point:
			printerr("unable to spawn enemy, empty spawn point: ", i)
			return
		var enemy = enemy_class.instantiate()
		enemy.transform = spawn_point.transform
		enemy.aggro_player_dist = enemy_aggro
		owner.add_child(enemy)
		enemy.set_owner(owner)
		enemy.on_death.connect(on_enemy_death)
		enemy.calculate_destinations()
	enemy_remaining = enemy_per_stage
		
func pick_class():
	return enemy_classes[rng.randi_range(0, enemy_classes.size() - 1)]
	
func pick_spawn_point(index):
	return spawn_points[index % spawn_points.size() - 1]
	
func on_enemy_death():
	enemy_remaining -= 1
	if enemy_remaining > 0:
		return
	total_enemies -= enemy_per_stage
	if total_enemies > 0:
		spawn_stage()
	else:
		completed = true
		on_stage_completed.emit()
	
func can_start():
	if completed:
		return false
	if enemy_classes.is_empty():
		printerr("unable to spawn enemies, no classes selected")
		return false
	if spawn_points.is_empty():
		printerr("unable to spawn enemies, no spawn points selected")
		return false
	if total_enemies <= 0:
		printerr("unable to spawn enemies, wrong total")
		return false
	return true
		
func on_error():
	on_stage_completed.emit()
