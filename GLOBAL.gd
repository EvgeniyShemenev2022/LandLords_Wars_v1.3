extends Node

#var POSITION_SELECTED_UNIT : Vector2
signal update_label_value

var IS_MENU_SELECTED = false
var POSITION_SELECTED_BUILDING : Vector2

var RESOURCE_PL_1 = {"gold" : 5,
					 "food" : 5,
					 "production" : 5}
					
var RESOURCE_PL_2 = {"gold" : 5,
					 "food" : 5,
					 "production" : 5}
var gold_value_city :int = 1
var food_value_city :int = 1
var prod_value_city :int = 2

var GOLD_PER_TURN  = [0, 1, 1]
var PROD_PER_TURN  = [0, 2, 2]
var FOOD_PER_TURN  = [0, 1, 1]

func WHOSE_RESOURSE_TO_TAKE():
	if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 1:
		return RESOURCE_PL_1
	elif TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 2:
		return RESOURCE_PL_2

func CAPITAL_PRODUCT_EVERY_TURN():
	if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 1:
		GLOBAL.RESOURCE_PL_1["gold"] += gold_value_city
		GLOBAL.RESOURCE_PL_1["food"] += food_value_city
		GLOBAL.RESOURCE_PL_1["production"] += prod_value_city

	if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 2:
		GLOBAL.RESOURCE_PL_2["gold"] += gold_value_city
		GLOBAL.RESOURCE_PL_2["food"] += food_value_city
		GLOBAL.RESOURCE_PL_2["production"] += prod_value_city
	GLOBAL.update_label_value.emit()
