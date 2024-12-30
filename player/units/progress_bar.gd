extends ProgressBar


func _ready() -> void:
	self.max_value = get_parent().stats["heath"]
	self.value = max_value
	
