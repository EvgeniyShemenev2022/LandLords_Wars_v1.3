extends Node

signal SELECTED_NODE_END_TURN(SELECTED_NODE : Node2D)
signal CHANGE_CAM_POSITION(units_col : Array)
signal CHANGE_TURN
signal UNIT_STRIKES(attack_node : Node2D, defence_node : Node2D, damage : int, dam_for_att_full : int, is_attacker_stronger : bool) # если юнит атакует - посылаем сигнал в его узел
var CURRENT_TURN : int = 1
var WHO_ARE_TURNED_NOW :int = 0 # индекс в массиве
const CURRENT_PLYER = ["Player_1", "Player_2"]
var NUMB_OF_PLAYER_WHO_TUNED :int # некрасивое решение, нужно придумать единый метод дял поика игрока
var SELECTED_UNIT_TURN_IS_OVER = false 
var units_col = []
var UNIT_TYPE :int = 3 # соответствует номеру в массиве юнитов
var numb_of_unit :int = 1
@onready var warrior = preload("res://player/units/lord.tscn")
var IS_UNIT_IN_DEFENCE = false
var UNIT_CANT_MOVE = false #костыль, используется когда выбрали юнита, а затем сняли выбор мышкой
var ARCHER_IS_SELECTED = false

var default_move : int = 2
var current_move : int = 1
var SELECTED_UNIT_POSITION : Vector2 = Vector2.ZERO # позиция выбранного юнита
var SELECTED_NODE : Node2D # выбранный юнит конвертит себя в ноду и передает сюда для последующих манипуляций
var RAY_CAST_2D : RayCast2D 
var COLLIDING_NODE : Node2D
@onready var tile_map_layer: TileMapLayer = get_tree().get_root().get_node("/root/WarField/TileMapLayer")   

const COST_SPIRE = { "gold" : 2,
					 "production" : 2,
					 "food" : 4}
const COST_ARCHER = { "gold" : 2,
					  "production" : 2,
					  "food" : 4}
const COST_KNIGHT = { "gold" : 6,
					 "production" : 6,
					 "food" : 6}

func _ready() -> void:
	#get_all_units_by_player()
	#print(units_col)
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if units_col.has(SELECTED_NODE) == true and IS_UNIT_IN_DEFENCE == false: #and UNIT_CANT_MOVE == false:
		if event.is_action_pressed("ui_down"):
			move(Vector2.DOWN)
		elif event.is_action_pressed("ui_up"):
			move(Vector2.UP)
		elif event.is_action_pressed("ui_left"):
			move(Vector2.LEFT)
		elif event.is_action_pressed("ui_right"):
			move(Vector2.RIGHT)
		
		# у юнита (заканчиваются ходы), удаляем ноду из массива, сигнал на снятие анимации и запрет на выбор
		if SELECTED_NODE.stats["base_turn"] <= 0:
			var unit_index = find_index_of_selected_unit_by_name(SELECTED_NODE)
			#print(unit_index)
			delete_unit_from_array(unit_index)
			print(units_col)
			
			#WARNING переделать в функцию, после неполного хода юнитом его ходы нужно принудительно обнулить
			# после завершения всех ходов 
			var a = SELECTED_NODE.stats
			if a["type"] == "spire":
				SELECTED_NODE.stats["base_turn"] = 2
			elif a["type"] == "archer":
				SELECTED_NODE.stats["base_turn"] = 2
			elif a["type"] == "lord":
				SELECTED_NODE.stats["base_turn"] = 2
				print("попал в МЭТЧ")
			elif a["type"] == "knight":
				SELECTED_NODE.stats["base_turn"] = 4
			#default_move = 2
			
			self.SELECTED_NODE_END_TURN.emit(SELECTED_NODE)
			
			if units_col.size() == 0:
				change_turn()

func move(direction: Vector2):
	var current_tile : Vector2i = tile_map_layer.local_to_map(SELECTED_UNIT_POSITION)
	var target_tile : Vector2i = Vector2i (
		current_tile.x + direction.x,
		current_tile.y + direction.y
	)
	prints("текущий тайл:  ", current_tile, ";    цель:  ", target_tile)
	
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(target_tile)
	
	if tile_data.get_custom_data("walkable") == false:
		return
	
	RAY_CAST_2D.target_position = direction * 16
	RAY_CAST_2D.force_raycast_update()
	if RAY_CAST_2D.is_colliding():
		COLLIDING_NODE = RAY_CAST_2D.get_collider().get_parent()
		if COLLIDING_NODE.is_in_group(CURRENT_PLYER[WHO_ARE_TURNED_NOW]):
			return
		else:
			print("ATTACK!   ",COLLIDING_NODE)
			FIGHT(SELECTED_NODE, COLLIDING_NODE)
			
			return
	
	SELECTED_NODE.global_position = tile_map_layer.map_to_local(target_tile)
	SELECTED_UNIT_POSITION = SELECTED_NODE.global_position
	#icon.global_position = tile_map_layer.map_to_local(current_tile)
	current_turn_is_ok()
	print(SELECTED_NODE.stats["base_turn"], " - ", current_move)
	
