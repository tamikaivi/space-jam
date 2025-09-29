# AudioPlayer.gd
extends Node

# AudioStreamPlayer para música de fondo
var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
# AudioStreamPlayer para efectos de sonido
var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(bgm_player)
	add_child(sfx_player)
	
	# Propiedades para que la música se repita
	bgm_player.bus = "Music" # Opcional: Para controlar volumen separado
	bgm_player.autoplay = false
	bgm_player.finished.connect(_on_bgm_finished)

func play_bgm(music_stream: AudioStream):
	# Detiene la música actual si está sonando
	if bgm_player.playing:
		bgm_player.stop()
	
	bgm_player.stream = music_stream
	bgm_player.play()

func play_sfx(sfx_stream: AudioStream):
	sfx_player.stream = sfx_stream
	sfx_player.play()

func _on_bgm_finished():
	# Repite la música cuando termina (si tiene stream)
	if bgm_player.stream:
		bgm_player.play()
