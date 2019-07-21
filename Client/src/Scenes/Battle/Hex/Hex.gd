extends Node

var id = Vector2(0, 0)
var position = Vector2(0, 0)
var astar_id = 0

var current_unit = null

func Hex(pos, id, a_id):
	position = pos
	self.id = id
	astar_id = a_id

func _ready():
	pass # Replace with function body.

func is_occupied():
	if current_unit != null:
		return true
	return false
