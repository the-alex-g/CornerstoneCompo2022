extends Control

const SCANCODE_ALPHABET := {45:"-", 39:"'", 32:" ", 65:"a", 66:"b", 67:"c", 68:"d", 69:"e", 70:"f", 71:"g", 72:"h", 73:"i", 74:"j", 75:"k", 76:"l", 77:"m", 78:"n", 79:"o", 80:"p", 81:"q", 82:"r", 83:"s", 84:"t", 85:"u", 86:"v", 87:"w", 88:"x", 89:"y", 90:"z"}
const ENTER := 16777221
const BACKSPACE := 16777220
const SHIFT := 16777237
const SPACES_PER_CHAR := " "
const TIME_PER_CHAR := 0.3
const PASSWORD := "gforce"
const MESSAGE := "Enter a word that reminds you of the pandemic"

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
var _password_mode := false
var _password := ""
var _shift_down := false

onready var _text_display = $TextDisplay as Label
onready var _word_list = $WordList as RichTextLabel
onready var _clear_timer = $ClearTimer as Timer
onready var _advance_timer = $AdvanceStringTimer as Timer
onready var _foreground = $CityContainer/Foreground as Label
onready var _midground = $CityContainer/Midground as Label
onready var _background = $CityContainer/Background as Label
onready var _password_field = $PopupPanel/Password/Password as Label
onready var _password_container = $PopupPanel/Password as VBoxContainer
onready var _menu_container = $PopupPanel/Menu as VBoxContainer
onready var _popup = $PopupPanel as Panel
onready var _settings_button = $Settings as Button
onready var _music = $AudioStreamPlayer as AudioStreamPlayer
onready var _click = $Click as AudioStreamPlayer


func _ready()->void:
	_music.play()
	
	_text_display.text = MESSAGE
	var generator := SkylineGenerator.new()
	var dict := generator.compile()
	_foreground_sequence = dict["foreground"]
	_background_sequence = dict["background"]
	_midground_sequence = dict["midground"]
	
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
	
	_clear_timer.wait_time = number_of_chars * TIME_PER_CHAR * 1.2
	_advance_timer.wait_time = TIME_PER_CHAR


func _input(event:InputEvent)->void:
	if event is InputEventKey:
		var scancode = event.scancode
		if event.is_pressed():
			if SCANCODE_ALPHABET.keys().has(scancode):
				var letter : String = SCANCODE_ALPHABET[scancode]
				if _shift_down:
					letter = letter.capitalize()
				if _password_mode:
					_password += letter
					_password_field.text = _password
				else:
					_word_being_typed += letter
					_text_display.text = _word_being_typed
			
			if scancode == ENTER and (_word_being_typed.length() > 0 or _password_mode):
				_submit_word()
			
			if scancode == BACKSPACE:
				if _password_mode:
					_password.erase(_password.length() - 1, 1)
					_password_field.text = _password
				else:
					_word_being_typed.erase(_word_being_typed.length() - 1, 1)
					if _word_being_typed.length() > 0:
						_text_display.text = _word_being_typed
					else:
						_text_display.text = MESSAGE
			
			if scancode == SHIFT:
				_shift_down = true
		
		else:
			if scancode == SHIFT:
				_shift_down = false


func _submit_word()->void:
	if _password_mode:
		if _password.to_lower() == PASSWORD:
			_settings_button.focus_mode = Control.FOCUS_CLICK
		else:
			_popup.visible = false
		_hide_password()
	else:
		if _clear_timer.is_stopped() and not _is_clearing:
			_clear_timer.start()
		
		if _words_entered.keys().has(_word_being_typed):
			_words_entered[_word_being_typed] = _words_entered[_word_being_typed] + 1
		else:
			_words_entered[_word_being_typed] = 1
		_update_wordlist()
		
		# adds word at start of _all_words
		_all_words = _word_being_typed + _all_words
		_word_being_typed = ""
		_text_display.text = MESSAGE


func _clear()->void:
	_character_index = 0
	_character_counter = 0
	_clear_timer.stop()
	_word_list.text = ""
	_scrolling_array.empty()
	_all_words = ""
	_words_entered.clear()
	_foreground.text = ""
	_background.text = ""
	_midground.text = ""


func _hide_password()->void:
	_password = ""
	_password_field.text = ""
	_password_mode = false
	_password_container.visible = false
	_menu_container.visible = true


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


func _on_Settings_pressed()->void:
	_click.play()
	_popup.visible = true
	_password_container.visible = true
	_menu_container.visible = false
	_password_mode = true
	_settings_button.focus_mode = Control.FOCUS_NONE


func _on_ClearButton_pressed()->void:
	_click.play()
	_clear()


func _on_FullScreen_toggled(button_pressed:bool)->void:
	_click.play()
	OS.window_fullscreen = button_pressed


func _on_Done_pressed()->void:
	_click.play()
	_popup.visible = false


func _on_Mute_pressed(button_pressed:bool)->void:
	_click.play()
	AudioServer.set_bus_mute(0, button_pressed)