func what_type_of_unit(type: String):
	if type == "spire": 		return COST_SPIRE
	elif type == "archer": 		return COST_ARCHER
	elif type == "knight": 		return COST_KNIGHT

# обновить/пересчитать массив юнитов
func recount_units_in_arr():
	units_col.clear()
	get_all_units_by_player()
	#print(units_col)

# все юниты игрока
func get_all_units_by_player():
	units_col.append_array(get_tree().get_nodes_in_group(CURRENT_PLYER[WHO_ARE_TURNED_NOW]))
	print("func get_all_units_by_player    ", get_tree().get_nodes_in_group(CURRENT_PLYER[WHO_ARE_TURNED_NOW]))

# определяем чей сейчас ход (нажатие на кнопку)
func start_turn():
	if CURRENT_TURN % 2 != 0:
		WHO_ARE_TURNED_NOW = 0
		NUMB_OF_PLAYER_WHO_TUNED = 1
	elif CURRENT_TURN % 2 == 0:
		WHO_ARE_TURNED_NOW = 1
		NUMB_OF_PLAYER_WHO_TUNED = 2
	print("now is turn of   ", CURRENT_PLYER[WHO_ARE_TURNED_NOW])
	recount_units_in_arr()
	self.CHANGE_CAM_POSITION.emit(units_col) # переходим на след.игрока


# ищем индекс элемента в массиве юнитов игрока, который сейчас ходит
func find_index_of_selected_unit_by_name(SELECTED_NODE):
	for i in units_col:
		if i.name == SELECTED_NODE.name:
			#print("!!!!   ",  units_col.find(i) )
			return units_col.find(i)

func delete_unit_from_array(index_of_element: int):
	units_col.remove_at(index_of_element)

# смена хода игрока | сброс разных настроек к дефолту
func change_turn():
	CURRENT_TURN += 1
	start_turn()
	recount_units_in_arr()
	self.CHANGE_CAM_POSITION.emit(units_col) # переходим на след.игрока
	MANAGER.IS_TOWER_JUST_BUILT = false
	MANAGER.IS_FERMA_JUST_BUILT = false
	MANAGER.IS_PRODUCTION_JUST_BUILT = false
	GLOBAL.CAPITAL_PRODUCT_EVERY_TURN()
	self.CHANGE_TURN.emit()

# создаем юнита
func hire_unit(name, type, base_turn, power, heath, defence):
	if can_i_hire_this_unit(what_type_of_unit(type)) != false:
		var warrior_new = warrior.instantiate()
		warrior_new.name = name + str(numb_of_unit)
		var numb_of_player = str(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) #кто именно сейчас ходит
		var path = get_tree().get_root().get_node("WarField/%s/Units" %[numb_of_player])
		path.add_child(warrior_new)
		warrior_new.global_position = GLOBAL.POSITION_SELECTED_BUILDING
		warrior_new.add_to_group(numb_of_player)
		if warrior_new.is_in_group("Player_2"): # color of unit
			warrior_new.get_node("icon").modulate = Color.BLACK
		# присваиваем статы нашему юниту (не знаю как записать в одну строку)
		warrior_new.stats["type"] = type
		warrior_new.stats["base_turn"] = base_turn
		warrior_new.stats["power"] = power
		warrior_new.stats["heath"] = heath
		warrior_new.stats["defence"] = defence
		warrior_new.stats["status"] = "on moving"

		units_col.append(warrior_new)
		numb_of_unit += 1
		
		# вычитаем стоимость башни из ресурсов игрока
		GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] -= what_type_of_unit(type)["gold"]
		GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"] -= what_type_of_unit(type)["production"]
		GLOBAL.WHOSE_RESOURSE_TO_TAKE()["food"] -= what_type_of_unit(type)["food"]

		GLOBAL.update_label_value.emit()

# вызывается в move(), только если юнит реально потратил ход
func current_turn_is_ok():
	if SELECTED_NODE.stats["base_turn"] > 0:
		SELECTED_NODE.stats["base_turn"] -= current_move

func can_i_hire_this_unit(COST : Dictionary):
	if COST["gold"] > GLOBAL.WHOSE_RESOURSE_TO_TAKE()["gold"] or COST["production"] > GLOBAL.WHOSE_RESOURSE_TO_TAKE()["production"] or COST["food"] > GLOBAL.WHOSE_RESOURSE_TO_TAKE()["food"]:
		return false

