extends Node2D

var is_port_connected := false
var placed := false

## Colors the house either red (state: true) or black (state: false)
func set_allocated_state(state: bool):
	if state:
		material.set_shader_parameter("color", Color(0, 0, 0)) # black
	else:
		material.set_shader_parameter("color", Color(1, 0, 0)) # red


func set_is_port_connected(state):
	is_port_connected = state


func _process(_delta):
	if not placed:
		global_position = get_global_mouse_position()
		global_position = global_position.snapped(Vector2i(20, 20))


func _input(event):
	if event.is_action_pressed("LClick"):
		placed = true
		get_node("/root/Main/Simulation").add_house(self, global_position)
		set_process(false)
		set_process_input(false)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("RClick") or event.is_action_pressed("Cancel"):
		queue_free()
