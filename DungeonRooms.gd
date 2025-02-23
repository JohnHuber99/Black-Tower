extends Node2D

# Dungeon Grid Conditions
const WIDTH = 5
const HEIGHT = 5
const MAX_ROOMS = 7
const MAX_LOOPS = 40

# Contains a list of directions
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

#Contains a 2D array of the dungeon
var dungeon = []

# Dictionary of room connections (Uses the room coordinates as a key to find what rooms it is connected to)
var room_connections = {}

# List of Room Types
enum { EMPTY, NORMAL, START, FINAL, TREASURE, SHOP, LONG_H, BIG, BOSS}

# ASCII representation of each room type
var room_symbols = {
	EMPTY: " ",
	START: "S",
	NORMAL: "N",
	FINAL: "F",
	TREASURE: "T",
	SHOP: "$",
	LONG_H: "=",
	BIG: "□",
	BOSS: "B"
}

# Tracking variables
var possible_neighbors = []
var long_room_list = []
var big_room_list = []
var normal_room_list = []
var long_h_count = 0  
var big_room_count = 0  
var treasure_room_count = 0
var is_shop_spawn = false
var num_loops = 0
var num_rooms = 1

#Creates x and y and centers them on the 2D Array
const start_x = int(ceilf(float(WIDTH) / 2.0 )) - 1
const start_y = int(ceilf(float(HEIGHT) / 2.0 )) - 1

var x = start_x
var y = start_y

# Initializes the creation of the Dungeon Map
func _ready():
	# Generates the Seed for the Dungeon Layout that we can reuse
	var seed_value = randi() 
	seed(seed_value) 
	print("Generate Seed : ", seed_value)
	
	var attempts = 0
	while true:
		generate_dungeon()
		#place_final_room()
		place_boss_room()
		place_special_rooms()
		attempts += 1
		
		if is_valid_dungeon():
			print("Dungeon generated successfully after ", attempts, " attempts!")
			break
		
		if attempts % 100 == 0:
			print("Still generating... Attempt: ", attempts, "\n")  # Debugging output
			print("Unfinished Dungeon Attempt: \n")
			print_dungeon()
		
		if attempts == 1001:
			break
	
	# Prints the Dungeon in ASCII
	print_dungeon()
		
#Generates the Dungeon
func generate_dungeon():
	dungeon = []
	room_connections = {}  
	long_room_list = []
	big_room_list = []
	normal_room_list = []
	long_h_count = 0
	big_room_count = 0
	treasure_room_count = 0
	num_loops = 0
	num_rooms = 1
	is_shop_spawn = false
	x = start_x
	y = start_y
	var prevDir = null
	
	# Creates the 2D Array for the Dungeon
	for gridHeight in range(HEIGHT):
		dungeon.append([])
		for gridWidth in range(WIDTH):
			dungeon[gridHeight].append(EMPTY)
	
	# Creates the starting room and sets up possible room connections
	dungeon[start_y][start_x] = START
	room_connections[Vector2(start_x, start_y)] = []

	# Ensures the Dungeon creates the desired amount of rooms
	while num_rooms < MAX_ROOMS:
		if num_loops > MAX_LOOPS:
			break
		num_loops += 1
		
		# Picks a random direction
		var dir = directions[randi() % directions.size()]
		var new_x = x + dir.x
		var new_y = y + dir.y
		
		if (prevDir == dir):
			dir = directions[randi() % directions.size()]
			new_x = start_x + dir.x
			new_y = start_y + dir.y
		
		# Checks if the random direction is within the 2D Array Bounds
		if new_x >= 0 and new_x < WIDTH and new_y >= 0 and new_y < HEIGHT:
			prevDir = dir
			x = new_x
			y = new_y
			
			if dungeon[y][x] == EMPTY:
				# Calls pick_room_type function to pick a room type
				var room_type = pick_room_type(new_x, new_y)
				if room_type == NORMAL:
					# Adds all normal rooms to a list
					normal_room_list.append(Vector2(x, y))
				elif room_type == LONG_H:
					long_h_count += 1
				elif room_type == BIG:
					big_room_count += 1
				
				if room_type != EMPTY:
					num_rooms += 1
				
				# Adds all rooms to the dictionary
				room_connections[Vector2(x, y)] = []
				# Creates a random connection to neighboring (adjacent) rooms
				add_random_connection(Vector2(x, y))
		else:
			new_x = start_x
			new_y = start_y

