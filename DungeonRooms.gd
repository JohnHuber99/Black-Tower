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

# Store placed room coordinates
var normal_room_list = []

var long_h_count = 0  # Track number of LONG_H rooms
var big_room_count = 0  # Track if at least one BIG room exists

#To implement limits later
var is_shop_spawn = false
var treasure_room_count = 0

#Create the starting coordinates
var x = int(ceilf(float(WIDTH) / 2.0 ))
var y = int(ceilf(float(HEIGHT) / 2.0))

# Called when the scene starts
func _ready():
	generate_dungeon()
	print_dungeon()

func generate_dungeon():
	# Initialize Dungeon Grid
	dungeon = []
	for y in range(HEIGHT):
		dungeon.append([])
		for x in range(WIDTH):
			dungeon[y].append(EMPTY)

	# Place Start Room in the Center
	var num_rooms = 1
	dungeon[y][x] = START

	# Room placement loop
	while num_rooms < MAX_ROOMS:
		var dir = directions[randi() % directions.size()]
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		# Ensure new room is within bounds
		if new_x >= 0 and new_x < WIDTH and new_y >= 0 and new_y < HEIGHT:
			var room_type = pick_room_type(new_x, new_y)
			if room_type != EMPTY:
				x = new_x
				y = new_y
				if room_type == NORMAL:
					normal_room_list.append(Vector2(x, y))
				num_rooms += 1
	
	# Place treasure and shop rooms
	place_special_rooms()


func place_special_rooms():
	# Randomly convert rooms to special types
	for pos in normal_room_list:
		if randf() < 0.1 and treasure_room_count < 2:  # 20% chance for a treasure room
			dungeon[pos.y][pos.x] = TREASURE
			treasure_room_count += 1
		elif randf() < 0.35 and !is_shop_spawn:  # 10% chance for a shop
			dungeon[pos.y][pos.x] = SHOP
			is_shop_spawn = true
	if treasure_room_count == 0:
		var rand = randi() % normal_room_list.size()
		dungeon[normal_room_list[rand].y][normal_room_list[rand].x] = TREASURE
		treasure_room_count += 1

# Picks a room type while ensuring no overlap
func pick_room_type(x, y) -> int:
	if dungeon[y][x] != EMPTY:
		return EMPTY  # Avoid overwriting existing rooms
	
	var possible_types = [NORMAL]

	# Check space for LONG_H (1x2 Horizontal Room)
	if long_h_count < 2 and x < WIDTH - 1 and dungeon[y][x + 1] == EMPTY:
		possible_types.append(LONG_H)
	
	# Check space for BIG (2x2 Room)
	if big_room_count < 1 and x < WIDTH - 1 and y < HEIGHT - 1:
		if (dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY):
			possible_types.append(BIG)
	
	# Weighted Random Selection
	var randRoomNum = randf()
	if randRoomNum < 0.01 and BIG in possible_types:
		placeBIG(y,x)
		return BIG
	elif randRoomNum < 0.1 and LONG_H in possible_types:
		placeLONG_H(y,x)
		return LONG_H
		
	dungeon[y][x] = NORMAL
	return NORMAL

func placeBIG(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x + 1] = BIG
	dungeon[y + 1][x] = BIG
	dungeon[y + 1][x + 1] = BIG
	big_room_count += 1

func placeLONG_H(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x + 1] = LONG_H  
	long_h_count += 1

# Prints the dungeon to the Godot console as ASCII
func print_dungeon():
	print("\nDungeon Layout:\n")
	for y in range(HEIGHT):
		var row = ""
		for x in range(WIDTH):
			row += room_symbols[dungeon[y][x]] + " "
		print(row)
	print("\n")
