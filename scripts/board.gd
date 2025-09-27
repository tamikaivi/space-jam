extends Node2D   
const COLS := 10
const ROWS := 20
const TILE_SIZE := 24

var grid := []

func _ready():
	init_grid()
	grid[19][4] = 1  # ejemplo: bloque rojo
	queue_redraw()   # en Godot 4

func init_grid():
	grid = []
	for y in ROWS:
		var row = []
		for x in COLS:
			row.append(0)
		grid.append(row)

func _draw():
	for y in ROWS:
		for x in COLS:
			var val = grid[y][x]
			var rect = Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE-1, TILE_SIZE-1)
			if val == 0:
				draw_rect(rect, Color(0.2,0.2,0.2), false) # borde
			else:
				draw_rect(rect, Color(1,0,0), true) # bloque rojo
