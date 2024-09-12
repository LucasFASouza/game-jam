extends "res://Scripts/interactable_item.gd"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anvil_minigame = $AnvilMinigame

var state: String = 'empty'
var current_item = ItemsType.create_item("")

func _ready() -> void:
	message_base = "Press SPACE to interact"
	tooltip.visible = false
	state = 'empty'

	super._ready()

func _process(delta: float) -> void:
	super._process(delta)

func _on_interaction_area_body_entered(_body: Node2D) -> void:
	if _body == player:
		player.current_interactable_item = self

		if state == 'empty':
			tooltip.text = message_base

func interact() -> void:
	if state == 'empty':
		if player.item_holding['id'] != "iron_ingot":
			tooltip.text = 'You need Iron Ingot to start the anvil'
			return

		player.state = 'minigame'
		current_item = player.give_item()

		tooltip.text = "Press SPACE to hammer the right spot"
		anvil_minigame.visible = true
		anvil_minigame.start_minigame()

		state = 'running'

func finish_minigame(score):
	current_item['id'] = "dull_sword"
	current_item['name'] = ItemsType.items_names.get("dull_sword", "")

	if score == 1:
		score = 1.5
	elif score == 0.5 or score == 0:
		score = 1
	current_item['anvil_level'] = score

	player.get_item(current_item)
	player.state = 'free'

	current_item = ItemsType.create_item("")
	state = 'empty'

	tooltip.text = "You scored " + str(score) + "/3 stars!"

	anvil_minigame.visible = false
