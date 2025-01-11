extends Label

var previous_message : String
var current_message : String
var default_message : String = "..."

func _ready() -> void:
	self.text = default_message

# обновляем информацию на лейбле
func _process(_delta: float) -> void:
	if INFO_MANAGER.WHAT_HAPPENED != previous_message:
			current_message = INFO_MANAGER.WHAT_HAPPENED
			self.text = current_message
			previous_message = self.text
			await get_tree().create_timer(3).timeout
			self.text = default_message
