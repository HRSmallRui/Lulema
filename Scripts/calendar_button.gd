extends Button
class_name CalendarButton

@onready var date_label: Label = $DateLabel
@onready var record_sprite: Sprite2D = $RecordSprite

var date_text: String
var current_date: DateStruct


func _ready() -> void:
	record_sprite.hide()
	date_label.text = date_text
	if current_date == null:
		record_sprite.hide()
	else:
		var sav: AppSaver = AppSaver.get_app_saver()
		if sav == null: return
		for date_struct in sav.recorded_dates:
			if DateStruct.is_the_same_day(current_date,date_struct):
				record_sprite.show()
				return
	pass