func pick_room_type(x, y) -> int:
	if dungeon[y][x] != EMPTY:
		return EMPTY
	
	var possible_types = [NORMAL]
	var isbigLeft = false
	var isbigRight = false
	var islongLeft = false
	var islongRight = false

	# Check space for LONG_H (1x2 Horizontal Room)
	if long_h_count < 2 and x < WIDTH - 1:
		if dungeon[y][x + 1] == EMPTY:
			possible_types.append(LONG_H)
			islongRight = true
		if x > 1:
			if dungeon[y][x - 1] == EMPTY:
				possible_types.append(LONG_H)
				islongLeft = true
	
	# Check space for BIG (2x2 Room)
	if big_room_count < 1 and x < WIDTH - 1 and y < HEIGHT - 1:
		if (dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY):
			possible_types.append(BIG)
			isbigRight = true
		if x > 1 and y > 1:
			if (dungeon[y][x - 1] == EMPTY and dungeon[y - 1][x] == EMPTY and dungeon[y - 1][x - 1] == EMPTY):
				possible_types.append(BIG)
				isbigLeft = true
	
	# Weighted Random Selection of if to add a Big Room or Long Room
	if randf() < 0.01 and BIG in possible_types: # 1% Chance to add Big Room
		if isbigLeft and isbigRight:
			if randf() < 0.5:
				placeBIGLeft(y, x)
			else:
				placeBIGRight(y, x)
		elif isbigRight:
			placeBIGRight(y, x)
		else:
			placeBIGLeft(y, x)
		return BIG
	elif randf() < 0.1 and LONG_H in possible_types: # 10% Chance to add Long Room
		if islongLeft and islongRight:
			if randf() < 0.5:
				placeLONG_HLeft(y, x)
			else:
				placeLONG_HRight(y, x)
		elif islongRight:
			placeLONG_HRight(y, x)
		elif islongLeft:
			placeLONG_HLeft(y, x)
		return LONG_H

	
	dungeon[y][x] = NORMAL
	return NORMAL

# Creates a Big Room on the right
func placeBIGRight(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x + 1] = BIG
	dungeon[y + 1][x] = BIG
	dungeon[y + 1][x + 1] = BIG
	big_room_list.append([[x, y],[x + 1, y],[x, y + 1],[x + 1, y + 1]])
	
# Creates a Big Room on the left
func placeBIGLeft(y, x):
	dungeon[y][x] = BIG
	dungeon[y][x - 1] = BIG
	dungeon[y - 1][x] = BIG
	dungeon[y - 1][x - 1] = BIG
	big_room_list.append([[x, y],[x - 1, y],[x, y - 1],[x - 1, y - 1]])

# Creates a Big Room on the right
func placeBossRight(y, x):
	dungeon[y][x] = BOSS
	dungeon[y][x + 1] = BOSS
	dungeon[y + 1][x] = BOSS
	dungeon[y + 1][x + 1] = BOSS
	
# Creates a Big Room on the left
func placeBossLeft(y, x):
	dungeon[y][x] = BOSS
	dungeon[y][x - 1] = BOSS
	dungeon[y - 1][x] = BOSS
	dungeon[y - 1][x - 1] = BOSS

# Creates a Horizontal Long Room on the right
func placeLONG_HRight(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x + 1] = LONG_H
	long_room_list.append([[x, y], [x + 1, y]])

# Creates a Horizontal Long Room on the left
func placeLONG_HLeft(y, x):
	dungeon[y][x] = LONG_H
	dungeon[y][x - 1] = LONG_H
	long_room_list.append([[x, y], [x - 1, y]])

