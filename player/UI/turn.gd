extends Button


func _ready() -> void:
	self.text = "BEGIN"
	self.visible = true

func _on_pressed() -> void:
	if self.text == "BEGIN":
		TURN_MANAGER.start_turn()
		self.text = "SKIP"
	else:
		TURN_MANAGER.change_turn()
		#print(TURN_MANAGER.SELECTED_NODE.is_selected)
		#print(typeof(TURN_MANAGER.SELECTED_NODE))
