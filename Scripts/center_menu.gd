extends Control

@onready var background: ColorRect = $Background
@onready var status_label: Label = $VBox/StatusLabel
@onready var streak_label: Label = $VBox/StreakLabel
@onready var button: Button = $VBox/CenterContainer/Button


func _ready() -> void:
	background.hide()
	update_state()
	pass


func update_state():
	var today = Time.get_datetime_dict_from_system()
	print(today)
	pass


func _on_button_pressed() -> void:
	
	pass # Replace with function body.
