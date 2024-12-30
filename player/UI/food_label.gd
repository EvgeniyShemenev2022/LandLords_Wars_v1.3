extends Label

var numb :int = 5


func _ready() -> void:
	self.text = "Food: " + str(numb) 
	GLOBAL.update_label_value.connect(update_lab_val)



func update_lab_val():
	if TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 1:
		numb = GLOBAL.RESOURCE_PL_1["food"]
		self.text = "Food: " + str(numb) + str(" (+") + str(GLOBAL.FOOD_PER_TURN[1]) + str(")")
	elif TURN_MANAGER.NUMB_OF_PLAYER_WHO_TUNED == 2:
		numb = GLOBAL.RESOURCE_PL_2["food"]
		self.text = "Food: " + str(numb) + str(" (+") + str(GLOBAL.FOOD_PER_TURN[2]) + str(")") 