# Adds random room connections
func add_random_connection(room: Vector2):
	# Resets list of all possible neighbors
	possible_neighbors = []

	# Check for all valid directions (up, down, left, right) to find neighbors
	for dir in directions:
		var neighbor = room + dir
		
		# Ensure the neighbor is within bounds
		if neighbor.x >= 0 and neighbor.x < WIDTH and neighbor.y >= 0 and neighbor.y < HEIGHT:

			# Check for LONG_H room (1x2) - Can connect vertically or horizontally
			if dungeon[room.y][room.x] == LONG_H:
				# Prevent connection to the other part of the LONG_H room horizontally
				if (dir == Vector2.RIGHT and [[room.x, room.y],[room.x + 1, room.y]] in long_room_list):
					continue  # Skips to the next direction in the for loop
				if (dir == Vector2.LEFT and [[room.x, room.y],[room.x - 1, room.y]] in long_room_list):
					continue  # Skips to the next direction in the for loop
					
				# Valid directions for Horizontal Long Rooms (checking up, down, right, left)
				valid_neighbors(dir, room, neighbor)
				
			# Check for BIG room (2x2) - Can connect on all four sides but not within itself
			elif dungeon[room.y][room.x] == BIG:
				# Prevent horizontal connections within the BIG room (left-right)
				if (dir == Vector2.LEFT and
				[[room.x, room.y],[room.x - 1, room.y],[x, room.y - 1],[room.x - 1, room.y - 1]] in big_room_list):
					continue  
				elif (dir == Vector2.RIGHT and 
				[[room.x, room.y],[room.x + 1, room.y],[x, room.y + 1],[room.x + 1, room.y + 1]] in big_room_list):
					continue 
				# Prevent vertical connections within the BIG room (top-bottom)
				elif (dir == Vector2.UP and 
				[[room.x, room.y],[room.x - 1, room.y],[x, room.y - 1],[room.x - 1, room.y - 1]] in big_room_list):
					continue
				elif (dir == Vector2.DOWN and 
				[[room.x, room.y],[room.x + 1, room.y],[x, room.y + 1],[room.x + 1, room.y + 1]] in big_room_list):
					continue 

				# Valid directions for Big Rooms (checking up, down, right, left)
				valid_neighbors(dir, room, neighbor)

			# For normal rooms, check for valid connections to neighboring rooms
			elif dungeon[room.y][room.x] == NORMAL:
				# If neighbor has a room
				if dungeon[neighbor.y][neighbor.x] != EMPTY:  
					possible_neighbors.append(neighbor)

	# If there are valid neighbors, randomly choose one to connect 
	if possible_neighbors.size() > 0:
		var connected_neighbors = []  # List to track neighbors that were connected

		# Go through each valid neighbor and randomly decide if it should be connected
		for neighbor in possible_neighbors:
			# Random chance to connect (could be adjusted to a percentage if needed)
			if randf() < 0.65:  # 65% chance to connect to this neighbor
				if neighbor not in room_connections.get(room, []):
					# If the room is not in the dictionary, add it
					if not room_connections.has(room):
						room_connections[room] = []
					if not room_connections.has(neighbor):
						room_connections[neighbor] = []
					
					# Add bidirectional connection between rooms
					room_connections[room].append(neighbor)
					room_connections[neighbor].append(room)
					connected_neighbors.append(neighbor)
		
		# If no neighbors were connected, force a connection with one
		if connected_neighbors.size() == 0:
			var forced_neighbor = possible_neighbors[randi() % possible_neighbors.size()]
			# Ensure the forced connection is valid and not redundant
			if forced_neighbor not in room_connections.get(room, []):
				if not room_connections.has(room):
					room_connections[room] = []
				if not room_connections.has(forced_neighbor):
					room_connections[forced_neighbor] = []
				
				# Add the forced bidirectional connection
				room_connections[room].append(forced_neighbor)
				room_connections[forced_neighbor].append(room)


