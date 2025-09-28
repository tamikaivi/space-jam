# Archivo: dice_piece.gd
extends Node2D
class_name DicePiece

# Diccionario de texturas pre-cargadas para la eficiencia
# (Asumiendo que las rutas son correctas)
const DICE_TEXTURES := {
	1: preload("res://sprites/dado_1.png"),
	2: preload("res://sprites/dado_2.png"),
	3: preload("res://sprites/dado_3.png"),
	4: preload("res://sprites/dado_4.png"),
	5: preload("res://sprites/dado_5.png"),
	6: preload("res://sprites/dado_6.png")
}

# La posición de la pieza en la grilla (no en píxeles)
@export var grid_position := Vector2i(2, 0)

# El valor actual del dado (1 a 6)
var value := 1

# La única celda de la pieza (para un dado simple 1x1, siempre es Vector2i(0, 0))
# Si implementas más formas, esta Array contendría más Vector2i
const CELL_COORDS := [Vector2i(0, 0)]

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Asegura que el sprite esté configurado correctamente para el tamaño del tile.
	# TILE_SIZE (64) debe coincidir con el tamaño de tus sprites.
	sprite.position = Vector2.ZERO 
	
	# Usar un método para inicializar el valor
	set_random_value()

# Configura un valor de dado aleatorio y actualiza la textura
func set_random_value():
	value = randi() % 6 + 1
	update_texture()

# Actualiza la textura basada en el valor actual
func update_texture():
	if DICE_TEXTURES.has(value):
		sprite.texture = DICE_TEXTURES[value]
		
# Método para obtener el valor contrario (7 - valor actual)
func toggle_opposite_face():
	value = 7 - value
	update_texture()
	
# Método para que el Board pida la lista de celdas que la pieza ocupa.
# En este caso, solo una celda, relativa a grid_position.
func get_cells() -> Array[Vector2i]:
	var world_cells: Array[Vector2i] = []
	# Para la forma de 1x1, solo añadimos la posición actual
	for cell in CELL_COORDS:
		world_cells.append(grid_position + cell)
	return world_cells
