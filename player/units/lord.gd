extends Sprite2D

@onready var icon: Sprite2D = $icon
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var tile_map_layer: TileMapLayer = get_tree().get_root().get_node("WarField/TileMapLayer")
@onready var building_panel = preload("res://player/UI/ui_building_panel.tscn")

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect: ColorRect = $ColorRect # подсвечиваем, чей ход закончен
@onready var d_label: Label = $D_label


var lord_icon = preload("res://player/units/icons/crown1.png")
var spear_icon = preload("res://player/units/icons/spear.png")
var archer_icon = preload("res://player/units/icons/archery1.png")
var horse_icon = preload("res://player/units/icons/horseshoer.png")
var choose_unit = [spear_icon, archer_icon, horse_icon, lord_icon]

var is_moving = false
var mouse_on_unit = false
var is_selected = false
var is_in_defence = false
var archer_can_shooting = false

var stats = {"type" : "lord",
			"base_turn" : 2,
			"power" : 10,
			"heath" : 100,
			"defence" : 5,
			"status" : "on_moving"} # "on_moving", "defence"


func _ready() -> void:
	if self.is_in_group("Player_2"):
		icon.modulate = Color.BLACK
	var u_type = TURN_MANAGER.UNIT_TYPE
	get_node("icon").texture = choose_unit[u_type]
	TURN_MANAGER.SELECTED_NODE_END_TURN.connect(is_unit_finished_his_turn)
	TURN_MANAGER.UNIT_STRIKES.connect(unit_was_attacked)


#func _physics_process(delta: float) -> void:

	#icon.global_position = icon.global_position.move_toward(global_position, 2)
	#Global.POSITION_SELECTED_UNIT = icon.global_position


func _input(event: InputEvent) -> void:
	#print("TURN_MANAGER.ARCHER_IS_SELECTED: ", TURN_MANAGER.ARCHER_IS_SELECTED)
	# возможно это нужно перенести в обычную функцию
	if TURN_MANAGER.units_col.has(self) == false: #and TURN_MANAGER.ARCHER_IS_SELECTED == false:
		color_rect.visible = true
		#return
	else:
		color_rect.visible = false
		if self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == true and  mouse_on_unit == true and event.is_action_released("left_click"):
			is_selected = true
			#TURN_MANAGER.UNIT_CANT_MOVE = false
			animation_player.play("selected")
			TURN_MANAGER.SELECTED_UNIT_POSITION = global_position # передаем в менеджер позицию объекта
			TURN_MANAGER.SELECTED_NODE = self as Node2D
			TURN_MANAGER.RAY_CAST_2D = ray_cast_2d # передаем детектор текущего персонажа
			print(stats)
			TURN_MANAGER.default_move = stats["base_turn"] # передаем базовые ходы текущего юнита
			TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить
			print("Ходы: ", TURN_MANAGER.default_move)
			if self.stats["type"] == "archer": #даем возможность лучнику щелкать по цели, передавая инфу в FIGHT()
				TURN_MANAGER.ARCHER_IS_SELECTED = true
				print("archer_is_selected: ", TURN_MANAGER.ARCHER_IS_SELECTED)
		elif self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == true and mouse_on_unit == false and is_selected == true and event.is_action_released("left_click") and archer_can_shooting == false:
				is_selected = false
				TURN_MANAGER.ARCHER_IS_SELECTED = false
				animation_player.stop()
				#TURN_MANAGER.UNIT_CANT_MOVE = true
	
	# вызываем панель строительства зданий
	if mouse_on_unit == true and event.is_action_pressed("right_click") and is_selected == true and self.name == "Lord":
		var ui_build_panel = building_panel.instantiate()
		self.add_child(ui_build_panel) # создали панель строительства
	
	# при нажатии буквы F строится ферма, нужно переделать панель строительства на УНИВЕИСАЛЬНУЮ!!!
	if event.is_action_pressed("ferma") and is_selected == true and self.name == "Lord":
		MANAGER.buld_a_ferma()
	if event.is_action_pressed("production") and is_selected == true and self.name == "Lord":
		MANAGER.buld_a_production()
	#состояние юнита при обороне (клавиша D)
	if event.is_action_pressed("defence") and is_selected == true:
		if self.stats["type"] == "knight":
			INFO_MANAGER.WHAT_HAPPENED = "Рыцари не могут укрепляться и получать бонус от обороны"
			return
		if is_in_defence == false:
			self.stats["status"] = "defence"
			self.stats["defence"] = stats.defence * 1.25 # решил отказаться от этого параметра
			d_label.visible = true
			animation_player.stop()
			is_in_defence = true
			TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить
		elif is_in_defence == true:
			self.stats["status"] = "on_moving"
			self.stats["defence"] = stats.defence * 0.8
			d_label.visible = false
			animation_player.play("selected")
			is_in_defence = false
			TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить
	# условие для лучника
	if self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == false:
		if mouse_on_unit == true and TURN_MANAGER.ARCHER_IS_SELECTED == true and event.is_action_released("right_click"):
			print("МОЖНО КЛИКАТЬ И СТРЕлЯТЬ")
			var pos_archer = tile_map_layer.local_to_map(TURN_MANAGER.SELECTED_NODE.global_position)
			var self_defence = tile_map_layer.local_to_map(self.global_position)
			var distance = abs(pos_archer - self_defence)
			#print("pos_archer: ", pos_archer)
			#print("self_defence: ", self_defence)
			if distance.x > 2 or distance.y > 2:
				print("TO FARE!!!")
				INFO_MANAGER.WHAT_HAPPENED = "TO FARE!!!"
			else:
				print("ВЫСТРЕЛ!")
				TURN_MANAGER.FIGHT(TURN_MANAGER.SELECTED_NODE, self as Node2D)
				INFO_MANAGER.WHAT_HAPPENED = self.name + " атакован лучником"

