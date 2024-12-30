extends Control


func _on_yes_pressed() -> void:
	MANAGER.build_a_tower()
	queue_free()


func _on_no_pressed() -> void:
	queue_free()
