class_name GameUI
extends Control

var _elapsed_time: float = 0.0 # TODO in the future this should probably be requested from simulation


func _physics_process(delta: float) -> void:
	%FPSCounter.text = "FPS: %s" % str(Engine.get_frames_per_second())
	_elapsed_time += delta
	%Timer.text = str(round(_elapsed_time))


func display_warning(text: String) -> void:
	%WarningLabel.text = text
	%WarningLabel.visible = true


func hide_warning() -> void:
	%WarningLabel.visible = false


func toggle_delete_cable_button_visibility(state: bool) -> void:
	%DeleteCableButton.visible = state


func _on_delete_cable_button_pressed() -> void:
	Global.current_simulation.delete_selected_nodes()


func _on_new_switch_button_pressed() -> void:
	Global.current_simulation.create_switch()
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_new_house_button_pressed() -> void:
	Global.current_simulation.create_house()
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_cable_copper_button_pressed() -> void:
	Global.selected_cable_type = Global.CableTypes.COPPER
	Global.cursor_mode = Global.CursorModes.CABLE


func _on_cable_fiber_button_pressed() -> void:
	Global.selected_cable_type = Global.CableTypes.FIBER
	Global.cursor_mode = Global.CursorModes.CABLE
