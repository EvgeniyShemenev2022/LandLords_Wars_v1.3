extends Sprite2D

@onready var menu_units = preload("res://player/UI/ui_hire_panel.tscn")
var mouse_on_building = false
var is_selected = false # имеется ввиду здание

# 
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click") and mouse_on_building == true and GLOBAL.IS_MENU_SELECTED == false:
		if self.is_in_group("Buildings_Player_%d" %[TURN_MANAGER.WHO_ARE_TURNED_NOW]): #только башни текущего игрока
			is_selected = true
			GLOBAL.POSITION_SELECTED_BUILDING = position
			var menu = menu_units.instantiate()
			self.add_child(menu)
			GLOBAL.IS_MENU_SELECTED = true


func _on_area_2d_mouse_entered() -> void:
	mouse_on_building = true

func _on_area_2d_mouse_exited() -> void:
	mouse_on_building = false
