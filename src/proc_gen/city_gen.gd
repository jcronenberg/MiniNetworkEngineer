class_name CityGen
extends Node2D

@export var grid_size: Vector2i = Vector2i(32, 32)
@export var cell_size: Vector2i = Vector2i(40, 40)
@export var grid_cell_size: Vector2i = Vector2i(3, 3)
@export var road_thickness: int = 20
@export var buildings: Array[Fake3DBuilding]
@export var use_threads: bool = false
# @export var buildings: Array[Pseudo3DFake3DBuilding]

enum GridCellType {
	PARK,
	HOUSING,
	EMPTY,
}

var _grid: Array[Array] = []
var _poly: Polygon2D = Polygon2D.new()

var _generate_cell_timer: float = 30.0
var _generated_cells: int = 0

var _thread_pool: Array[Thread] = []


func _init() -> void:
	_poly.polygon = [Vector2(0, 0), Vector2(cell_size.x * grid_cell_size.x, 0), Vector2(cell_size.x * grid_cell_size.x, cell_size.y * grid_cell_size.y), Vector2(0, cell_size.y * grid_cell_size.y)]
	_poly.color = Color(0, 255, 0)

	# setup _grid
	for x in grid_size.x:
		var x_array: Array[GridCell] = []
		x_array.resize(grid_size.y)
		_grid.append(x_array)

	Global.connect("camera_changed", _sort_buildings)

	#for _i in OS.get_processor_count():
		#_thread_pool.append(Thread.new())


func _ready() -> void:
	# generate_grid()
	_generate_grid_cell_at(0, 0)
	_generated_cells += 1

	if visible:
		_generate_buildings()


func _physics_process(delta: float) -> void:
	_generate_cell_timer += delta
	if _generate_cell_timer >= 30.0 and _generated_cells < grid_size.x * grid_size.y:
		while(not _generate_grid_cell_at(randi() % grid_size.x - grid_size.x / 2, randi() % grid_size.y - grid_size.x / 2)): pass
		_generated_cells += 1
		_generate_cell_timer = 0.0


func generate_grid() -> void:
	for x in range(-grid_size.x / 2, grid_size.x / 2):
		for y in range(-grid_size.y / 2, grid_size.y / 2):
			_generate_grid_cell_at(x, y)


func _generate_grid_cell_at(x: int, y: int) -> bool:
	if _grid[x][y] is GridCell:
		return false

	_grid[x][y] = _generate_grid_cell(GridCellType.EMPTY, cell_size * grid_cell_size * Vector2i(x, y) + Vector2i(x, y) * road_thickness)
	if x == 0 and y == 0:
		_grid[x][y] = _generate_grid_cell(GridCellType.EMPTY, cell_size * grid_cell_size * Vector2i(x, y) + Vector2i(x, y) * road_thickness)
	else:
		_grid[x][y] = _generate_grid_cell(GridCellType.values().filter(
				func(type: GridCellType) -> bool: return not type in [GridCellType.EMPTY]
			).pick_random(),
			cell_size * grid_cell_size * Vector2i(x, y) + Vector2i(x, y) * road_thickness)

	return true


func _generate_grid_cell(type: GridCellType, cell_center: Vector2i) -> GridCell:
	var cells: Array[Array] = []
	if type == GridCellType.PARK:
		var park_node: Polygon2D = _poly.duplicate()
		park_node.global_position = cell_center - cell_size / 2
		%Parks.add_child(park_node)
		cells.append([park_node])
	else:
		cells.resize(grid_cell_size.x)
		for x in grid_cell_size.x:
			var x_array: Array[Node2D] = []
			x_array.resize(grid_cell_size.y)
			for y in grid_cell_size.y:
				var new_node: Node2D
				if type == GridCellType.HOUSING:
					new_node = Global.current_simulation.create_placed_house_at(cell_center + Vector2i(x, y) * cell_size)
				else:
					continue

				x_array[y] = new_node

			cells[x] = x_array

	var grid_cell: GridCell = GridCell.new()
	grid_cell.cells = cells
	grid_cell.type = type
	grid_cell.cell_center = cell_center
	return grid_cell


func _generate_buildings() -> void:
	var building_amount: int = 50
	for i in building_amount:
		for j in building_amount:
			var building: Fake3DBuilding = Fake3DBuilding.new()
			building.height = randi_range(10, 100)
			building.plot_size = 50#randi_range(10, 50)
			# var building: Pseudo3DFake3DBuilding = Pseudo3DFake3DBuilding.new()
			# building.set_height(randf_range(10, 100))
			# building.set_plot_size(50)#randi_range(10, 50)
			building.global_position = Vector2(i * 100, j * 100)#Vector2(randf_range(i * 100 - 5, i * 100 + 5), randf_range(j * 100 - 5, j * 100 + 5))

			if not use_threads:
				Global.connect("camera_changed", building.set_camera_pos)

			buildings.append(building)
			building.generate_building()
			add_child(building)

	for building in buildings:
		building.generate_building()
		add_child(building)


func _sort_buildings(camera_pos: Vector2, zoom: Vector2) -> void:
	# if zoom.x >= 0.2:
	# buildings.sort_custom(func(a: Pseudo3DFake3DBuilding, b: Pseudo3DFake3DBuilding) -> bool:
	buildings.sort_custom(func(a: Fake3DBuilding, b: Fake3DBuilding) -> bool:
		return a.global_position.distance_to(camera_pos) > b.global_position.distance_to(camera_pos)
		)

	for i in buildings.size():
		buildings[i].z_index = i
		# buildings[i].set_camera_pos(camera_pos, zoom)

	if not use_threads:
		return

	for i in _thread_pool.size():
		_thread_pool[i].start(_work_thread.bind(i, camera_pos, zoom))

	for thread in _thread_pool:
		thread.wait_to_finish()


func _work_thread(index: int, camera_pos: Vector2, zoom: Vector2) -> void:
	for i in ceil(float(buildings.size()) / _thread_pool.size()) as int:
		i = i * _thread_pool.size() + index
		if i >= buildings.size():
			continue
		buildings[i].set_deferred("z_index", i)
		buildings[i].set_camera_pos(camera_pos, zoom)


class GridCell:
	var cells: Array[Array] = []
	var type: GridCellType
	var cell_center: Vector2i
