extends Node

class_name TurnQueue

#Both Arrays of Action
var unit_list  = []
var current_unit

var current_action

signal turn_ended()
signal new_turn(unit)
signal finish_turn(unit)

func add_battler_to_list(unit):
	if unit.current_state != "dead":
		unit_list.append(unit)

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
	
	if current_unit != null:
		emit_signal("finish_turn", current_unit)
	
	if !unit_list.empty():
		current_unit = unit_list.pop_front()
		emit_signal("new_turn", current_unit)
	else:
		emit_signal("turn_ended")

func remove_unit_from_turn(unit):
	if unit_list.has(unit):
		unit_list.erase(unit)

func set_new_unit_list(new_list):
	unit_list = new_list

func _on_end_turn_pressed():
	pop_action()
