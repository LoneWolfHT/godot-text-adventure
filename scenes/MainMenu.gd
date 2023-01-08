extends Control

func _on_button_activate(button):
	if button == "exit":
		Quit.quit()
	elif button == "restart":
		Settings.setting.current_page = 0
		Settings.setting.score        = 0
		$ResetSave.visible = false
	elif button == "keybinds":
		$KeyChangeMenu.visible = true
