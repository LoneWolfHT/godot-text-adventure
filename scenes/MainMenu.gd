extends Control

var _queue_quit = false
var _queue_play = false

func _ready():
	$Music.volume_db = 0.0 + Settings.setting.audio_volume_shift
	$Toggles/TypeSounds.pressed = Settings.setting.typing_sounds
	$Toggles/ExtraHints.pressed = Settings.setting.always_extra_hints


func _on_button_activate(button):
	$Blip.volume_db = -4.0 + Settings.setting.audio_volume_shift
	$Blip.play()

	if button == "exit":
		_queue_quit = true
	elif button == "play":
		_queue_play = true
	elif button == "restart":
		Settings.setting.current_page = 0
		Settings.setting.score        = 0
		$ResetSave.visible = false
	elif button == "keybinds":
		$KeyChangeMenu.visible = true

func _on_TypeSounds_toggled(button_pressed: bool):
	if Settings.setting.typing_sounds == button_pressed:
		return

	Settings.setting.typing_sounds = button_pressed

	if button_pressed:
		$Toggles/TypeSounds/Blip.pitch_scale = 1.1
	else:
		$Toggles/TypeSounds/Blip.pitch_scale = 0.9

	$Toggles/TypeSounds/Blip.volume_db = 0.0 + Settings.setting.audio_volume_shift
	$Toggles/TypeSounds/Blip.play()


func _on_Blip_finished():
	if _queue_quit:
		Quit.quit()
	elif _queue_play:
		if(get_tree().change_scene("res://scenes/Game.tscn") != OK):
			push_error("Failed to load game")


func _on_ExtraHints_toggled(button_pressed:bool):
	if Settings.setting.always_extra_hints == button_pressed:
		return

	Settings.setting.always_extra_hints = button_pressed

	if button_pressed:
		$Toggles/ExtraHints/Blip.pitch_scale = 1.1
	else:
		$Toggles/ExtraHints/Blip.pitch_scale = 0.9

	$Toggles/ExtraHints/Blip.volume_db = 0.0 + Settings.setting.audio_volume_shift
	$Toggles/ExtraHints/Blip.play()


func _on_Timer_timeout():
	$Music.volume_db = 0.0 + Settings.setting.audio_volume_shift
