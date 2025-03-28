extends Node

const Mana_Base = 100
const Mana_maxBar = 100

var currentMana_Bar = Mana_Base
var regeneration_Bar = 2
const Plague_Grenade_Cost = 22
const Smelling_Salts_cost = 30
const heavy_attack_cost = 20

signal manabar_signal

func _process(delta):
	manaRegenerate_Time(delta)
	manabar_signal.emit()

							
func manaRegenerate_Time(delta):
	if currentMana_Bar < Mana_maxBar:
		currentMana_Bar += regeneration_Bar * delta
		currentMana_Bar = clamp(currentMana_Bar, 0, Mana_maxBar)
		

func plague_grenade():
	if currentMana_Bar >= Plague_Grenade_Cost:
		currentMana_Bar -= Plague_Grenade_Cost
		return true
	else:
		return false

func smelling_salts():
	if currentMana_Bar >= Smelling_Salts_cost:
		currentMana_Bar -= Smelling_Salts_cost
		return true
	else:
		return false
		
func heavy_attack():
	if currentMana_Bar >= heavy_attack_cost:
		currentMana_Bar -= heavy_attack_cost
		return true
	else:
		return false
