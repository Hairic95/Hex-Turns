extends Control

var hex_size = Vector2(22, 22)

var x_range = 9
var y_range = 5

signal connection_error(message)

func _ready():
	
	if $BattleEntities.connect("hex_created_at", $BattleView, "create_hex"):
		emit_signal("connection_error", "Couldn't connect virtual hexes to view hexes.")
	if $BattleEntities.connect("unit_created_at", $BattleView, "create_unit"):
		emit_signal("connection_error", "Couldn't connect virtual unit to view unit.")
	if $BattleEntities.connect("set_unitView_path", $BattleView, "set_new_path_to_unitView"):
		emit_signal("connection_error", ".")
	if $BattleEntities.connect("play_unit_anim", $BattleView, "play_unit_anim"):
		emit_signal("connection_error", ".")
	if $BattleEntities.connect("remove_unit_from_turn", $BattleTurn, "remove_unit_from_turn"):
		emit_signal("connection_error", ".")
	
	
	
	if $BattleEntities.connect("set_hex_selectable", $BattleUI, "add_hex_area"):
		emit_signal("connection_error", "Couldn't connect virtual hexes to UI.")
	
	
	
	if $BattleTurn.connect("new_turn", self, "update_ui_to_unit"):
		emit_signal("connection_error", "Couldn't connect the turn manager to ui logic")
	if $BattleTurn.connect("turn_ended", self, "start_turn"):
		emit_signal("connection_error", "Couldn't connect the turn manager")
	if $BattleTurn.connect("finish_turn", self, "finish_turn"):
		emit_signal("connection_error", "Couldn't connect the turn manager")
	
	
	if $BattleUI.connect("action_selected", self, "setup_action"):
		emit_signal("connection_error", "")
	if $BattleUI.connect("hex_pressed", self, "hex_pressed"):
		emit_signal("connection_error", "")
	
	
	
	$BattleEntities.create_level(x_range, y_range, hex_size)
	
	$BattleEntities.add_unit_at({"id" : "1"}, Vector2(1, 2))
	$BattleEntities.add_unit_at({"id" : "2"}, Vector2(1, 3))
	
	$BattleEntities.add_unit_at({"id" : "3"}, Vector2(3, 2))
	$BattleEntities.add_unit_at({"id" : "4"}, Vector2(4, 3))
	$BattleEntities.add_unit_at({"id" : "5"}, Vector2(6, 1))
	$BattleEntities.add_unit_at({"id" : "6"}, Vector2(2, 0))
	
	start_turn()

func start_turn(unit_list = $BattleEntities/units.get_children()):
	for unit in unit_list:
		$BattleTurn.add_battler_to_list(unit)
	$BattleTurn.pop_action()

func update_ui_to_unit(unit):
	
	"""
	reset units and ui
	"""
	$BattleView.reset_units()
	$BattleUI.reset_ui()
	$BattleUI.reset_hex_areas()
	
	$BattleView.set_light(unit.id, true)
	
	$BattleUI.create_actionButtons(unit.get_actions())

func setup_action(action):
	
	var current_unit = $BattleTurn.current_unit
	
	$BattleUI.reset_hex_areas()
	
	if action.type == "move":
		$BattleEntities.add_passable_hex(current_unit.position)
	
	$BattleTurn.current_action = action
	
	match(action.type):
		"move":
			var passable_hexes = $BattleEntities.get_hexes_at_distance_from(current_unit.position, current_unit.movement)
			for hex in passable_hexes:
				$BattleEntities.set_hex_selectable(hex.id)
		"attack":
			var selectable_hexes = $BattleEntities.get_first_ranged_hexes(current_unit.position, action.radius)
			
			for hex in selectable_hexes:
				$BattleEntities.set_hex_selectable(hex.id)

func hex_pressed(id):
	
	$BattleUI.reset_hex_areas()
	$BattleEntities.handle_action($BattleTurn.current_unit, $BattleTurn.current_action, [id])

func finish_turn(unit):
	$BattleEntities.remove_passable_hex(unit.position)
