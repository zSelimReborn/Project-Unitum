class_name Types

extends Node

const DISTANCE_INTERNAL_EPSILON = 5

enum PlayerState { Character, Shadow }

enum Elements { WATER, FIRE, AIR, EARTH }

static var ElementString = {
	Elements.WATER: "water",
	Elements.FIRE: "fire",
	Elements.AIR: "air",
	Elements.EARTH: "earth"
}

static var ElementTextures = {
	Elements.WATER: preload("res://assets/gameplay/triangle_water.tga"),
	Elements.FIRE: preload("res://assets/gameplay/triangle_fire.tga"),
	Elements.AIR: preload("res://assets/gameplay/triangle_air.tga"),
	Elements.EARTH: preload("res://assets/gameplay/triangle_earth.tga"),
}
