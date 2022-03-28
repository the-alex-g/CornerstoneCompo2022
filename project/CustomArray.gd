class_name CustomArray
extends Node

var _array := []
var _max_value := 0

func setup(max_value:int)->void:
	_max_value = max_value


func get_at(index:int):
	if index < _array.size():
		return _array[index]
	else:
		return " "


func add(value:String)->void:
	var transient_array := []
	transient_array.append(value)
	transient_array.append_array(_array)
	_array = transient_array
	
	var array_length := _array.size()
	if array_length > _max_value:
		_array.remove(array_length-1)


func only_contains(value:String)->bool:
	var is_true := true
	for v in _array:
		if v != value:
			is_true = false
	return is_true


func empty()->void:
	_array.clear()


