class_name HealthPotion

extends BaseInteractable

# Properties
@export var amount: float = 10

func interact(player: Player):
	if player == null:
		return false
	if player.health >= player.max_health:
		return false
	if not player.is_alive:
		return false
	player.heal(amount)
	return true
