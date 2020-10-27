extends TextureRect

const WIDTH = 256 * 3
const HEIGHT = 256

func _ready():
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()


	dynImage.create(WIDTH,HEIGHT,false,Image.FORMAT_RGB8)
	dynImage.fill(Color(0.1,0.1,0,1))
	dynImage.lock()	
	
	for f in range(9):
		var f1_x_orig = int(randf() * WIDTH)
		var f1_x_off = (randf() * 3) - 1.5
		
		var f2_x_orig = int(randf() * WIDTH)
		var f2_x_off = (randf() * 3) - 1.5
	
		for j in range(HEIGHT):
			var i_min = f1_x_orig + int(f1_x_off * j) % WIDTH
			var i_max = f2_x_orig + int(f2_x_off * j) % WIDTH
			
			var o = i_min
			var i = 0
			var im = i_max - i_min
			
			if i_max < i_min:
				im = i_min - i_max
				o = i_max
			
			while i < im:
				var i_x = (o + i) % WIDTH
				var c = dynImage.get_pixel(i_x, j)
				
				dynImage.set_pixel(i_x, j, c.lightened(0.1))
				i += 1

	dynImage.unlock()
	imageTexture.create_from_image(dynImage)
	self.texture = imageTexture