func valid_neighbors(dir, room, neighbor):
	if dir == Vector2.LEFT and room.x > 0 and dungeon[room.y][room.x - 1] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.RIGHT and room.x + 1 < WIDTH and dungeon[room.y][room.x + 1] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.UP and room.y > 0 and dungeon[room.y - 1][room.x] != EMPTY:
		possible_neighbors.append(neighbor)
	elif dir == Vector2.DOWN and room.y + 1 < HEIGHT and dungeon[room.y + 1][room.x] != EMPTY:
		possible_neighbors.append(neighbor)

func place_boss_room():
	var start_room = Vector2(start_x, start_y) 
	var visited = {}
	var queue = []
	var last_normal_room = null  # Stores the last NORMAL room found during BFS
	var isBossLeft = false
	var isBossRight = false

	queue.append(start_room)

	while queue.size() > 0:
		var current_room = queue.pop_front()

		if current_room in visited:
			continue

		visited[current_room] = true

		# Update last NORMAL room encountered
		if dungeon[current_room.y][current_room.x] == NORMAL:
			last_normal_room = current_room

		for neighbor in room_connections.get(current_room, []):
			if neighbor not in visited:
				queue.append(neighbor)

	if last_normal_room != null:
		# Check space for BIG (2x2 Room)
		if big_room_count < 1 and x < WIDTH - 1 and y < HEIGHT - 1:
			if (dungeon[y][x + 1] == EMPTY and dungeon[y + 1][x] == EMPTY and dungeon[y + 1][x + 1] == EMPTY):
				isBossRight = true
			if x > 1 and y > 1:
				if (dungeon[y][x - 1] == EMPTY and dungeon[y - 1][x] == EMPTY and dungeon[y - 1][x - 1] == EMPTY):
					isBossRight = true	
		
		if isBossLeft == true or isBossRight == true: 
			if isBossLeft and isBossRight:
				if randf() < 0.5:
					placeBossLeft(y, x)
				else:
					placeBossRight(y, x)
			elif isBossRight:
				placeBossRight(y, x)
			else:
				placeBossLeft(y, x)
	else:
		print("Error: No NORMAL room found to place FINAL room!\n")
		
func place_final_room():
	var start_room = Vector2(start_x, start_y) 
	var visited = {}
	var queue = []
	var last_normal_room = null  # Stores the last NORMAL room found during BFS

	queue.append(start_room)

	while queue.size() > 0:
		var current_room = queue.pop_front()

		if current_room in visited:
			continue

		visited[current_room] = true

		# Update last NORMAL room encountered
		if dungeon[current_room.y][current_room.x] == NORMAL:
			last_normal_room = current_room

		for neighbor in room_connections.get(current_room, []):
			if neighbor not in visited:
				queue.append(neighbor)

	if last_normal_room != null:
		dungeon[last_normal_room.y][last_normal_room.x] = FINAL
		normal_room_list.erase(last_normal_room)
	else:
		print("Error: No NORMAL room found to place FINAL room!\n")

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

func is_valid_dungeon() -> bool:
	# Ensure at least one FINAL and TREASURE room exist
	var has_treasure = false
	var has_boss = false
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if dungeon[y][x] == TREASURE:
				has_treasure = true
			if dungeon[y][x] == BOSS:
				has_boss = true
	
	# Define your criteria
	return has_treasure and has_boss and num_rooms == MAX_ROOMS

func print_dungeon():
	print("\nDungeon Layout:\n")
	
	for y in range(HEIGHT):
		var room_row = ""
		var door_row = ""  
		var first_vert = false

		for x in range(WIDTH):
			var pos = Vector2(x, y)
			
			# Add room symbol
			room_row += room_symbols[dungeon[y][x]]

			# Add horizontal door
			if Vector2(x + 1, y) in room_connections.get(pos, []):
				room_row += "  +  "  # Horizontal door
			else:
				room_row += "     "  # Maintain spacing
			
			# Add vertical doors
			if Vector2(x, y + 1) in room_connections.get(pos, []):
				if !first_vert:
					door_row += "+  " 
					first_vert = true
				else:
					door_row += "  +  "  # Vertical door
			else:
				door_row += "     "  # Maintain spacing
			door_row += " "

		# Print the room row
		print(room_row)

		# Print vertical doors
		print(door_row)
		first_vert = false

	print("\n")
