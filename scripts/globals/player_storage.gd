extends Node

var kill_count : int = 2
var relics = {
	Types.PlayerState.Character: 2,
	Types.PlayerState.Shadow: 2
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
