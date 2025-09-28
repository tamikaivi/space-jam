# LeaderboardEntry.gd
extends Control

# Elimina las variables @onready
# @onready var rank_label = $HBoxContainer/rank
# @onready var name_label = $HBoxContainer/name
# @onready var score_label = $HBoxContainer/score
# ---------------------------------------------------

func set_data(rank: int, name: String, score: int):
	# Obtenemos y verificamos las referencias antes de usarlas
	
	# Opción 1: Usar get_node_or_null (Requiere ruta exacta)
	var rank_label = get_node_or_null("HBoxContainer/rank")
	var name_label = get_node_or_null("HBoxContainer/name")
	var score_label = get_node_or_null("HBoxContainer/score")
	
	if rank_label and name_label and score_label:
		# Si todos existen, asigna el texto
		print("rank =>", rank_label,"name => ",name_label,"score =>",score_label)
		rank_label.text = str(rank) + "." 
		name_label.text = name
		score_label.text = str(score)
	else:
		# Si no existen, imprime un error de depuración útil
		push_error("ERROR: No se pudieron encontrar todos los Labels dentro de HBoxContainer. Revise la escena LeaderboardEntry.tscn y los nombres 'rank', 'name', 'score'.")
