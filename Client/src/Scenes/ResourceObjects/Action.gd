extends Resource
class_name Action

export (String) var type = ""
var effects = []

var target : String = ""

export (int) var radius = 1
export (int) var damage = 0

signal action_ended()

func _init(type, damage, radius):
	self.radius = radius
	self.damage = damage
	self.type = type

func execute_action(user, targets_cells):
	for effect in effects:
		effect.execute_effect(user, targets_cells)
	emit_signal("action_ended")
