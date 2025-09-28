# GameOverScene.gd

extends CanvasLayer # ⬅️ IMPORTANTE: Ahora la escena extiende CanvasLayer

# Variable que recibirá el puntaje de la escena Board
var final_score: int = 0

# Las rutas @onready pueden necesitar ajustarse si cambiaste la estructura,
# pero asumo que siguen siendo correctas.
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var name_input: LineEdit = $VBoxContainer/NameInput
@onready var submit_button: Button = $VBoxContainer/Submit

func _ready():
	# 1. Muestra la puntuación recibida
	score_label.text = "YOUR FINAL SCORE: " + str(final_score)
	name_input.grab_focus()
	# 2. Conecta la acción al botón
	submit_button.pressed.connect(_on_submit_button_pressed)

func _on_submit_button_pressed():
	var player_name = name_input.text.strip_edges()
	
	# 💥 CORRECCIÓN: Usar is_empty() en Godot 4
	if player_name.is_empty(): 
		# Sugiere al jugador que ingrese un nombre
		name_input.placeholder_text = "¡ENTER YOUR NAME!"
		return
		
	# Deshabilita el botón mientras se guarda el puntaje
	submit_button.disabled = true
	submit_button.text = "Saving..."
	
	# 3. Guardar el puntaje en SilentWolf
	SilentWolf.Scores.save_score(player_name, final_score, "main")
	
	# 4. Iniciar el temporizador para el cambio de escena
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 1.0 # Espera 1 segundo
	timer.timeout.connect(_on_save_complete)
	timer.start()

func _on_save_complete():
	var tree = get_tree()
	# Vuelve al tablero (la escena principal)
	queue_free()
	tree.call_deferred("change_scene_to_file", "res://scenes/game.tscn") 
