class_name SkylineGenerator
extends Node
# class description (one line)
# extended class description

# signals

# enums

# constants
const EMPTY := Color(0,0,0,0)
const BLACK := Color(0,0,0,1)
# exported variables

# public variables

# private variables
var _ignore

# onready variables

# METHOD ORDER:
# 1. built-in methods, starting with _init and _ready in that order
# 2. public methods
# 3. private methods

func compile()->Dictionary:
	var dict := {}
	
	var texture = load("res://SkylineGenerator/Foreground.png") as Texture
	var image = texture.get_data() as Image
	image.lock()
	var array := _read(image)
	dict["foreground"] = array
	
	image.unlock()
	texture = load("res://SkylineGenerator/Background.png") as Texture
	image = texture.get_data() as Image
	image.lock()
	array = _read(image)
	dict["background"] = array
	
	image.unlock()
	texture = load("res://SkylineGenerator/Midground.png") as Texture
	image = texture.get_data() as Image
	image.lock()
	array = _read(image)
	dict["midground"] = array
	
	return dict


func _read(image:Image)->Array:
	var size := image.get_size()
	var array := []
	for c in size.y:
		for r in size.x:
			var pixel := image.get_pixel(r, c)
			if pixel == EMPTY:
				array.append("e")
			if pixel == BLACK:
				array.append("c")
		array.append("n")
	return array
