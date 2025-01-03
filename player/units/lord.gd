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
	if TURN_MANAGER.units_col.has(self) == false:
		color_rect.visible = true 
		return
	else:
		color_rect.visible = false
		if self.is_in_group(TURN_MANAGER.CURRENT_PLYER[TURN_MANAGER.WHO_ARE_TURNED_NOW]) == true :
			if mouse_on_unit == true and event.is_action_pressed("left_click"):
					is_selected = true
					animation_player.play("selected")
					TURN_MANAGER.SELECTED_UNIT_POSITION = global_position # передаем в менеджер позицию объекта
					TURN_MANAGER.SELECTED_NODE = self as Node2D
					TURN_MANAGER.RAY_CAST_2D = ray_cast_2d # передаем детектор текущего персонажа
					print(stats)
					TURN_MANAGER.default_move = stats["base_turn"] # передаем базовые ходы текущего юнита
					TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить
					print(TURN_MANAGER.default_move)
					
					
			elif mouse_on_unit == false and event.is_action_pressed("left_click"):
					is_selected = false
					animation_player.stop()
	
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
		if is_in_defence == false:
			self.stats["status"] = "defence"
			self.stats["defence"] = stats.defence * 1.25
			d_label.visible = true
			animation_player.stop()
			is_in_defence = true
			TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить
		else:
			self.stats["status"] = "on_moving"
			self.stats["defence"] = stats.defence * 0.8
			d_label.visible = false
			animation_player.play("selected")
			is_in_defence = false
			TURN_MANAGER.IS_UNIT_IN_DEFENCE = is_in_defence # если юнит в обороне, он не должен ходить

# ПО СИГНАЛУ выключаем анимацию и ставим блок на выбор
func is_unit_finished_his_turn(SELECTED_NODE):
	if self == SELECTED_NODE:
		TURN_MANAGER.SELECTED_UNIT_TURN_IS_OVER = true
		animation_player.stop()

# сигналы, для селекта конкретного юнита
func _on_area_2d_mouse_entered() -> void:
	mouse_on_unit = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	#print("IN")

func _on_area_2d_mouse_exited() -> void:
	mouse_on_unit = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	#print("OUT")

func unit_was_attacked(attack_node, defence_node, damage, dam_for_att):
	if self == defence_node:
		progress_bar.visible = true
		progress_bar.value -= damage
		if stats["heath"] <= 0:
			queue_free()
	if self == attack_node:
		progress_bar.visible = true
		progress_bar.value -= dam_for_att
		if stats["heath"] <= 0:
			queue_free()
