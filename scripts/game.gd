# Game.gd (Asignado al nodo raíz "Game")
extends Control

# Pre-carga la escena del leaderboard para instanciarla rápidamente
const LEADERBOARD_SCENE = preload("res://scenes/leaderboard.tscn")
const CONTROL_SCENE = preload("res://scenes/control.tscn")
# Referencia al nodo Board. Su ruta es: CenterContainer/GameArea/Board
@onready var board_node = $CenterContainer/GameArea/Board

# Referencia al botón del Leaderboard en la UI lateral
# AJUSTA LA RUTA SI ES NECESARIO (ej: CanvasLayer/MarginContainer/VBoxContainer/LeaderboardButton)
@onready var leaderboard_button = $CanvasLayer/MarginContainer/VBoxContainer/Leaderboardbutton

# Variable para rastrear el estado del leaderboard
var is_leaderboard_open = false

func _ready():
	# Conexión del botón de la UI principal para mostrar el Leaderboard
	if leaderboard_button:
		leaderboard_button.pressed.connect(show_leaderboard)
	
	# Opcional: Aquí puedes conectar una señal de 'game_over' emitida por el Board
	# board_node.game_over_signal.connect(_on_game_over)
	pass

func _unhandled_input(event: InputEvent):
	# Permite abrir/cerrar el leaderboard con una tecla (además del botón)
	if event.is_action_pressed("toggle_leaderboard"):
		if is_leaderboard_open:
			hide_leaderboard()
		else:
			show_leaderboard()

## --------------------------------------------------------------------------
## LÓGICA DEL LEADERBOARD (PAUSA GLOBAL)
## --------------------------------------------------------------------------

func show_leaderboard():
	if is_leaderboard_open:
		return

	# 1. Pausar todo el juego
	get_tree().paused = true 
	
	# 2. Instanciar y añadir el Leaderboard
	var leaderboard_instance = CONTROL_SCENE.instantiate()
	
	# 3. CRÍTICO: Asegurar que el Leaderboard se ejecute AUNQUE el juego esté pausado.
	leaderboard_instance.set_process_mode(Node.PROCESS_MODE_ALWAYS) 
	
	leaderboard_instance.name = "Leaderboard" # Nómbralo para referenciarlo
	add_child(leaderboard_instance)
	
	# 4. Conectar la señal del botón 'Cerrar' del leaderboard para ocultarlo
	var close_button = leaderboard_instance.find_child("Button") # Busca el primer botón hijo
	if close_button:
		# También aseguramos que el botón de cerrar procese el click en pausa
		close_button.set_process_mode(Node.PROCESS_MODE_ALWAYS) 
		close_button.pressed.connect(hide_leaderboard)

	is_leaderboard_open = true

func hide_leaderboard():
	if not is_leaderboard_open:
		return
		
	# 1. Eliminar la escena del Leaderboard
	var leaderboard_instance = get_node_or_null("Leaderboard")
	if leaderboard_instance:
		leaderboard_instance.queue_free()
		
	# 2. Reanudar el juego
	get_tree().paused = false # Desactiva la pausa para todo el árbol
	
	is_leaderboard_open = false

## --------------------------------------------------------------------------
## LÓGICA DE COMUNICACIÓN DE SCORE (Placeholder para Firebase)
## --------------------------------------------------------------------------

# Este método será llamado, por ejemplo, cuando el Board notifique un Game Over.
func submit_score(player_name: String, final_score: int):
	# En el futuro, esta será la función que llama a tu Autoload FirebaseManager.
	print("Enviando score a Firebase para el jugador ", player_name, " con puntaje: ", final_score)
	# FirebaseManager.submit_score(player_name, final_score)
	pass
	
