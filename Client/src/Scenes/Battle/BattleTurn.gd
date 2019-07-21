extends Node

class_name TurnQueue

#Both Arrays of Action
var unitList  = []
var currentUnit
func GetCurrentUnit():
	return currentUnit.unit
var current_action

var turnIndex = 0
var players = []
var currentPlayerId = null

func StartTurn():
	for unitState in unitList:
		unitState.hasToAct = true
	PassToOtherPlayer()

func PassToOtherPlayer():
	if !players.empty():
		if currentPlayerId == null:
			currentPlayerId = players[turnIndex]
		else:
			if turnIndex == players.size():
				turnIndex = 0
			currentPlayerId = players[turnIndex]
	turnIndex += 1
	
	emit_signal("playerTurnChoice", currentPlayerId)

signal playerTurnChoice(playerId)
signal turn_ended()
signal new_turn(unit)
signal finish_turn(unit)

func add_battler_to_list(unit):
	if unit.current_state != "dead":
		var unitState = {
			"unit" : unit,
			"hasToAct" : true
		}
		
		unitList.append(unitState)
"""
func sort_actions():
	for i in range(unit_list.size()):
		var j = i + 1
		while (j) < (unit_list.size()):
			if unit_list[i].combatant.speed > unit_list[j].combatant.speed:
				var temp = unit_list[i].duplicate()
				unit_list[i] = unit_list[j].duplicate()
				unit_list[j] = temp
			j += 1

func pop_action():
	
	if currentUnit != null:
		emit_signal("finish_turn", GetCurrentUnit())
	
	if !unitList.empty():
		currentUnit = unitList.pop_front()
		emit_signal("new_turn", current_unit)
	else:
		emit_signal("turn_ended")
"""

func remove_unit_from_turn(unit):
	for u in unitList:
		if u.unit == unit:
			if unitList.has(unit):
				unitList.erase(unit)

func set_new_unit_list(newList):
	unitList = newList

func _on_end_turn_pressed():
	PassToOtherPlayer()
