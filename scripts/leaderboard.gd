# Leaderboard.gd
extends Control

const ENTRY_SCENE = preload("res://scenes/Leaderboard_entry.tscn")

# 1. Datos Ficticios (Dummy Data) que simulan la respuesta de Firebase
const DUMMY_SCORES = [
	{"name": "GODOT_DEV", "score": 9850},
	{"name": "STR8_FLUSH", "score": 8200},
	{"name": "ACE_HIGH", "score": 6750},
	{"name": "PLAYER_4", "score": 5100},
	{"name": "RED_DICE", "score": 3950},
]

# Referencia al contenedor que contendrá las entradas
@onready var entries_container: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var close_button = $CenterContainer/PanelContainer/VBoxContainer/CloseButton

func _ready():
	if entries_container == null:
		push_error("ERROR CRÍTICO: entries_container es nulo. Revisar la ruta de @onready en Leaderboard.gd")
		# Pobla la lista con los datos ficticios
	print("DEBUG: Container encontrado. Procediendo a poblar...")
	_populate_leaderboard(DUMMY_SCORES)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	# Conecta el botón de cerrar
# Método que itera y crea las entradas
func _populate_leaderboard(scores: Array):
	# Limpia el contenedor (útil si se llama varias veces)
	print(scores)
	for child in entries_container.get_children():
		child.queue_free()

	for i in range(scores.size()):
		var score_data = scores[i]
		
		# Instanciar la escena de entrada
		var entry = ENTRY_SCENE.instantiate()
		
		# Llenar los datos de la fila
		entry.set_data(i + 1, score_data.name, score_data.score)
		
		# Añadir al contenedor de la lista
		entries_container.add_child(entry)

# Maneja el cierre del leaderboard
func _on_close_button_pressed():
	# Si esta escena es un hijo de Game, la elimina
	queue_free()
