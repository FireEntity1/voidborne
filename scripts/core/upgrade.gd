extends Window

const THEME = preload("res://resources/game.tres")

var upgrades = [
	{
		"name": "Strength 1",
		"cost": 3,
		"prereq": "none"
	},
	{
		"name": "Strength 2",
		"cost": 10,
		"prereq": "Strength 1"
	},
	{
		"name": "Range 1",
		"cost": 5,
		"prereq": "none"
	},
	{
		"name": "Range 2",
		"cost": 10,
		"prereq": "Range 1"
	}
]

func _ready() -> void:
	Global.state.light_shards = 20
	generate()

func generate():
	for child in $container/vbox.get_children():
		child.queue_free()
	for upgrade in upgrades:
		if upgrade.prereq != "none" and Global.state.upgrades[upgrade.prereq] == false or Global.state.upgrades[upgrade.name] == true:
			continue
		
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(700,64)
		var label = Label.new()
		label.custom_minimum_size = Vector2(260,0)
		label.add_theme_font_size_override("font_size",30)
		label.text = upgrade.name
		
		var button = Button.new()
		button.text = "Purchase (" + str(upgrade.cost) + " light shards)"
		button.add_theme_font_size_override("font_size",30)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		button.connect("button_up",_buy.bind(upgrade.name))
		
		hbox.add_child(label)
		hbox.add_child(button)
		
		$container/vbox.add_child(hbox)
	var button = Button.new()
	button.text = "close"
	button.add_theme_font_size_override("font_size",30)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	$container/vbox.add_child(button)
		
	button.connect("button_up",close)

func _buy(_name):
	var item
	for upgrade in upgrades:
		if upgrade.name == _name:
			item = upgrade
			break
	if Global.state.light_shards < item.cost:
		return
	Global.state.light_shards -= item.cost
	Global.state.upgrades[_name] = true
	Dialogic.emit_signal("signal_event","upgrade_" + item.name)
	print(_name, ", ", Global.state.light_shards, " left")
	generate()

func close():
	Global.mod_can_move(true)
	hide()
