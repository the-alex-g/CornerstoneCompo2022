extends Control

const SCANCODE_ALPHABET := {32:" ", 65:"a", 66:"b", 67:"c", 68:"d", 69:"e", 70:"f", 71:"g", 72:"h", 73:"i", 74:"j", 75:"k", 76:"l", 77:"m", 78:"n", 79:"o", 80:"p", 81:"q", 82:"r", 83:"s", 84:"t", 85:"u", 86:"v", 87:"w", 88:"x", 89:"y", 90:"z"}
const ENTER := 16777221
const BACKSPACE := 16777220
const SPACES_PER_CHAR := "  "
const TIME_PER_CHAR := 0.4

var _word_being_typed := ""
var _words_entered := {}
var _all_words := ""
var _scrolling_array := CustomArray.new()
var _character_index : int
var _character_counter := 0
var _is_clearing := false
var _foreground_sequence := []
var _midground_sequence := []
var _background_sequence := []

onready var _text_display = $TextDisplay as Label
onready var _word_list = $WordList as RichTextLabel
onready var _clear_timer = $ClearTimer as Timer
onready var _advance_timer = $AdvanceStringTimer as Timer
onready var _foreground = $CityContainer/Foreground as Label
onready var _midground = $CityContainer/Midground as Label
onready var _background = $CityContainer/Background as Label


func _ready()->void:
	var generator := SkylineGenerator.new()
	var dict := generator.compile()
	_foreground_sequence = dict["foreground"]
	
	var number_of_chars := 0
	for v in _foreground_sequence:
		if v == "c":
			number_of_chars += 1
	for v in _background_sequence:
		if v == "c":
			number_of_chars += 1
	for v in _midground_sequence:
		if v == "c":
			number_of_chars += 1
	_scrolling_array.setup(number_of_chars)
	
	_clear_timer.wait_time = number_of_chars * TIME_PER_CHAR * 2
	_advance_timer.wait_time = TIME_PER_CHAR


func _input(event:InputEvent)->void:
	if event is InputEventKey:
		if event.is_pressed():
			var scancode = event.scancode
			if SCANCODE_ALPHABET.keys().has(scancode):
				_word_being_typed += SCANCODE_ALPHABET[scancode]
				_text_display.text = _word_being_typed
			
			if scancode == ENTER and _word_being_typed.length() > 0:
				_submit_word()
			
			if scancode == BACKSPACE:
				_word_being_typed.erase(_word_being_typed.length() - 1, 1)
				_text_display.text = _word_being_typed


func _submit_word()->void:
	if _clear_timer.is_stopped() and not _is_clearing:
		_clear_timer.start()
		print("start")
	
	if _words_entered.keys().has(_word_being_typed):
		_words_entered[_word_being_typed] = _words_entered[_word_being_typed] + 1
	else:
		_words_entered[_word_being_typed] = 1
	_update_wordlist()
	
	# adds word at start of _all_words
	_all_words = _word_being_typed.capitalize() + _all_words
	_word_being_typed = ""
	_text_display.text = _word_being_typed


func _update_wordlist()->void:
	_word_list.text = ""
	for word in _words_entered:
		word = word as String
		_word_list.text += word.capitalize()
		var times_entered = _words_entered[word]
		if times_entered > 1:
			_word_list.text += " x" + str(times_entered)
		_word_list.text += "\n"


func _on_AdvanceStringTimer_timeout()->void:
	var string_length := _all_words.length()
	if string_length == 0:
		return
		
	if not _is_clearing:
		_character_index = string_length - _character_counter
		_character_counter += 1
		if _character_counter >= string_length:
			_character_counter %= string_length
		var character = _all_words[_character_index-1]
		_scrolling_array.add(character)
	
	else:
		_scrolling_array.add(SPACES_PER_CHAR)
		if _scrolling_array.only_contains(SPACES_PER_CHAR):
			_clear_timer = true
			_is_clearing = false
	
	var field := _generate_field()
	_foreground.text = field["foreground"]
	_midground.text = field["midground"]
	_background.text = field["background"]


func _generate_field()->Dictionary:
	var index := 0
	var dict := {}
	var text := ""
	for x in _foreground_sequence:
		match x:
			"e":
				text += SPACES_PER_CHAR
			"c":
				text += _scrolling_array.get_at(index)
				index += 1
			"n":
				text += "\n"
	dict["foreground"] = text
	text = ""
	
	for x in _midground_sequence:
		match x:
			"e":
				text += SPACES_PER_CHAR
			"c":
				text += _scrolling_array.get_at(index)
				index += 1
			"n":
				text += "\n"
	dict["midground"] = text
	text = ""
	
	for x in _background_sequence:
		match x:
			"e":
				text += SPACES_PER_CHAR
			"c":
				text += _scrolling_array.get_at(index)
				index += 1
			"n":
				text += "\n"
	dict["background"] = text
	return dict


func _on_ClearTimer_timeout()->void:
	_is_clearing = true
	print("clear")
