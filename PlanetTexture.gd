extends TextureRect

const WIDTH = 256 * 3
const HEIGHT = 256
const ITERCOUNT = 75
const H_ABILITY = 3 # the higher, the more "horizontal' lines can get.

func _ready():
	randomize()
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()


	dynImage.create(WIDTH,HEIGHT,false,Image.FORMAT_RGB8)
	dynImage.fill(Color(0.1,0.1,0,1))
	
	var arr = []
	for i in range(WIDTH):
		for j in range(HEIGHT):
			arr.push_back(ITERCOUNT * 0.5)
			
	
	
	for f in range(ITERCOUNT):
		var f1_x_orig = int(randf() * WIDTH)
		var f1_x_off = (randf() * H_ABILITY)
		
		var f2_x_orig = f1_x_orig + int(randf() * (WIDTH / H_ABILITY))
		var f2_x_off = 0 - (randf() * H_ABILITY)
		
		var off = 1 # determines whether or not the area between the liens will be raised or lowered
		if randf() < 0.5:
			off = -1
	
		for j in range(HEIGHT):
			var i_min = f1_x_orig + int(f1_x_off * j)
			var i_max = f2_x_orig + int(f2_x_off * j)
			
			var o_min = i_min
			var o_max = i_max
			
			var i = 0
			var im = i_max - i_min
			
			if i_max < i_min:
				im = i_min - i_max
				o_min = i_max
				o_max = i_min
			
			while i < WIDTH:
				if i < o_min || i > o_max:
					arr[j * WIDTH + i] -= off
				else:
					arr[j * WIDTH + i] += off
				
				i += 1
	
	
	dynImage.lock()
	var fI = float(ITERCOUNT)
	for i in range(WIDTH):
		for j in range(HEIGHT):
			var p = max(min(float(arr[j * WIDTH + i]) / fI, 255), 0)
			dynImage.set_pixel(i, j, Color(p, p, p, 1))
	dynImage.unlock()
	
	imageTexture.create_from_image(dynImage)
	self.texture = imageTexture