# ПО СИГНАЛУ выключаем анимацию и ставим блок на выбор
func is_unit_finished_his_turn(SELECTED_NODE):
	if self == SELECTED_NODE:
		TURN_MANAGER.SELECTED_UNIT_TURN_IS_OVER = true
		animation_player.stop()

# сигналы, для селекта конкретного юнита
func _on_area_2d_mouse_entered() -> void:
	mouse_on_unit = true
	#print("mouse_on_unit  ", mouse_on_unit)
	#Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	print("IN")

func _on_area_2d_mouse_exited() -> void:
	mouse_on_unit = false
	#print("mouse_on_unit  ", mouse_on_unit)
	#Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	print("OUT")

func unit_was_attacked(attack_node, defence_node, damage, dam_for_att_full, attacker_is_stronger):
	var damage_actual = damage
	var dam_for_att_full_actual = dam_for_att_full
	
	#как и в функции FIGHT убеждаемся, что тот кто нападал - сильнее, если нет - меняем местами переменные
	if attacker_is_stronger == false:
		damage_actual = dam_for_att_full
		dam_for_att_full_actual = damage
	
	if self == defence_node:
		progress_bar.visible = true
		progress_bar.value -= damage_actual
		if stats["heath"] <= 0:
			queue_free()
	if self == attack_node:
		progress_bar.visible = true
		progress_bar.value -= dam_for_att_full_actual
		if stats["heath"] <= 0:
			queue_free()
	#get_global_mouse_position()



func _on_archer_shot_area_mouse_entered() -> void:
	prints("Юнит: ", self,  self.get_groups() )
	print(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW])
	if TURN_MANAGER.ARCHER_IS_SELECTED == true:
		print("ARCHER_IS_SELECTED == true")
		if self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == false:
			archer_can_shooting = true
			print("archer_can_shooting - ",archer_can_shooting )

func _on_archer_shot_area_mouse_exited() -> void:
	if TURN_MANAGER.ARCHER_IS_SELECTED == true:
		if self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == false:
			archer_can_shooting = false
			print("archer_can_shooting - ",archer_can_shooting )
