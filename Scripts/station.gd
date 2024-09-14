extends "res://Scripts/interactable_item.gd"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var percentage: Label = $Percentage

var state: String = 'empty'
var duration: float = 15
var elapsed_time: float = 0.0

@export var station: String = 'forge'

const stations = {
	'forge': {
		'empty': 'iron_ore',
		'emtpy_text': 'You need Iron Ore to start the forge',
		'ready': 'iron_ingot',
		'duration':5 # value for testing
	},
	'anvil': {
		'empty': 'iron_ingot',
		'emtpy_text': 'You need Iron Ingot to start the anvil',
		'ready': 'dull_sword',
		'duration':0.1# value for testing
	},
	'whetstone': {
		'empty': 'dull_sword',
		'emtpy_text': 'You need a Dull Sword to start the whetstone',
		'ready': 'finished_sword',
		'duration': 0.1# value for testing
	}
}

var current_item = ItemsType.create_item("")

func _ready() -> void:
	message_base = "Press SPACE to interact"
	tooltip.visible = false
	percentage.visible = false
	percentage.text = "0%"
	state = 'empty'

	if station not in stations:
		return

	duration = stations[station]['duration']
	animated_sprite.animation = station
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

	if state == 'running':
		elapsed_time += delta
		percentage.text = str(int(elapsed_time / duration * 100)) + "%"

		if elapsed_time >= duration:
			state = 'ready'
			percentage.text = "READY"

func _on_interaction_area_body_entered(_body: Node2D) -> void:
	if _body == player and state != 'running':
		player.current_interactable_item = self

		if state == 'empty':
			tooltip.text = message_base
		elif state == 'running':
			tooltip.text = "Running..."
		elif state == 'ready':
			tooltip.text = message_base

func interact() -> void:
	if state == 'empty':
		if player.item_holding['id'] != stations[station]['empty']:
			tooltip.text = stations[station]['emtpy_text']
			return

		current_item = player.give_item()
		Audiomanager.play_sfx(station)
		state = 'running'
		percentage.visible = true
		elapsed_time = 0.0

	elif state == 'ready':
		if player.item_holding['id'] != '':
			tooltip.text = "You have your hands full right now"
			return

		current_item['id'] = stations[station]['ready']
		current_item['name'] = ItemsType.items_names.get(current_item['id'], "")
		current_item[station + '_level'] = 5

		player.get_item(current_item)
		current_item = ItemsType.create_item("")
		state = 'empty'
		percentage.visible = false
		percentage.text = "00%"
