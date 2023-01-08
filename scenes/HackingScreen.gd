extends Control

signal stop_hacking

var _words = []
var _current_word
var _last_guess
var _solved = {}

var _id = ""
var _done = false
var _queue = false
var _text = ""
var _text_clean = ""
var _step = 1
var _letter_step = 1
var _extra_help = false
var _random = false
var _resume = false

var _command_history = []

func _ready():
	if self.connect("stop_hacking", get_parent(), "stop_hacking") != OK:
		push_error("Parent doesn't handle hack requests")

	$Screen/Blip.volume_db += Settings.setting.audio_volume_shift
	$Input/Blip.volume_db  += Settings.setting.audio_volume_shift
	$Blip.volume_db  += Settings.setting.audio_volume_shift

	$CheatSheet/BG/commands.bbcode_text = "[color=#00ff00][url]help[/url][/color]\n[color=#00ff00][url]exit[/url][/color]\n[color=#00ff00][url]clear[/url][/color]\n[color=#00ff00][url]goal[/url][/color]\n[color=#00ff00]guess <word>[/color]"

func bringup(id, newwords, random = false, showfirst = false, help = false):
	if id != _id:
		_words = newwords
		_current_word = 0
		_random = random
		_extra_help = help || random || Settings.setting.always_extra_hints
		_id = id
		_done = false
		_solved = {}
		_command_history = []

		if !showfirst:
			_last_guess = "[color=red]%s[/color]" % "_".repeat(newwords[0].length())
		else:
			_solved[0] = newwords[0][0]
			_last_guess = "[color=#2099FF]%s[/color][color=red]%s[/color]" % [
				newwords[0][0],
				"_".repeat(newwords[0].length()-1),
			]

	self.visible = true
	$Input/Terminal.text = ""
	$Input/Terminal.grab_focus()

	update_help_text()

	if random:
		write_terminal("Decryption coordinates randomized\n")

	write_terminal("Terminal Restored.\n")
	_show_goal()

func update_help_text():
	var text = "Press [%s] to type out your last command\nLetters will turn [color=#2099FF]blue[/color] if they match the word you're decrypting" % Settings.setting.keybinds.termhist

	if _extra_help:
		text += " and [color=yellow]yellow[/color] if they are found somewhere else in the word."
	else:
		text += "| [color=yellow]yellow[/color] letters are disabled (Force-enable them with the extra hints setting)."

	if !_random:
		text += "\nIf you get stuck you can [code][color=#00ff00][url]exit[/url][/color][/code] to check the story for clues. Or just [code][color=#00ff00][url]!cheat[/url][/color][/code]"

	$Help.bbcode_text = text

func set_content(contents: String = "", startpos = 1, letter_startpos = 1):
	if contents.length() > 0:
		_queue = true
		if Settings.setting.typing_sounds && !$Screen/Blip.playing:
			_resume = true
		else:
			_resume = false
	else:
		$Screen/Content/Text.bbcode_text = ""

	_step = startpos
	_letter_step = letter_startpos
	_text = (contents
		).replace("[brk]"  , "````" #4
	)
	_text_clean = contents.replace("[brk]", "")

func write_terminal(text):
	set_content(_text + text, _step, _letter_step)

func _on_keybindmenu_exit():
	update_help_text()

var _text_timer = 0
func _process(delta):
	if !self.visible:
		return

	if Input.is_action_just_pressed("termhist"):
		if _command_history.size() >= 1:
			$Input/Terminal.text = _command_history.pop_back()
			$Input/Terminal.cursor_set_column($Input/Terminal.text.length())

	if _queue:
		_text_timer += delta

		if _text_timer > 0.02:
			_text_timer = 0

			while true:
				if _step >= 1 && _step < _text.length():
					var inc = 3

					if "[" in _text.substr(_step - 1, inc):
						var skip = _text.find("[", _step - 1) - (_step - 1)

						if skip <= 0:
							skip = _text.find("]", _step) - _step

						if skip > 0:
							_letter_step += skip + 2
							_step += skip + 2
							continue

					if "`" in _text.substr(_step - 1, inc):
						if _text[_step - 1] == "`":
							_step += 1
							_text_timer = -0.2

							if !_resume:
								_resume = true
								if $Screen/Blip.playing:
									$Screen/Blip.stop()
							break
						else:
							inc = 1

					if Settings.setting.typing_sounds && _resume && !$Screen/Blip.playing:
						_resume = false
						$Screen/Blip.play()

					$Screen/Content/Text.bbcode_text = _text_clean.left(_letter_step)
					_letter_step += inc
					_step += inc
				else:
					$Screen/Content/Text.bbcode_text = _text_clean
					_queue = false
					if $Screen/Blip.playing:
						$Screen/Blip.stop()

				break

