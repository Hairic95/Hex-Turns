extends Node2D

var id = Vector2(0, 0)

func set_id(vec):
	id = vec

var is_mouse_on = false
var is_being_click_on = false

signal pressed(self_ref)

func _input(ev):
	if ev is InputEventMouseButton:
		
		if is_mouse_on and ev.button_index == BUTTON_LEFT:
			
			if ev.pressed:
				is_being_click_on = true
			elif !ev.pressed and is_being_click_on:
				emit_signal("pressed", id)

func _on_click_area_mouse_entered():
	$selectable.modulate.a = 0.8
	is_mouse_on = true

func _on_click_area_mouse_exited():
	$selectable.modulate.a = 0.3
	is_mouse_on = false
