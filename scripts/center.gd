extends CanvasLayer
@onready var obj = $DialogPanel

func compute_centered_window_position(window_size: Vector2) -> Vector2:
	return (get_viewport().size - window_size) / 2

func _ready():
	# Llamamos deferred para que el tamaño ya esté calculado
	call_deferred("_center_dialog")

func _center_dialog():
	var size = obj.get_combined_minimum_size()
	obj.rect_position = compute_centered_window_position(size)
