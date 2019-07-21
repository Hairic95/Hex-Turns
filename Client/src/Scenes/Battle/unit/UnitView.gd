extends Node2D

signal action_anim_ended()

var id = ""

func UnitView(data, pos):
	
	self.id = data.id
	set_global_position(pos)

func _ready():

	set_process(false)
	set_state("idle")
	set_facing()

var path = []

var speed = 40

func _process(delta):
	if path.empty():
		set_state("idle")
		set_facing()
		emit_signal("action_anim_ended")
		set_process(false)
	else:
		var distance = path[0] - get_global_position()
		if distance.x > 0:
			set_facing("right")
		elif distance.x < 0:
			set_facing("left")
		if distance.length() <= 1.5:
			set_global_position(path.pop_front())
		else:
			set_global_position(delta * distance.normalized() * speed + get_global_position())

var current_state = ""

var default_facing = "right"
var current_facing = ""

func set_state(new_state):
	if current_state != new_state:
		current_state = new_state
		$image/image_anim.play(new_state)
		if new_state == "run":
			set_process(true)
func set_facing(new_facing = ""):
	if new_facing == "":
		set_facing(default_facing)
	elif current_facing != new_facing:
		current_facing = new_facing
		if current_facing == "right":
			$image.flip_h = true
		else:
			$image.flip_h = false

func set_light(value):
	if value:
		$light.show()
	else:
		$light.hide()

func set_new_path(path):
	self.path = path
	set_state("run")
