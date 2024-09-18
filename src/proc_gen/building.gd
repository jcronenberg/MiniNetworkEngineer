class_name Fake3DBuilding
extends Node2D
## A building that renders a perspective height in 2D
##
## Note this isn't very performant for a large amount of buildings,
## only use this if you plan to render like max 50 buildings on the screen.

@export var building_scale: int = 100
@export var plot_size: float
@export var height: float
@export var building_color: Color = Color("#03346e")
@export var roof_color: Color = Color("#e2e2b6")

var _visibility_notifier: VisibleOnScreenNotifier2D
var _building_poly: Polygon2D
var _roof_poly: Polygon2D
var _foundation: PackedVector2Array


func generate_building() -> void:
	_foundation = [Vector2(-plot_size, -plot_size), Vector2(-plot_size, plot_size), Vector2(plot_size, plot_size), Vector2(plot_size, -plot_size)]

	_visibility_notifier = VisibleOnScreenNotifier2D.new()
	_visibility_notifier.rect = Rect2(-plot_size, -plot_size, plot_size * 2, plot_size * 2)
	_visibility_notifier.connect("screen_entered", _on_screen_entered)
	_visibility_notifier.connect("screen_exited", _on_screen_exited)

	_building_poly = Polygon2D.new()
	_building_poly.color = building_color
	var poly: PackedVector2Array = _foundation.duplicate()
	poly.append_array(_foundation)
	_building_poly.polygon = poly
	_building_poly.polygons = [[0, 1, 2, 3], [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7]]
	_building_poly.antialiased = true
	_building_poly.visible = false

	_roof_poly = Polygon2D.new()
	_roof_poly.color = roof_color
	_roof_poly.polygon = _foundation
	_roof_poly.antialiased = true
	_roof_poly.z_index = 1
	_roof_poly.visible = false

	add_child(_building_poly)
	add_child(_roof_poly)
	add_child(_visibility_notifier)


func set_camera_pos(camera_pos: Vector2, zoom: Vector2) -> void:
	if not _building_poly.visible:
		return

	var zoom_scale: float = building_scale / zoom.x / (building_scale / zoom.x - height)
	var direction: Vector2 = camera_pos.direction_to(global_position) * height * camera_pos.distance_to(global_position) / building_scale * zoom

	for i in _foundation.size():
		_roof_poly.polygon[i] = (_foundation[i] + direction) * zoom_scale
		_building_poly.polygon[i + 4] = (_foundation[i] + direction) * zoom_scale


func _on_screen_entered() -> void:
	_building_poly.visible = true
	_roof_poly.visible = true


func _on_screen_exited() -> void:
	_building_poly.visible = false
	_roof_poly.visible = false


# This function should be implemented in a separate parent that generates the building
# It should be called every time the camera_pos or zoom of the camera changed
var buildings: Array[Fake3DBuilding] = []
func _sort_buildings(camera_pos: Vector2, zoom: Vector2) -> void:
	buildings.sort_custom(func(a: Fake3DBuilding, b: Fake3DBuilding) -> bool:
		return a.global_position.distance_to(camera_pos) > b.global_position.distance_to(camera_pos)
		)

	for i in buildings.size():
		buildings[i].z_index = i
		buildings[i].set_camera_pos(camera_pos, zoom)
