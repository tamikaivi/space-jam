extends Node2D
class_name Board

const COLS := 5
const ROWS := 10
const TILE_SIZE := 64

var grid := []                # grilla del tablero
var current_piece = null  # pieza actual
var score := 0

@onready var fall_timer := Timer.new()
var move_dir := 0
var move_accumulator := 0.0
var move_delay := 0.12

# sprites para cada valor de dado
var dice_textures := {
	1: preload("res://sprites/dado_1.png"),
	2: preload("res://sprites/dado_2.png"),
	3: preload("res://sprites/dado_3.png"),
	4: preload("res://sprites/dado_4.png"),
	5: preload("res://sprites/dado_5.png"),
	6: preload("res://sprites/dado_6.png")
}

func _ready():
	# Inicializar grilla vacía
	for y in range(ROWS):
		var row := []
		for x in range(COLS):
			row.append(0)
		grid.append(row)
	for y in range(ROWS-5, ROWS):
		for x in range(COLS):
			grid[y][x] = randi() % 26 + 5

	# Crear timer de caída
	add_child(fall_timer)
	fall_timer.wait_time = 0.5
	fall_timer.one_shot = false
	fall_timer.timeout.connect(Callable(self, "_on_fall_timeout"))
	fall_timer.start()

	# Spawnear primera pieza
	spawn_piece()
	queue_redraw()

# Spawnea una pieza tipo O (2x2) centrada arriba
func spawn_piece():
	var value = randi() % 6 + 1
	current_piece = {
		"pos": Vector2i(4, 0),
		"cells": [Vector2i(0,0)],
		"value": value,
		"texture": dice_textures[value]  # amarillo
	}

# Timer de caída
func _on_fall_timeout():
	move_piece(Vector2i(0,1))

# Mueve la pieza; si no puede bajar, la fija
func move_piece(offset: Vector2i):
	if current_piece == null:
		return

	var new_pos: Vector2i = current_piece["pos"] + offset

	if can_move(new_pos, current_piece["cells"]):
		current_piece["pos"] = new_pos
	elif offset == Vector2i(0,1):
		lock_piece()

	queue_redraw()

# Verifica si la pieza puede estar en la posición
func can_move(pos: Vector2i, cells: Array) -> bool:
	for cell in cells:
		var x = pos.x + cell.x
		var y = pos.y + cell.y
		if x < 0 or x >= COLS:
			return false
		if y >= ROWS:
			return false
		if y >= 0 and grid[y][x] != 0:
			return false
	return true

# Fija la pieza en la grilla y spawnea otra
func lock_piece():
	for cell in current_piece["cells"]:
		var x = current_piece["pos"].x + cell.x
		var y = current_piece["pos"].y + cell.y
		if y >= 0:
			grid[y][x] = current_piece["value"]
	spawn_piece()  # nueva pieza
	queue_redraw()
	clear_lines()

# Dibujar grilla y pieza
func _draw():
	# dibujar tablero
	for y in range(ROWS):
		for x in range(COLS):
			var rect = Rect2(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE-1, TILE_SIZE-1)
			if grid[y][x] == 0:
				draw_rect(rect, Color(0.2,0.2,0.2), false)
			elif grid[y][x] >= 1 and grid [y][x] <= 6:
				draw_texture_rect(dice_textures[grid[y][x]], rect, false)
			else:
				# valores de las filas especiales (5..30)
				draw_rect(rect, Color(0.4,0.4,0.4), true)
				draw_string(
					ThemeDB.fallback_font, 
					rect.position + Vector2(5,50), 
					str(grid[y][x]),
					HORIZONTAL_ALIGNMENT_CENTER,
					-1,
					24,
					Color.BLACK)

	# dibujar pieza actual
	if current_piece != null:
		for cell in current_piece["cells"]:
			var px = current_piece["pos"].x + cell.x
			var py = current_piece["pos"].y + cell.y
			if py >= 0:
				var rect = Rect2(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE-1, TILE_SIZE-1)
				draw_texture_rect(current_piece["texture"], rect, false)
				

func _input(event: InputEvent):
	# movimiento lateral continuo
	if event.is_action_pressed("ui_left"):
		move_dir = -1
	elif event.is_action_pressed("ui_right"):
		move_dir = 1
	elif event.is_action_released("ui_left") and move_dir == -1:
		move_dir = 0
	elif event.is_action_released("ui_right") and move_dir == 1:
		move_dir = 0

	# caída rápida
	if event.is_action_pressed("ui_down"):
		move_piece(Vector2i(0,1))

	# Shift para mostrar lado contrario
	if event.is_action_pressed("ui_select") and current_piece != null:
		var v = current_piece["value"]
		var opp = 7 - v
		current_piece["value"] = opp
		current_piece["texture"] = dice_textures[opp]
		queue_redraw() 

func clear_lines():
	for y in range(ROWS -1 , -1, -1):  # de abajo hacia arriba
		var first_val = grid[y][0]
		if first_val == 0:
			continue
		var full:= true
		for x in range(COLS):
			if grid[y][x] != first_val:
				full = false
				break
		if full:
			grid.remove_at(y)
			var new_row = []
			for i in range(COLS):
				new_row.append(0)
			grid.insert(0, new_row)
			score += 10 * first_val
			print("Score: ", score)
			
func _process(delta):
	if move_dir != 0:
		move_accumulator += delta
		if move_accumulator >= move_delay:
			move_piece(Vector2i(move_dir,0))
			move_accumulator = 0.0
