extends Node

@onready var tower = preload("res://player/buildings/tower.tscn")
@onready var ferma = preload("res://player/buildings/ferma.tscn")
@onready var production = preload("res://player/buildings/production.tscn")
var IS_TOWER_JUST_BUILT = false
var IS_FERMA_JUST_BUILT = false
var IS_PRODUCTION_JUST_BUILT = false

const COST_FERMA = { "gold" : 5,
				   "production" : 4}
const COST_PROD = { "gold" : 6,
				   "production" : 6}
const COST_TOWER = { "gold" : 1,
				   "production" : 1}
# значения которые приносят здания за 1 ход игрока (решил сделать глобальными)
var GOLD_VALUE_FERMA :int = 1
var FOOD_VALUE_FERMA :int = 2
var GOLD_VALUE_PROD :int = 1
var PRODUCTION_VALUE_PROD :int = 2

func can_i_building(COST : Dictionary):
	if COST["gold"] > GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] or COST["production"] > GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"]:
		return false

# строим башню
func build_a_tower():
	if can_i_building(COST_TOWER) != false:
		if IS_TOWER_JUST_BUILT == false:
			var new_tower = tower.instantiate()
			var numb_of_player = str(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			var path = get_tree().get_root().get_node("WarField/%s/Buildings" % [numb_of_player]) 
			print(numb_of_player)
			path.add_child(new_tower)
			new_tower.add_to_group("Buildings_Player_%d" %[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			#WARNING !!! Buildings_Player_0 (первый игрок); Buildings_Player_1 (второй)  ПЕРЕДЕЛАТЬ на норм
			new_tower.position = TURN_MANAGER.SELECTED_UNIT_POSITION
			IS_TOWER_JUST_BUILT = true # не даем построить больше одной башни за ход
			
			# вычитаем стоимость башни из ресурсов игрока
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] -= COST_TOWER["gold"]
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"] -= COST_TOWER["production"]
			GLOBAL.update_label_value.emit()


# строим ферму
func buld_a_ferma():
	if can_i_building(COST_FERMA) != false:
		if IS_FERMA_JUST_BUILT == false:
			var new_ferma = ferma.instantiate()
			var numb_of_player = str(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			var path = get_tree().get_root().get_node("WarField/%s/Buildings" % [numb_of_player])
			path.add_child(new_ferma)
			new_ferma.add_to_group("Buildings_Player_%d" %[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			#WARNING !!! Buildings_Player_0 (первый игрок); Buildings_Player_1 (второй)  ПЕРЕДЕЛАТЬ на норм
			new_ferma.position = TURN_MANAGER.SELECTED_UNIT_POSITION
			IS_FERMA_JUST_BUILT = true # не даем построить больше одной башни за ход
			GLOBAL.FOOD_PER_TURN[TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED] += FOOD_VALUE_FERMA # info for label
			GLOBAL.GOLD_PER_TURN[TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED] += GOLD_VALUE_FERMA # info for label
			# вычитаем стоимость фермы из ресурсов игрока
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] -= COST_FERMA["gold"]
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"] -= COST_FERMA["production"]
			GLOBAL.update_label_value.emit()
			print("ФЕРМА ПОСТРОЕНА")

# строим производство
func buld_a_production():
	if can_i_building(COST_PROD) != false:
		if IS_FERMA_JUST_BUILT == false:
			var new_production = production.instantiate()
			var numb_of_player = str(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			var path = get_tree().get_root().get_node("WarField/%s/Buildings" % [numb_of_player])
			path.add_child(new_production)
			new_production.add_to_group("Buildings_Player_%d" %[TURN_MANAGER.WHO_ARE_TURNED_NOW])
			#WARNING !!! Buildings_Player_0 (первый игрок); Buildings_Player_1 (второй)  ПЕРЕДЕЛАТЬ на норм
			new_production.position = TURN_MANAGER.SELECTED_UNIT_POSITION
			IS_PRODUCTION_JUST_BUILT = true # не даем построить больше одной башни за ход
			GLOBAL.GOLD_PER_TURN[TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED] += GOLD_VALUE_PROD # info for label
			GLOBAL.PROD_PER_TURN[TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED] += PRODUCTION_VALUE_PROD # info for label
			# вычитаем стоимость производства из ресурсов игрока
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] -= COST_PROD["gold"]
			GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"] -= COST_PROD["production"]
			GLOBAL.update_label_value.emit()

#%TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]%
