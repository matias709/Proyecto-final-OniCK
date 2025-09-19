extends TileMapLayer

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 300
var height = 300
var biomas = [Vector2i(2,0), Vector2i(0,0), Vector2i(1,0)]
var target_tail:Array[Vector2i]

var loaded_chunks = []

func _ready() -> void:
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	
	altitude.frequency =0.01
	island_generator(Vector2i(0,0))

func island_generator(pos) -> void:
	var area_agua = width/3
	print(area_agua)
	for x in range(width):
		for y in range(height):
			var dx = x - width/2
			var dy = y - height/2
			var dist = sqrt(dx * dx + dy * dy);
			if dist<=area_agua:
				set_cell(Vector2i(x, y), 0, biomas[1])
			else:
				set_cell(Vector2i(x, y), 0, biomas[0])

func _process(delta: float) -> void:
	pass
	#generate_chunk(Vector2i(0,0))
	##var player_tile_pos = local_to_map(player.position)



#func generate_chunk(pos):
	#for x in range(width):
		#for y in range(height):
			#var moist = moisture.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			#var temp = temperature.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			#var alt = altitude.get_noise_2d(pos.x - (width / 2) + x, pos.y - (height / 2) + y) * 10
			#print("moist: ", moist)
			#print("temp: ", temp)
			#print("alt: ", alt)
			#
			#if alt < 0:
				#set_cell(Vector2i(pos.x - (width / 2) + x, pos.y - (height / 2) + y), 0, biomas[0])
			#else:
				#set_cell(Vector2i(pos.x - (width / 2) + x, pos.y - (height / 2) + y), 0, biomas[1])
