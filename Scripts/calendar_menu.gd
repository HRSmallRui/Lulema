extends Control
class_name CalendarMenu

static var instance: CalendarMenu

@export var calendar_button_scene: PackedScene

# ---- 引用场景节点 ----
@onready var grid: GridContainer = $VBox/Grid
@onready var month_label: Label = $VBox/MonthHeader/MonthLabel
@onready var prev_button: Button = $VBox/MonthHeader/PrevButton
@onready var next_button: Button = $VBox/MonthHeader/NextButton
@onready var background: ColorRect = $Background

# ---- 日历逻辑 ----
var cal = Calendar.new()
var current_year: int
var current_month: int

# ---- 记录数据（从DataManager获取） ----
# 假设你有一个 DataManager 单例，里面存了 record_dates: Array[Calendar.Date]
# 如果没有，先建一个空数组顶替


func _init() -> void:
	instance = self
	pass


func _ready():
	background.hide()
	
	# 设置每周从周日开始（匹配你的星期头）
	cal.first_weekday = Time.WEEKDAY_SUNDAY
	
	# 初始化为当前月份
	var today = cal.get_today()
	current_year = today.year
	current_month = today.month
	
	# 连接切换按钮信号
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	
	render_calendar()


func render_calendar():
	# 1. 清空日期网格
	for child in grid.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	# 2. 更新月份标签
	month_label.text = "%d年%d月" % [current_year, current_month]
	
	# 3. 获取当月日历数据（包含6周，不包含相邻月日期）
	var month_data = cal.get_calendar_month(current_year, current_month, false, true)
	
	# 4. 遍历并生成格子
	for week in month_data:
		for cell in week:
			var btn: CalendarButton = calendar_button_scene.instantiate()
			
			# 让格子均匀填满
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
			btn.custom_minimum_size = Vector2(160, 160)  # 根据你的尺寸调整
			# 字体大小
			btn.add_theme_font_size_override("font_size", 32)
			
			if cell is Calendar.Date:
				# ---- 本月日期 ----
				btn.date_text = str(cell.day)
				
				# 检查是否有记录（从DataManager获取）
				if DataManager.has_record(cell):
					_apply_record_marker(btn)
				
				# 高亮今天
				var today = cal.get_today()
				if cell.is_equal(today):
					btn.modulate = Color(0.2, 0.6, 1.0)  # 淡蓝色
					# 或者加边框：暂时用颜色表示
				var date_struct: DateStruct = DateStruct.new()
				date_struct.year = current_year
				date_struct.month = current_month
				date_struct.day = cell.day
				btn.current_date = date_struct
			else:
				# ---- 空占位（不属于本月） ----
				btn.date_text = ""
				btn.disabled = true
				btn.modulate = Color(0.5, 0.5, 0.5, 0.3)
			grid.add_child(btn)


# 给有记录的日期添加标记（鹿蹄印）
func _apply_record_marker(btn: Button):
	# 方案A：用Emoji（简单粗暴）
	# 注意：如果你之前用了 btn.text = str(cell.day)，这里可以在前面加🦌
	# 但因为我们是在格子生成时调用，建议直接在生成时处理
	# 此处改用颜色标记
	btn.modulate = Color(0.9, 0.7, 0.3)  # 鹿棕色
	
	# 方案B：如果有图片，用 TextureRect 叠加
	# var icon = TextureRect.new()
	# icon.texture = load("res://hoofprint.png")
	# icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	# icon.custom_minimum_size = Vector2(20, 20)
	# btn.add_child(icon)


# ---- 月份切换 ----
func _on_prev_pressed():
	current_month -= 1
	if current_month < 1:
		current_month = 12
		current_year -= 1
	render_calendar()

func _on_next_pressed():
	current_month += 1
	if current_month > 12:
		current_month = 1
		current_year += 1
	render_calendar()


# ---- 当页面可见时刷新（可选） ----
#func _notification(what):
	#await get_tree().process_frame
	#if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
		#render_calendar()
