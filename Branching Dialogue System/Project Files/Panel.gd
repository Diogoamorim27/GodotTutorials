extends Panel

onready var choice_container : VBoxContainer = $VBoxContainer
onready var dialog_manager = $DialogManager
onready var dialog_text_box : Label = $Label
onready var soup_check_box : CheckBox = $CheckBox

var choice_buttons = {}
var soup_pressed

func _ready():
	dialog_manager.start_dialog()
	

func _process(delta):
	soup_pressed = soup_check_box.pressed
	for button in choice_buttons:
		if choice_buttons[button].pressed:
			dialog_manager.choice_picked(button)

func _on_DialogManager_new_speech(speech_codes):
	if !choice_buttons.empty():
		for button in choice_buttons:
			choice_buttons[button].queue_free()
		choice_buttons.clear()
	dialog_text_box.text = speech_codes[0]


func _on_Panel_gui_input(event):
	if  event.is_action_pressed("mouse_click"):
		dialog_manager.continue_dialog()
	

func _on_DialogManager_new_choice(choices):
	print(choices)
	if choice_buttons.empty():
		var choice_index = 0
		for choice in choices:
			choice_buttons[choice_index] = Button.new()
			choice_container.add_child(choice_buttons[choice_index])
			choice_buttons[choice_index].text = choice
			choice_index += 1


func _on_DialogManager_dialog_finished():
	queue_free()
