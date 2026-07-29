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
	for upgrade in upgrades:
		var hbox = HBoxContainer.new()
		var label = Label.new()
		label.add_theme_font_size_override("font_size",30)
		label.text = upgrade.name
		
		var button = Button.new()
		button.text = "Purchase (" + str(upgrade.cost) + " light shards)"
		button.add_theme_font_size_override("font_size",30)
		
		button.connect("button_up",_buy.bind(upgrade.name))
		
		hbox.add_child(label)
		hbox.add_child(button)
		
		$container/vbox.add_child(hbox)

func _buy(name):
	print(name)
