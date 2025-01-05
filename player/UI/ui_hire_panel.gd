extends Control

#choose_unit = [sword_icon, archer_icon, horse_icon]

#func _ready() -> void:
#	pass

func _on_spire_pressed() -> void:
	#GLOBAL.build_tower(GLOBAL.unit_position)
	TURN_MANAGER.UNIT_TYPE = 0
	TURN_MANAGER.hire_unit("spire_", "spire", 2, 10, 100, 10)
	queue_free()
	GLOBAL.IS_MENU_SELECTED = false


func _on_archer_pressed() -> void:
	TURN_MANAGER.UNIT_TYPE = 1
	TURN_MANAGER.hire_unit("archer_", "archer", 2, 10, 100, 5)
	queue_free()
	GLOBAL.IS_MENU_SELECTED = false


func _on_knight_pressed() -> void:
	TURN_MANAGER.UNIT_TYPE = 2
	TURN_MANAGER.hire_unit("knight_", "knight", 4, 14, 100, 15)
	queue_free()
	GLOBAL.IS_MENU_SELECTED = false


func _on_notyet_pressed() -> void:
	queue_free()
	GLOBAL.IS_MENU_SELECTED = false
