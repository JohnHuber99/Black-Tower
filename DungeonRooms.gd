extends Node2D

const WIDTH = 6
const HEIGHT = 6
const MAX_ROOMS = 7

var dungeon = []
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var room_connections = {}  # Store graph connections between rooms

# Room types with different sizes
enum { EMPTY, NORMAL, START, BOSS, TREASURE, SHOP, LONG_H, BIG }

# ASCII representation of each room type
var room_symbols = {
	EMPTY: " ",
	START: "S",
	NORMAL: "N",
	BOSS: "B",
	TREASURE: "T",
	SHOP: "$",
	LONG_H: "=",
	BIG: "□"
}

# Tracking variables
var normal_room_list = []
var long_h_count = 0  
var big_room_count = 0  
var is_shop_spawn = false
var treasure_room_count = 0

var x = int(ceilf(float(WIDTH) / 2.0 ))
var y = int(ceilf(float(HEIGHT) / 2.0 ))

func _ready():
	randomize()
	generate_dungeon()
	ensure_full_connectivity()
	print_dungeon()

func generate_dungeon():
	dungeon = []
	for y in range(HEIGHT):
		dungeon.append([])
		for x in range(WIDTH):
			dungeon[y].append(EMPTY)
	
	var num_rooms = 1
	dungeon[y][x] = START
	room_connections[Vector2(x, y)] = []

	while num_rooms < MAX_ROOMS:
		var dir = directions[randi() % directions.size()]
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		if new_x >= 0 and new_x < WIDTH and new_y >= 0 and new_y < HEIGHT:
			var room_type = pick_room_type(new_x, new_y)
			if room_type != EMPTY:
				x = new_x
				y = new_y
				if room_type == NORMAL:
					normal_room_list.append(Vector2(x, y))
				elif room_type == LONG_H:
					long_h_count += 1
				elif room_type == BIG:
					big_room_count += 1
				room_connections[Vector2(x, y)] = []
				add_random_connection(Vector2(x, y))
				num_rooms += 1
	
	place_special_rooms()

func place_special_rooms():
	for pos in normal_room_list:
		if randf() < 0.1 and treasure_room_count < 2:
			dungeon[pos.y][pos.x] = TREASURE
			treasure_room_count += 1
		elif randf() < 0.35 and !is_shop_spawn:
			dungeon[pos.y][pos.x] = SHOP
			is_shop_spawn = true
	if treasure_room_count == 0:
		var rand = randi() % normal_room_list.size()
		dungeon[normal_room_list[rand].y][normal_room_list[rand].x] = TREASURE
		treasure_room_count += 1

func pick_room_type(x, y) -> int:
	if dungeon[y][x] != EMPTY:
		return EMPTY
	
	var possible_types = [NORMAL]

	# Check space for LONG_H (1x2 Horizontal Room)
	if long_h_count < 2 and x < WIDTH - 1:
		if dungeon[y][x + 1] == EMPTY:
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

func add_random_connection(room: Vector2):
	var possible_neighbors = []
	for dir in directions:
		var neighbor = room + dir
		if room_connections.has(neighbor):
			possible_neighbors.append(neighbor)
	
	if possible_neighbors.size() > 0:
		var chosen_neighbor = possible_neighbors[randi() % possible_neighbors.size()]
		room_connections[room].append(chosen_neighbor)
		room_connections[chosen_neighbor].append(room)

func ensure_full_connectivity():
	var visited = {}
	var queue = [Vector2(x, y)]
	visited[Vector2(x, y)] = true

	while queue.size() > 0:
		var current = queue.pop_front()
		for neighbor in room_connections[current]:
			if !visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	
	for room in room_connections.keys():
		if !visited.has(room):
			add_random_connection(room)

func print_dungeon():
	print("\nDungeon Layout:\n")
	
	# Loop through each row to print rooms with extra spacing
	for y in range(HEIGHT):
		# Print the rooms with extra spacing
		var room_row = ""
		var door_row = ""
		var horizontal_doors_count = 0
		
		for x in range(WIDTH):
			var pos = Vector2(x, y)
			# Print the room symbol with a large gap
			room_row += room_symbols[dungeon[y][x]]

			# Check if there's a horizontal connection to the right
			if Vector2(x + 1, y) in room_connections.get(pos, []):
				room_row += "  +  "  # Horizontal connection
			else:
				room_row += "     "  # No horizontal connection

			# Add vertical door connections in a separate row
			if Vector2(x, y + 1) in room_connections.get(pos, []):
				door_row += "  |  "  # Vertical door with extra spacing
			else:
				door_row += "     "  # No vertical door

		# Print the room row and horizontal connections
		print(room_row)
		# Print the vertical door row, ensuring it's on a new line
		if y < HEIGHT - 1:
			print(door_row)

	print("\n")
