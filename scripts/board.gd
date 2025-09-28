extends Node2D
class_name Board

const COLS := 5
const ROWS := 10
const TILE_SIZE := 64

# Nuevo array para los valores objetivo
var target_rail := []

# Target Rail Configuración
const MIN_TARGET_VALUE := 5
const MAX_TARGET_VALUE := 30
const TARGET_RAIL_COLS := 1 # La columna para los números de objetivo
const TARGET_RAIL_OFFSET := -1 # Dibuja una celda a la izquierda de la columna 0

var grid := []                # grilla del tablero
var current_piece = null  # pieza actual
var score := 0

@onready var fall_timer := Timer.new()
var move_dir := 0
var move_accumulator := 0.0
var move_delay := 0.12
var SIDE_PANEL_WIDTH := 3
var grid_texture: Texture2D = load("res://sprites/grid.png")
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
		if y > 0: 
			target_rail.append(randi_range(MIN_TARGET_VALUE, MAX_TARGET_VALUE)) # Godot 4: randi_range
		
	# Crear timer de caída
	add_child(fall_timer)
	fall_timer.wait_time = 0.8
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
		"pos": Vector2i(2, 0),
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
		print("YOU LOSE!", y)
		if y <= 0:
			game_over()
			return
		if y > 0:
			grid[y][x] = current_piece["value"]
	spawn_piece()  # nueva pieza
	queue_redraw()
	clear_lines()

# Dibujar grilla y pieza
func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(COLS * TILE_SIZE, ROWS * TILE_SIZE)), Color.BLACK)
	# dibujar tablero
	for y in range(ROWS):
		for x in range(COLS):
			if y == 0:
				continue
			var rect = Rect2(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE-1, TILE_SIZE-1)
			if grid[y][x] == 0:
				draw_texture_rect(grid_texture, rect, false)
			else:
				# dado (1–6)	
				draw_texture_rect(dice_textures[grid[y][x]], rect, false)
	# Dibujar Numeros Izquierda
	var fontNumbers = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	var text_color = Color.WHITE
	for target_index in range(target_rail.size()):
		var target_value = target_rail[target_index]
		var target_text = str(target_value)
		
		var grid_y = target_index + 1
		
		var px = (TARGET_RAIL_OFFSET * TILE_SIZE) + TILE_SIZE / 2
		var py = (grid_y * TILE_SIZE) + TILE_SIZE / 2
		var position = Vector2(px, py)
		
		var text_size = fontNumbers.get_string_size(target_text, font_size)
		position -= text_size / 2.0
		
		draw_string(
			fontNumbers, 
			position, 
			target_text,
			HORIZONTAL_ALIGNMENT_FILL,
			-1,
			font_size,
			text_color)
	# dibujar pieza actual
	
	
	if current_piece != null:
		for cell in current_piece["cells"]:
			var px = current_piece["pos"].x + cell.x
			var py = current_piece["pos"].y + cell.y
			if py >= 0:
				var rect = Rect2(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE-1, TILE_SIZE-1)
				draw_texture_rect(current_piece["texture"], rect, false)

	var panel_x := COLS * TILE_SIZE
# ------------------
# Panel izquierdo
# ------------------
	var panel_width: int = SIDE_PANEL_WIDTH * TILE_SIZE
	var font := ThemeDB.fallback_font

	var right_x := COLS * TILE_SIZE
	var right_rect = Rect2(right_x + 75, 80, 241, 40)
	#draw_rect(right_rect, Color.RED, true)
	draw_string(font, Vector2(right_x + 100, 100), "Score", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
	draw_string(font, Vector2(right_x + 125, 140),  str(score), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)



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
		var row_data = grid[y]
		var full:= true
		for x in range(COLS):
			if row_data[x] == 0:
				full = false
				break
		if full:
			var target_index = y - 1
			if target_index < 0 or target_index >= target_rail.size():
				continue
				
			var target_value = target_rail[target_index]
			var sum_value = 0;
			for v in row_data:
				sum_value += v
			var play_score = check_play(row_data)
			var base_score = 0;
			var is_combo = false
			
			if sum_value == target_value:
				base_score = 600
			if base_score > 0 and play_score > 0:
				is_combo= true
			var line_score = base_score + play_score
			if is_combo:
				line_score *= 2
			
			if line_score >0:
				score += line_score
				print("Línea completada! Puntos: ", line_score, " (Combo: ", is_combo, ")", " Nuevo Score: ", score)
					
				grid.remove_at(y)
				var new_row = []
				for i in range(COLS):
					new_row.append(0)
				grid.insert(0, new_row)
			
				target_rail.remove_at(target_index)
				target_rail.insert(0, randi_range(MIN_TARGET_VALUE, MAX_TARGET_VALUE))
				y += 1
			else: 
				pass
	queue_redraw()
	
func _process(delta):
	if move_dir != 0:
		move_accumulator += delta
		if move_accumulator >= move_delay:
			move_piece(Vector2i(move_dir,0))
			move_accumulator = 0.0

# En board.gd
# Retorna el puntaje base de la jugada (0 si no hay jugada)
func check_play(row_data: Array) -> int:
	# row_data es un array de 5 valores de dados [d1, d2, d3, d4, d5]
	if row_data.size() != COLS: return 0
	
	var counts := {} # Frecuencia de cada dado {valor: conteo}
	var values := [] # Valores únicos para escaleras
	
	for v in row_data:
		counts[v] = counts.get(v, 0) + 1
		if v not in values:
			values.append(v)
	var num_unique = counts.size()
	var max_count = 0
	for c in counts.values():
		max_count = max(max_count, c)
		# 1. Cinco Iguales (Five of a Kind)
	if num_unique == 1:
		return 500
		# 2. Escalera (Straight)
	if num_unique == 5:
		values.sort() # Ordenar [1, 2, 3, 4, 5] o [2, 3, 4, 5, 6]
		var is_straight := true
		for i in range(values.size() - 1):
			if values[i+1] != values[i] + 1:
				is_straight = false
				break
		if is_straight:
			return 400
	# 3. Full House (Tres iguales y un par)
	if num_unique == 2:
		if max_count == 3: # max_count es 3 (tres iguales) y el otro es 2 (par)
			return 200
			# No hay jugada reconocida
	return 0


func game_over():
	print("YOU LOSE!")
	fall_timer.stop()   # detener la caída automática
	move_dir = 0
	current_piece = null
	# Opcional: mostrar mensaje en pantalla
	var label = Label.new()
	label.text = "YOU LOSE!"
	label.position = Vector2(COLS * TILE_SIZE / 2 - 50, ROWS * TILE_SIZE / 2)
	label.add_theme_color_override("font_color", Color(1,0,0))
	add_child(label)
