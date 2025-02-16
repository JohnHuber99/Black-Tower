extends Node2D

const WIDTH = 6
const HEIGHT = 6
const MAX_ROOMS = 7

var dungeon = []
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

# Room types with different sizes
enum { EMPTY, NORMAL, START, BOSS, TREASURE, SHOP, LONG_H, BIG }

# ASCII representation of each room type
var room_symbols = {
	EMPTY: " ",
	START: "S",
	NORMAL: ".",
	BOSS: "B",
	TREASURE: "T",
	SHOP: "$",
	LONG_H: "=",
	BIG: "□"
}

# Called when the scene starts
func _ready():
	generate_dungeon()
	print_dungeon()

func generate_dungeon():
	# Creates Dungeon Grid
	dungeon = []
	for y in range(HEIGHT):
		dungeon.append([])
		for x in range(WIDTH):
			dungeon[y].append(EMPTY)

	# Creates the Start Room in the Center of the Grid
	var start_x = int(float(WIDTH) / 2.0)
	var start_y = int(float(HEIGHT) / 2.0)
	dungeon[start_y][start_x] = START

	var num_rooms = 1
	var x = start_x
	var y = start_y

	#Runs code below until we reach the room creation limit
	while num_rooms < MAX_ROOMS:
		var dir = directions[randi() % directions.size()]
		var new_x = x + int(dir.x)
		var new_y = y + int(dir.y)
		var room_type = pick_room_type(new_x, new_y)
		
		#Checks if room is inbounds of the dungeon grid
		if room_type != EMPTY and is_within_bounds(new_x, new_y, room_type):
			if room_type != EMPTY:
				dungeon[new_y][new_x] = room_type
				x = new_x
				y = new_y
				num_rooms += 1

	place_special_rooms()

func place_special_rooms():
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if dungeon[y][x] == NORMAL:
				if randf() < 0.2: # 20% Chance for a regular room to turn into a treasure room
					dungeon[y][x] = TREASURE
				elif randf() < 0.1: # 10% Chance for a regular room to turn into a treasure room
					dungeon[y][x] = SHOP

#Need to update the is_within_bounds function to include long rooms and big rooms
func is_within_bounds(x, y, room_type) -> bool:
	if room_type == NORMAL or room_type == START or room_type == BOSS or room_type == TREASURE or room_type == SHOP:
		return x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT and dungeon[y][x] == EMPTY
	elif room_type == LONG_H:
		return (x >= 0 and x < WIDTH - 1 and y >= 0 and y < HEIGHT and 
				dungeon[y][x] == EMPTY and dungeon[y][x + 1] == EMPTY)
	elif room_type == BIG:
		return (x >= 0 and x < WIDTH - 1 and y >= 0 and y < HEIGHT - 1 and 
				dungeon[y][x] == EMPTY and dungeon[y][x + 1] == EMPTY and 
				dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY)
	return false

# Picks a room type while ensuring no overlap
func pick_room_type(x, y) -> int:
	var possible_types = [NORMAL]
	var chosen_type = NORMAL
	var roomChance = randi() % 100 #Picks a random number between and including 0 - 99.
	
	# Check if we can place a horizontal long or big room
	if x < WIDTH - 1 and dungeon[y][x + 1] == EMPTY:
		possible_types.append(LONG_H)
	if x < WIDTH - 1 and y < HEIGHT - 1 and dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY:
		possible_types.append(BIG)
	
	if possible_types.size() > 1:
		if roomChance < 90: # 90% Chacne to spawn a regular room
			chosen_type = NORMAL
		elif roomChance == 99: # 1% Chance to spawn a Big Room
			chosen_type = BIG
		else: # 9% Chance to spawn a regular room
			chosen_type = LONG_H
	
	# Mark additional tiles for big/long rooms
	if chosen_type == LONG_H:
		dungeon[y][x + 1] = LONG_H
	elif chosen_type == BIG:
		dungeon[y + 1][x] = BIG
		dungeon[y][x + 1] = BIG
		dungeon[y + 1][x + 1] = BIG

	return chosen_type

# Prints the dungeon to the Godot console as ASCII
func print_dungeon():
	print("\nDungeon Layout:\n")
	for y in range(HEIGHT):
		var row = ""
		for x in range(WIDTH):
			row += room_symbols[dungeon[y][x]] + " "
		print(row)
	print("\n")
