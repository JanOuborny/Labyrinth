extends Spatial

"""
Add random Tiles in a SIZE x SIZE grid.
"""

export var SIZE: int = 10

var labyrinth: Spatial
var labyrinth_tile_array: Array = Array()

const Corner = preload("res://Assets/Objects/Tiles/Corner.tscn")
const Straight = preload("res://Assets/Objects/Tiles/Straight.tscn")
const TJunction = preload("res://Assets/Objects/Tiles/T-junction.tscn")

func _ready() -> void:
	randomize()
	
	_create_labyrinth()

# FIXME Player needs to move relatively to the ground he is standing on
#func _physics_process(delta: float) -> void:
#	labyrinth.translation.x += delta

func _push_column(column: int) -> void:
	assert(column >= 0)
	assert(column <= SIZE - 1)
	
	var next_tile = labyrinth_tile_array[0][column]
	
	for row in labyrinth_tile_array.size():
		var tile = next_tile
		
		if row != SIZE - 1:
			next_tile = labyrinth_tile_array[row + 1][column]
			labyrinth_tile_array[row + 1][column] = tile
			tile.translation.x += 1
		else:
			next_tile = labyrinth_tile_array[0][column]
			labyrinth_tile_array[0][column] = tile
			tile.translation.x = 0.5

func _push_row(row: int) -> void:
	assert(row >= 0)
	assert(row <= SIZE - 1)
	
	var next_tile = labyrinth_tile_array[row][0]
	
	for column in labyrinth_tile_array[row].size():
		var tile = next_tile
		
		if column != SIZE - 1:
			next_tile = labyrinth_tile_array[row][column + 1]
			labyrinth_tile_array[row][column + 1] = tile
			tile.translation.z += 1
		else:
			next_tile = labyrinth_tile_array[row][0]
			labyrinth_tile_array[row][0] = tile
			tile.translation.z = 0.5

func _create_labyrinth() -> void:
	labyrinth = Spatial.new()
	
	add_child(labyrinth)
	
	for row in SIZE:
		labyrinth_tile_array.push_back(Array())
		
		for column in SIZE:
			var tile
			var rand = randf()
			
			# Player starting position should not be Corner facing outwards
			if row == 0 and column == 0:
				if rand < 0.5:
					tile = Straight.instance()
				else:
					tile = TJunction.instance()
			else:
				if rand < 0.3:
					tile = Straight.instance()
				elif rand < 0.6:
					tile = Corner.instance()
				else:
					tile = TJunction.instance()
			
			labyrinth.add_child(tile)
			
			tile.translation = Vector3(row + 0.5, 0, column + 0.5)
			tile.rotation.y = float(randi() % 4) / 2.0 * PI
			
			labyrinth_tile_array[row].push_back(tile)
