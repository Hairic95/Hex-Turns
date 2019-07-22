extends Node

export (String) var type = ""
var effects = []

export (String, "empty", "self", "singol") var target

export (int) var radius = 1
export (int) var damage = 0

signal action_ended()

func _ready():
	pass # Replace with function body.

func execute_action(user, targets_cells):
	
	for effect in effects:
		effect.execute_effect(user, targets_cells)
	
	emit_signal("action_ended")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
