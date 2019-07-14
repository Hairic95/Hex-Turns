extends Node

"""
////////////////////////////////////////////////////
               HEX FIELD CODE AREA
////////////////////////////////////////////////////
"""

export (PackedScene) var hex_ref

onready var astar = AStar.new()

#var size = ""
var x_max = 0
var y_max = 0

var field_offset = Vector2(65, 50)

signal set_hex_selectable(id, pos)
signal hex_created_at(pos, id)

"""
field generation:
	uses the x and y ranges to make that many hexes, distant based on hex_size
	the field than is connect within an A* resource to calculate any path the unit can take
"""
func create_level(x_range, y_range, hex_size):
	
	x_max = x_range
	y_max = y_range
	
	var y_offeset = hex_size.y * 3.0 / 4.0
	var x_offeset = hex_size.x / 2.0
	
	for x in range(x_range):
		for y in range(y_range):
			
			if (y % 2 == 1) and x == x_range -1:
				pass
			else:
				var pos = Vector2(x * hex_size.x + x_offeset * ((y) % 2), y * y_offeset)
				$hexes.add_child(add_hex(pos + field_offset, Vector2(x, y)))
				
	
	for hex in $hexes.get_children():
		add_passable_hex(hex.id)

"""
Hex Generation:
	creates an virtual hex giving it an id and a position (for pathfinding and to identify)
	also alerts the view to create a corresponding HexView for the player to actually see
"""
func add_hex(pos, id):
	
	var new_hex = hex_ref.instance()
	
	var astar_id = get_astar_id(id)
	
	new_hex.Hex(pos, id, astar_id)
	astar.add_point(astar_id, Vector3(pos.x, pos.y, 0))
	
	emit_signal("hex_created_at", pos, id)
	return new_hex

"""
creates a unique id to use for the A* node
"""
func get_astar_id(id):
	return id.x + id.y * x_max

func get_adjacent_hex(center_hex):
	var adjs = []
	if int(center_hex.y) % 2:
		for vec in odd_adjacents:
			if get_hex(center_hex + vec):
				adjs.append(get_hex(center_hex + vec))
	else:
		for vec in even_adjacents:
			if get_hex(center_hex + vec):
				adjs.append(get_hex(center_hex + vec))
	return adjs

"""
functions to connect, remove connections and change A* points weight
"""
var odd_adjacents = [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(1, 1),
	Vector2(1, -1),
]
var even_adjacents = [
	Vector2(1, 0),
	Vector2(-1, 0),
	Vector2(0, 1),
	Vector2(0, -1),
	Vector2(-1, -1),
	Vector2(-1, 1),
]
func remove_passable_hex(hex_id):
	for adj_hex in astar.get_point_connections(get_hex(hex_id).astar_id):
		astar.disconnect_points(adj_hex, get_hex(hex_id).astar_id)
func add_passable_hex(hex_id):
	
	var hex = get_hex(hex_id)
	
	for adj_hex in get_adjacent_hex(hex_id):
		if adj_hex != null and adj_hex.current_unit == null:
			if astar.has_point(adj_hex.astar_id) and !astar.are_points_connected(hex.astar_id, adj_hex.astar_id):
				astar.connect_points(hex.astar_id, adj_hex.astar_id)

"""
return the corresponding hex given the id
"""
func get_hex(id):
	for hex in $hexes.get_children():
		if hex.id == id:
			return hex
	return null

"""
handles when a Hex is selected
"""
func hex_clicked(id):
	pass

"""
return all cell in a certain radius from the starting hex (including the starting_hex)
it is BattleUI business to handle the inputs, depending on the Action Target
"""
func get_hexes_at_distance_from(starting_hex, radius):
	
	var hex_to_return = []
	
	for hex in $hexes.get_children():
		var point3path = astar.get_point_path(get_hex(starting_hex).astar_id, hex.astar_id)
		var path = []
		
		for point in point3path:
			path.append(Vector2(point.x, point.y))
		
		if path.size() != 0 and path.size() - 1 <= radius:
			hex_to_return.append(hex)
	
	return hex_to_return

func get_first_ranged_hexes(pos, radius):
	
	var directions = []
	var hex_to_return = []
	
	if int(pos.y) % 2:
		directions = odd_adjacents
	else:
		directions = even_adjacents
	
	for dir in directions:
		
		for i in range(radius):
			
			var hex = get_hex(pos + dir * (i + 1))
			
			if hex != null and hex.current_unit != null:
				if i == 2:
					print(str(pos, " / ", hex.id))
				hex_to_return.append(hex)
				#break
		
	
	return hex_to_return

func set_hex_selectable(id):
	var hex = get_hex(id)
	emit_signal("set_hex_selectable", hex.id, hex.position)


"""
////////////////////////////////////////////////////
                NETPLAYER CODE AREA
////////////////////////////////////////////////////
"""

export (PackedScene) var NetPlayer_ref = load("res://src/Scenes/Battle/NetPlayer/NetPlayer.tscn")


"""
////////////////////////////////////////////////////
                  UNIT CODE AREA
////////////////////////////////////////////////////
"""
"""
export (PackedScene) var player

signal unit_created_at(data, pos)
signal play_unit_anim(id, anim_name)

func add_unit_at(unit_data, hex_pos):
	
	var new_unit = unit_ref.instance()
	$units.add_child(new_unit)
	
	new_unit.id = unit_data.id
	
	new_unit.position = hex_pos
	
	remove_passable_hex(hex_pos)
	
	get_hex(hex_pos).current_unit = new_unit
	
	new_unit.connect("play_anim", self, "play_unit_animation")
	
	emit_signal("unit_created_at", unit_data, get_hex(hex_pos).position)

func play_unit_animation(id, anim_name):
	emit_signal("play_unit_anim",id, anim_name)
"""
"""
////////////////////////////////////////////////////
ACTION HANDLER
////////////////////////////////////////////////////
"""
"""
signal set_unitView_path(id, path)
signal remove_unit_from_turn(unit)

func handle_action(user, action, hex_targets):
	
	match(action.type):
		"move":
			var start = get_hex(user.position)
			var end = get_hex(hex_targets[0])
			var vec3path = astar.get_point_path(start.astar_id, end.astar_id)
			
			var path = []
			
			for point in vec3path:
				path.append(Vector2(point.x, point.y))
			
			emit_signal("set_unitView_path", user.id, path)
			
			start.current_unit = null
			
			user.position = hex_targets[0]
			end.current_unit = user
		"attack":
			
			var target = get_hex(hex_targets[0]).current_unit
			target.dies()
			
			emit_signal("remove_unit_from_turn", target)
	
	
	remove_passable_hex(user.position)
"""
"""
TEST AREA
"""
