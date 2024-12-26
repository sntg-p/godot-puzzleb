class_name Set extends Node


var dictionary: Dictionary = {}


func add(value: Variant):
	var valueHash = hash(value)
	dictionary[valueHash] = value

func has(value: Variant) -> bool:
	var valueHash = hash(value)
	return dictionary.has(valueHash)

func values():
	return dictionary.values()
