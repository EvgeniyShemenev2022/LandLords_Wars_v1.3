extends Sprite2D


func _ready() -> void:
	TURN_MANAGER.CHANGE_TURN.connect(maining_resourse)


func maining_resourse():
	if self.is_in_group("Buildings_Player_0"):
		if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 1:
			GLOBAL.RESOURCE_PL_1["gold"] += MANAGER.GOLD_VALUE_FERMA
			GLOBAL.RESOURCE_PL_1["food"] += MANAGER.FOOD_VALUE_FERMA
	elif self.is_in_group("Buildings_Player_1"):
		if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 2:
			GLOBAL.RESOURCE_PL_2["gold"] += MANAGER.GOLD_VALUE_FERMA
			GLOBAL.RESOURCE_PL_2["food"] += MANAGER.FOOD_VALUE_FERMA

	GLOBAL.update_label_value.emit()
