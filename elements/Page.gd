extends Control

var _queue = false
var _queued_text
var _queued_text_clean
var _step = 1
var _letter_step = 1
var _resume = false

signal start_hacking
signal start_next

var content_set = false

func _ready():
	update_help_text()

	$Blip.volume_db += Settings.setting.audio_volume_shift

	if self.connect("start_hacking", get_parent(), "start_hacking") != OK:
		push_error("Parent doesn't handle hack requests")

	if self.connect("start_next", get_parent(), "start_next") != OK:
		push_error("Parent doesn't handle next requests")

func update_help_text():
	$Help.text = "Press [%s] to skip text animation" % Settings.setting.keybinds.skip

func set_content(contents: String):
	content_set = true

	if contents.length() > 0:
		_queue = true
		_resume = false
		if Settings.setting.typing_sounds:
			$Blip.play()
	else:
		$Content.bbcode_text = ""

	_step = 1
	_letter_step = 1
	_queued_text = (contents
		).replace(","      , ",`"           #1
		).replace("."      , ".``"          #2
		).replace("?"      , ".```"         #3
		).replace("!"      , ".```"         #3
		).replace("[brk]"  , "`````"        #5
	)
	_queued_text_clean = (contents
		).replace("[brk]", ""
		).replace("[hack]", "[color=#00ff00][url=starthack_"
		).replace("[/hack]", "]Begin Decrypting[/url][/color]"
		).replace("[hackguess]", "[color=#00ff00][url=starthack_"
		).replace("[/hackguess]", "]Try Guess-Decrypting (optional)[/url][/color]"
		).replace("[next]", "[color=#9999ff][url=startnext_"
		).replace("[/next]", "]Wait for clues (continue story)[/url][/color]"
	)

func _on_meta_clicked(meta):
	if _queue:
		return

	meta = str(meta)

	$ButtonBlip.play()

	if meta.begins_with("starthack_"):
		emit_signal("start_hacking", meta.substr("starthack_".length(), -1))
	elif meta.begins_with("startnext_"):
		emit_signal("start_next", meta.substr("startnext_".length(), -1) as int)

func _on_keybindmenu_exit():
	update_help_text()

var _text_timer = 0
func _process(delta):
	if _queue:
		_text_timer += delta

		if _text_timer > 0.02:
			_text_timer = 0

			while true:
				if _step >= 1 && _step < _queued_text.length():
					if _queued_text[_step - 1] == "[":
						var skip = _queued_text.find("]", _step - 1) - (_step - 1)

						if skip > 0:
							_letter_step += skip
							_step += skip
							continue

					if _queued_text[_step - 1] == "`":
						_step += 1
						if !_resume:
							_resume = true
							$Blip.stop()
						_text_timer = -0.14
						break
					else:
						if Settings.setting.typing_sounds && _resume:
							_resume = false
							$Blip.play()

						$Content.bbcode_text = _queued_text_clean.left(_letter_step)
						_letter_step += 1
						_step += 1
				else:
					$Content.bbcode_text = _queued_text_clean
					_queue = false
					$Blip.stop()

				break

	if Input.is_action_just_released("skip"):
		_step = 0
