class_name GameUI
extends Control

var _elapsed_time: float = 0.0 # TODO in the future this should probably be requested from simulation


func _physics_process(delta: float) -> void:
	%FPSCounter.text = "[color=black]%s" % str(Engine.get_frames_per_second())
	_elapsed_time += delta
	%Timer.text = "[center][color=black]%s" % str(round(_elapsed_time))


func display_warning(text: String):
	%WarningLabel.text = text
	%WarningLabel.visible = true


func hide_warning():
	%WarningLabel.visible = false


func _on_move_switch_button_pressed():
	Global.cursor_mode = Global.CursorModes.MOVE_SWITCH


func _on_delete_cable_button_pressed():
	Global.cursor_mode = Global.CursorModes.DELETE_CABLE


func _on_new_switch_button_pressed():
	Global.get_current_simulation().create_switch()
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_new_house_button_pressed():
	Global.get_current_simulation().create_house()
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_cable_copper_button_pressed():
	Global.selected_cable_type = Global.CableTypes.COPPER
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_cable_fiber_button_pressed():
	Global.selected_cable_type = Global.CableTypes.FIBER
	Global.cursor_mode = Global.CursorModes.CABLE