# добавить в парамерты тип местности и бонусы от флангов
func FIGHT(attack_node, defence_node):
	print(attack_node.name)
	print(defence_node.name)
	var ratio :float = 0 #сотношение сил
	var ratio_2 :float = 0 #прогрессия эффекта урона от увеличения соотношения сил 
	var base_damage = 30
	var damage
	var attacker_is_stronger = true
	var def_health = (100 - defence_node.stats["heath"]) * 0.5
	var att_health = (100 - attack_node.stats["heath"]) * 0.5
	var defence_bonus = 0.0
	var bonus_vs_enemy_att = 0.0
	var bonus_vs_enemy_def = 0.0
	var bonus_first = 0.20 #бонус за инициативу в нападении
	var dam_for_att = 0.0 #коэффициент урона для атакующего
	
	if defence_node.stats["status"] == "defence":
		defence_bonus = 0.4
	
	if attack_node.stats["type"] == "spire" and defence_node.stats["type"] == "knight":
		bonus_vs_enemy_att = 1.0
	elif attack_node.stats["type"] == "knight" and defence_node.stats["type"] == "spire":
		bonus_vs_enemy_def = 1.0
	elif attack_node.stats["type"] == "knight" and defence_node.stats["type"] == "archer":
		bonus_vs_enemy_att = 1.0
	elif attack_node.stats["type"] == "archer" and defence_node.stats["type"] == "knight":
		bonus_vs_enemy_att = 0.9
	elif attack_node.stats["type"] == "archer" and defence_node.stats["type"] == "spire":
		bonus_vs_enemy_att = 0.9
	elif attack_node.stats["type"] == "spire" and defence_node.stats["type"] == "archer":
		bonus_vs_enemy_att = 1.0

	# начинаем проверку соотношения сил; может оказаться, что нападающий - слабее, тогда меняем соотношение в обр.сторону
	ratio = (attack_node.stats["power"] * (1 + bonus_first + bonus_vs_enemy_att)) / (defence_node.stats["power"] * (1 + defence_bonus + bonus_vs_enemy_def))
	print("RATIO:  ", ratio)
	if ratio > 1:
		attacker_is_stronger = true
		ratio_2 = abs(1.0 - ratio)
	else: 
		attacker_is_stronger = false
		ratio = (defence_node.stats["power"] * (1 + defence_bonus + bonus_vs_enemy_def)) / (attack_node.stats["power"] * (1 + bonus_first + bonus_vs_enemy_att))
		ratio_2 = abs(1.0 - ratio)
	print("RATIO:  ", ratio)
	print("ratio_2:  ", ratio_2)
	
	# коэффициент урона для атакующего, чем слабее другой юнит, тем меньше урона наносишь себе
	if int(ratio*10) in range(10, 12):
		dam_for_att = 0.6
	elif int(ratio*10) in range(12, 13):
		dam_for_att = 0.5
	elif int(ratio*10) in range(13, 15):
		dam_for_att = 0.3
	elif int(ratio*10) in range(15, 16):
		dam_for_att = 0.2
	elif int(ratio*10) in range(16, 19):
		dam_for_att = 0.15
	
	# базовый + отношение сил - неполное_здоровье_нападающего + неполное здоровье обороняющегося (чем он слабее тем сильнее урон)
	damage = (base_damage + (base_damage * ratio_2) - att_health + def_health)
	var dam_for_att_full :int = int(damage * dam_for_att)
	print("DAMAGE:  ", damage)
	print("dam_for_att_full ", dam_for_att_full)
	print("attacker_is_stronger: ", attacker_is_stronger)
	
	#меняем статы и отправляем сигналы в лейблы
	if attack_node.stats["type"] == "archer":
		defence_node.stats["heath"] -= damage
		dam_for_att_full = 0
		attacker_is_stronger = true
	else:
		if attacker_is_stronger == true:
			defence_node.stats["heath"] -= damage
			attack_node.stats["heath"] -= dam_for_att_full
		elif attacker_is_stronger == false:
			defence_node.stats["heath"] -= dam_for_att_full
			attack_node.stats["heath"] -= damage

	# изначально передавал COLLIDING_NODE и при атаке лучника ничего не передавалось
	self.UNIT_STRIKES.emit(SELECTED_NODE, defence_node, damage, dam_for_att_full, attacker_is_stronger) # посылаем сигнал в ноду атакуемого юнита
	
	# после атаки юнит теряет все ходы
	var unit_index = find_index_of_selected_unit_by_name(SELECTED_NODE)
	delete_unit_from_array(unit_index)
	print(units_col)
	self.SELECTED_NODE_END_TURN.emit(SELECTED_NODE)
