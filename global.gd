extends Node
func _ready() -> void:
	
  SilentWolf.configure({
	"api_key": "A7jg1j0SlS94MarMIrmzHaLH0qom1F9fCvAV3RA7",
	"game_id": "saikoro",
	"log_level": 1
  })

  SilentWolf.configure_scores({
	"open_scene_on_close": "res://scenes/control.tscn"
  })
