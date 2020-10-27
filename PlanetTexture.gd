extends TextureRect

func _ready():
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()

	dynImage.create(256,256,false,Image.FORMAT_RGB8)
	dynImage.fill(Color(0.1,0.1,0,1))
	dynImage.lock()	
	
	for i in range(256):
		for j in range(256):
			dynImage.set_pixel(i, j, dynImage.get_pixel(i, j).lightened(randf()))

	dynImage.unlock()
	imageTexture.create_from_image(dynImage)
	self.texture = imageTexture
