extends Node2D

func _ready():
	var err = get_tree().connect("files_dropped", self, "handle_files_dropped")
	if err != OK:
		print("Error connecting method to signal")
	
func handle_files_dropped(files, _screen):
	var file_path = files[0]
	var dir = Directory.new()
	var err = dir.copy(file_path, "user://new_file.ogg")
	if err == OK:
		print("File copied successfully")
		
#	var image = Image.new()
#	var texture = ImageTexture.new()
#	err = image.load("user://new_file.png")
#	texture.create_from_image(image)
#	$Sprite.texture = texture

	var stream = AudioImporter.loadfile("user://new_file.ogg")
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.playing = true
