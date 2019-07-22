extends Control

export (PackedScene) var hexButtonArea_ref
export (PackedScene) var actionButton_ref

signal action_selected(action)
signal hex_pressed(id)

func _ready():
	pass # Replace with function body.

func reset_ui():
	for child in $move_container/actions.get_children():
		child.queue_free()

func reset_hex_areas():
	for hex in $hexes_areas.get_children():
		hex.queue_free()

func add_hex_area(id, pos, type = "base"):
	match(type):
		"base":
			var new_hexButton = hexButtonArea_ref.instance()
			
			$hexes_areas.add_child(new_hexButton)
			new_hexButton.id = id
			new_hexButton.set_global_position(pos)
			
			if new_hexButton.connect("pressed", self, "hex_pressed"):
				emit_signal("connection_error", "Couldn't connect the Hex UI click to the UI")

func hex_pressed(id):
	emit_signal("hex_pressed", id)

func create_actionButtons(action_list):
	
	for action in action_list:
		var new_actionButton = actionButton_ref.instance()
		
		$move_container/actions.add_child(new_actionButton)
		
		new_actionButton.action = action
		new_actionButton.connect("selected", self, "action_selected")

func action_selected(action):
	for actionButton in $move_container/actions.get_children():
		if actionButton.action != action:
			actionButton.set_pressed(false)
	
	emit_signal("action_selected", action)

func ShowUnitChoice():
	pass
func ShowWaiting():
	pass
