class_name Set extends Node


var _dictionary: Dictionary = {}


func add(value: Variant):
	var valueHash = hash(value)
	_dictionary[valueHash] = value


func has(value: Variant) -> bool:
	var valueHash = hash(value)
	return _dictionary.has(valueHash)


func values():
	return _dictionary.values()


func erase(value: Variant) -> bool:
	return _dictionary.erase(value)


func size() -> int:
	var values = _dictionary.values()
	var amount = 0
	
	for value in values:
		if not is_instance_valid(value):
			print('skipping invalid set value')
			continue
		amount += 1
	
	return amount
