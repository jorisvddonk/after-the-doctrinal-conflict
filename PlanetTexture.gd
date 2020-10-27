extends TextureRect

const WIDTH = 256 * 3
const HEIGHT = 256
const ITERCOUNT = 100
const H_ABILITY = 2

func _ready():
	randomize()
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()


	dynImage.create(WIDTH,HEIGHT,false,Image.FORMAT_RGB8)
	dynImage.fill(Color(0.1,0.1,0,1))
	
	var arr = []
	for i in range(WIDTH):
		for j in range(HEIGHT):
			arr.push_back(0)
			
	
	
	for f in range(ITERCOUNT):
		var f1_x_orig = int(randf() * WIDTH)
		var f1_x_off = (randf() * H_ABILITY)
		
		var f2_x_orig = f1_x_orig + int(randf() * (WIDTH / H_ABILITY))
		var f2_x_off = 0 - (randf() * H_ABILITY)
	
		for j in range(HEIGHT):
			var i_min = f1_x_orig + int(f1_x_off * j)
			var i_max = f2_x_orig + int(f2_x_off * j)
			
			var o = i_min
			var i = 0
			var im = i_max - i_min
			
			if i_max < i_min:
				im = i_min - i_max
				o = i_max
			
			while i < im:
				var i_x = (o + i) % WIDTH
				arr[j * WIDTH + i_x] += 1
				#var c = dynImage.get_pixel(i_x, j)
				
				#dynImage.set_pixel(i_x, j, c.lightened(0.05))
				i += 1
	
	
	dynImage.lock()
	var fI = float(ITERCOUNT)
	for i in range(WIDTH):
		for j in range(HEIGHT):
			var p = float(arr[j * WIDTH + i]) / fI
			dynImage.set_pixel(i, j, Color(p, p, p, 1))
	dynImage.unlock()
	
	imageTexture.create_from_image(dynImage)
	self.texture = imageTexture
