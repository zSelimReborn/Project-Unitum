class_name Types

extends Node

const DISTANCE_INTERNAL_EPSILON = 5

# Oh yeah, consistency
enum PlayerState { Character, Shadow }

enum Elements { WATER, FIRE, AIR, EARTH }

enum Ending { None, Human, Shadow, Good, Pacifist }

static var ElementString = {
	Elements.WATER: "water",
	Elements.FIRE: "fire",
	Elements.AIR: "air",
	Elements.EARTH: "earth"
}

static var ElementTextures = {
	Elements.FIRE: {
		"inactive": preload("res://assets/gameplay/elements/fire_ui_inactive.png"),
		"active": preload("res://assets/gameplay/elements/fire_ui_active.png")
	},
	Elements.WATER: {
		"inactive": preload("res://assets/gameplay/elements/water_ui_inactive.png"),
		"active": preload("res://assets/gameplay/elements/water_ui_active.png")
	},
	Elements.AIR: {
		"inactive": preload("res://assets/gameplay/elements/air_ui_inactive.tga"),
		"active": preload("res://assets/gameplay/elements/air_ui.tga")
	},
	Elements.EARTH: {
		"inactive": preload("res://assets/gameplay/elements/earth_ui_inactive.png"),
		"active": preload("res://assets/gameplay/elements/earth_ui_active.png")
	},
}
