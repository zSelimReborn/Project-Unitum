extends Node

var kill_count : int = 0
var relics = {
	Types.PlayerState.Character: 0,
	Types.PlayerState.Shadow: 0
}
var opened_chest = []
var ending = Types.Ending.None

func reset():
	kill_count = 0
	relics = {
		Types.PlayerState.Character: 0,
		Types.PlayerState.Shadow: 0
	}
	opened_chest = []
	ending = Types.Ending.None
