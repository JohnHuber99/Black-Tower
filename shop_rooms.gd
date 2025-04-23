extends "res://Dungeon/Dungeon_Scripts/DungeonRooms.gd"

func generate_dungeon():
	dungeon = []
	room_connections = {}  
	normal_room_list = []
	x = start_x
	y = start_y
	num_loops = 0
	num_rooms = 1
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
	while num_rooms < 2:
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
				dungeon[y][x] = NORMAL
				# Adds all normal rooms to a list
				normal_room_list.append(Vector2(x, y))
				
				num_rooms += 1
				
				# Adds all rooms to the dictionary
				room_connections[Vector2(x, y)] = []
				# Creates a random connection to neighboring (adjacent) rooms
				add_random_connection(Vector2(x, y))
		else:
			new_x = start_x
			new_y = start_y

func place_special_rooms():
	for pos in normal_room_list:
		if !is_shop_spawn and dungeon[pos.y][pos.x] == NORMAL:
			dungeon[pos.y][pos.x] = SHOP
			is_shop_spawn = true

func place_boss_room():
	pass

func is_valid_dungeon() -> bool:
	return num_rooms == 2 and is_shop_spawn
