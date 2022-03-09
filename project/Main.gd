extends Control

const SCANCODE_ALPHABET := {32:" ", 65:"a", 66:"b", 67:"c", 68:"d", 69:"e", 70:"f", 71:"g", 72:"h", 73:"i", 74:"j", 75:"k", 76:"l", 77:"m", 78:"n", 79:"o", 80:"p", 81:"q", 82:"r", 83:"s", 84:"t", 85:"u", 86:"v", 87:"w", 88:"x", 89:"y", 90:"z"}
const ENTER := 16777221
const BACKSPACE := 16777220

var _word_being_typed := ""
var _words_entered := []

onready var _text_display = $TextDisplay as Label


func _input(event:InputEvent)->void:
	if event is InputEventKey:
		#event = event as InputEventKey
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
	_words_entered.append(_word_being_typed)
	_word_being_typed = ""
	_text_display.text = _word_being_typed
