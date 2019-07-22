extends Node2D

export (PackedScene) var hexView_ref
export (PackedScene) var unitView_ref

func create_hex(pos, id):
	var new_hexView = hexView_ref.instance()
	
	$hexes.add_child(new_hexView)
	new_hexView.set_position(pos)
	new_hexView.id = id

func get_hexView(id):
	for hex in $hexes.get_children():
		if hex.id == id:
			return hex

func create_unit(data, pos):
	var new_unitView = unitView_ref.instance()
	
	$units.add_child(new_unitView)
	new_unitView.UnitView(data, pos)

func get_unit(id):
	for unit in $units.get_children():
		if unit.id == id:
			return unit
	return null

func set_light(id, value):
	var unit = get_unit(id)
	print(id)
	if unit != null:
		unit.set_light(value)

func reset_units():
	for unit in $units.get_children():
		unit.set_light(false)

func set_new_path_to_unitView(id, path):
	get_unit(id).set_new_path(path)

func play_unit_anim(id, anim_name):
	get_unit(id).set_state(anim_name)