# return false to refuse
func command(text, clicked = false):
	text = text.strip_escapes().strip_edges().split(" ")

	if clicked && text[0] != "help" && $Input/Terminal.text == "help ":
		command("help " + text[0], true)
		$Input/Terminal.text = ""
		return

	if clicked:
		if (text.size() == 1 && text[0] != "help") && text[0] != "exit":
			write_terminal("[>] %s\n" % $Input/Terminal.text)
	else:
		write_terminal("> %s\n" % $Input/Terminal.text)

		if _command_history.size() >= 50:
			_command_history.pop_front()

		_command_history.push_back($Input/Terminal.text.strip_escapes())

	if text[0] == "help":
		if text.size() > 1:
			if text[1] == "exit":
				write_terminal("[color=white]exit[/color]: Closes the terminal and returns you to the story\n")
				return
			elif text[1] == "clear":
				write_terminal("[color=white]clear[/color]: Clears the terminal. (May help with bugs)\n")
				return
			elif text[1] == "goal":
				write_terminal("[color=white]goal[/color]: Prints your current decryption progress\n")
				return
			elif text[1] == "guess":
				write_terminal("[color=white]guess <word>[/color]: Make a guess at the word you're currently decrypting\n")
				return

		if clicked && $Input/Terminal.text == "":
			$Input/Terminal.insert_text_at_cursor("help ")
			$Input/Terminal.cursor_set_column($Input/Terminal.text.length())
			return

		write_terminal("You can run [color=white]help <command>[/color] for an explanation of that command\nCommands are listed in the cheatsheet\n")
	elif text[0] == "exit":
		write_terminal("Terminal Closed.\n\n")

		if !_done:
			emit_signal("stop_hacking")
		else:
			_clear_terminal()
			emit_signal("stop_hacking", true, _id)
	elif text[0] == "goal":
		_show_goal()
	elif !_done && text[0] == "!cheat":
		if text.size() > 1:
			if text[1] == "show":
				write_terminal(_words[_current_word] + "\n")
				return
			elif text[1] == "do":
				_make_guess(_words[_current_word])
				return

		write_terminal(
"""Here are some cheats, courtesy of the hacker 'Harvest Moon':
[color=white]!cheat show[/color]: Shows the word you're trying to decrypt
[color=white]!cheat do[/color]: Decrypts the current word for you
"""
			)
	elif text[0] == "guess":
		if _done:
			write_terminal("You already guessed the key words. Type [color=white]exit[/color] to continue\n")
		elif text.size() > 1:
			if text[1].length() == _words[_current_word].length():
				_make_guess(text[1])
			else:
				if text[1].length() - _words[_current_word].length() > 0:
					write_terminal("%d too many characters\n" % (text[1].length() - _words[_current_word].length()))
				else:
					write_terminal("%d too few characters\n" % (_words[_current_word].length() - text[1].length()))

				return false
		else:
			write_terminal("Please submit a guess ([color=white]guess <word>[/color])\n")
			return false
	elif text[0] == "clear":
		_clear_terminal()
	else:
		if text.size() <= 1:
			write_terminal("Converting command to guess:\n")
			command("guess " + text[0], true)
		else:
			write_terminal("Invalid Command.\n")

func _on_Terminal_text_changed():
	if !self.visible:
		return

	if "\n" in $Input/Terminal.text:
		$Input/Terminal.text = $Input/Terminal.text.strip_escapes()
		var result = command($Input/Terminal.text)

		if typeof(result) == TYPE_BOOL && !result:
			if Settings.setting.typing_sounds:
				$Input/Blip.pitch_scale = 0.4

				$Input/Blip.play()

			$Input/Terminal.cursor_set_column($Input/Terminal.text.length())
		else:
			if Settings.setting.typing_sounds:
				if $Input/Terminal.text.begins_with("!"):
					$Input/Blip.pitch_scale = 0.3
				else:
					$Input/Blip.pitch_scale = 1.2

				$Input/Blip.play()

			$Input/Terminal.text = ""
	elif Settings.setting.typing_sounds:
		if $Input/Terminal.text.begins_with("!"):
			$Input/Blip.pitch_scale = 0.5
			$Input/Blip.play()
		else:
			$Input/Blip.pitch_scale = 1.0
			$Input/Blip.play()



func _on_commands_meta_clicked(meta):
	meta = str(meta)

	$Blip.play()

	command(meta, true)

func _show_goal():
	if !_done:
		write_terminal("\nGoal: %d/%d words guessed.\nCurrent Word: [color=white]|[/color]%s[color=white]|[/color]\n" % [
			_current_word,
			_words.size(),
			_last_guess,
		])
	else:
		write_terminal("\nGoal: %d/%d words guessed.\nLast Word: [color=white]|[/color]%s[color=white]|[/color]\n%s\n" % [
			_words.size(),
			_words.size(),
			_last_guess,
			"Type [color=white]exit[/color] to continue",
		])

func _make_guess(guess):
	guess = guess.to_upper()
	_last_guess = ""

	var wrongs = 0
	var guessedit = ""
	for i in range(0, guess.length()):
		var color = "white"

		if _solved.has(i) || guess[i] == _words[_current_word][i]:
			_last_guess += "[color=#2099FF]%s[/color]" % _words[_current_word][i]

			if !_solved.has(i):
				_solved[i] = _words[_current_word][i]
			else:
				guess[i] = _solved[i]
				color = "#2099FF"

		elif _extra_help && guess[i] in _words[_current_word]:
			_last_guess += "[color=yellow]%s[/color]" % guess[i]
			wrongs += 1
		else:
			_last_guess += "[color=red]%s[/color]" % guess[i]
			wrongs += 1

		guessedit += "[color=%s]%s[/color]" % [color, guess[i]]

	write_terminal("You guess %s: " % guessedit)

	if wrongs == 0:
		write_terminal("Word decrypted. ")

		if _current_word == _words.size() - 1: #All done
			_done = true
			write_terminal("\nDecrypting the rest of the data[brk].[brk].[brk].[brk]\nDone. Type [color=white]exit[/color] to continue\n")
			return
		else:
			_current_word += 1
			_solved = {}
			_last_guess = "[color=red]%s[/color]" % "_".repeat(_words[_current_word].length())

		write_terminal("Moving to next one...\n")
		_show_goal()
	else:
		write_terminal("[color=white]|[/color]%s[color=white]|[/color]\n" % _last_guess)

func _clear_terminal():
	_resume = false
	set_content()

	if $Screen/Blip.playing:
		$Screen/Blip.stop()
