extends ProgressBar


func _ready() -> void:
	#print("PROGRESS BAR:  ", get_parent().name)
	self.max_value = get_parent().stats["heath"]
	self.value = max_value
