extends Label

func _process(delta: float) -> void:
	text = "Turn " + str(TURN_MANAGER.CURRENT_TURN) + "  \n" + str(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW])
