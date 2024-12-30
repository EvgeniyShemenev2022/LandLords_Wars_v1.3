extends Camera2D

var element_in_array : int = 1
var target_zoom : float = 1.0

var zoom_min = Vector2(1.0,1.0)
var zoom_max = Vector2(2,2)
var zoom_speed = Vector2(0.05,0.05)

func _ready() -> void:
	TURN_MANAGER.CHANGE_CAM_POSITION.connect(change_cam_position)

#func _process(delta: float) -> void:
	#self.global_position = get_global_mouse_position()

# передвижение камеры средней кнопкой мыши
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative / zoom


func _input(event: InputEvent) -> void:
	
	# ZOOM по нажатию клавиши
	if event.is_action_pressed("map"): 
		if self.zoom == Vector2(1.5,1.5):
			self.zoom = Vector2(1,1)
		else: 
			self.zoom = Vector2(1.5,1.5)
	
	# Смена юнита по нажатию клавиши
	if event.is_action_pressed("next_unit"):
		var all_units_in_array : int = TURN_MANAGER.units_col.size()
		if element_in_array > all_units_in_array: element_in_array = 1
		self.global_position = TURN_MANAGER.units_col[all_units_in_array - element_in_array].global_position
		element_in_array += 1


	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if zoom > zoom_min:
					zoom -= zoom_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if zoom < zoom_max:
					zoom += zoom_speed
	pass

func change_cam_position(units_array):
	if units_array.size() <= 0:
		return
	var first_unit = units_array[0]   #units_array[0]
	print(first_unit)
	self.global_position = first_unit.global_position
	print(self.global_position)
