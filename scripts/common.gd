class_name Common

extends Node


static func spawn_projectile(scene_owner, projectile_class, instigator, group, damage, element, transform):
	if not projectile_class:
		return null
	var projectile = projectile_class.instantiate()
	if not scene_owner:
		printerr("unable to spawn projectile, no owner")
		return null
	scene_owner.add_child(projectile)
	projectile.instigator = instigator
	projectile.instigator_group = group
	projectile.damage = damage
	projectile.element = element
	projectile.transform = transform
	return projectile
