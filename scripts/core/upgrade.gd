extends Window

var upgrades = [
	{
		"name": "Damage",
		"cost": 1
	},
	{
		"name": "Range",
		"cost": 3
	}
]

func _ready() -> void:
	Global.state.light_shards = 20
	for upgrade in upgrades:
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

func _buy(_name):
	var item
	for upgrade in upgrades:
		if upgrade.name == _name:
			item = upgrade
			break
	Global.state.light_shards -= item.cost
	print(_name, ", ", Global.state.light_shards, " left")
