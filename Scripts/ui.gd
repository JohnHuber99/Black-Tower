extends Node2D

@export var z_layer = 2
@export var flash_duration = 0.1
@export var flash_amount = 2

@onready var health_bar = $Health
@onready var mana_bar = $Mana
@onready var health = $Health/Label
@onready var mana = $Mana/Label
@onready var slot0 = $SpellSlot0
@onready var slot1 = $SpellSlot1
@onready var spell0 = $SpellSlot0/Spell0
@onready var spell1 = $SpellSlot1/Spell1

func _flash(node):
	for i in range(flash_amount):
		node.modulate = Color(10, 10, 10, 10)
		await get_tree().create_timer(flash_duration).timeout
		node.modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(flash_duration).timeout

func _ready() -> void:
	z_index = z_layer
	slot0.play("ready")
	slot1.play("ready")

func set_health(current, max):
	health.text = str(current, "/", max)
	_flash(health_bar)

func set_mana(current, max):
	mana.text = str(current, "/", max)
	
func set_spell_0(spell):
	spell0.play(spell)
	
func set_spell_1(spell):
	spell1.play(spell)
	
func set_cooldown(slot):
	if slot == 0:
		slot0.play("cooldown")
	if slot == 1:
		slot1.play("cooldown")
		
func set_ready(slot):
	if slot == 0:
		slot0.play("ready")
	if slot == 1:
		slot1.play("ready")
