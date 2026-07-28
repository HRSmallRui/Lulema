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
	var sav: AppSaver = AppSaver.get_app_saver()
	if sav == null:
		sav = AppSaver.new()
		AppSaver.save_app_saver(sav)
	var today_struct: DateStruct = DateStruct.new()
	today_struct.year = today.year
	today_struct.month = today.month
	today_struct.day = today.day
	for struct in sav.recorded_dates:
		if DateStruct.is_the_same_day(struct,today_struct):
			status_label.text = "今日已记录"
			break
	pass


func _on_button_pressed() -> void:
	
	pass # Replace with function body.
