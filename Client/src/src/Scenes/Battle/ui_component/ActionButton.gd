extends TextureButton

var action

signal selected(action)

func _ready():
	pass

func _on_ActionButton_pressed():
	emit_signal("selected", action)
