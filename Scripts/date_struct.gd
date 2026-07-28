extends Resource
class_name DateStruct

@export var year: int
@export var month: int
@export var day: int


static func is_the_same_day(date1: DateStruct, date2: DateStruct) -> bool:
	if date1.day == date2.day:
		if date1.month == date2.month:
			if date1.day == date2.day:
				return true
	return false
