extends Control

export(Dictionary) var actions = {
	#"jump"    : {"label": "Jump", "key": to_inputevent(KEY_SPACE)},
	"skip"     : {label = "Skip Text Animation", key = to_inputevent(KEY_SPACE) },
	"termhist" : {label = "Type Last Command"  , key = to_inputevent(KEY_UP   ) },
}

var ActionNode = preload("res://elements/KeyChangeEntry.tscn")

export(NodePath) var signal_target = null

signal went_back

func _ready():
	self.visible = false
	$Panel/Scroll/KeyList.anchor_right = 1

	if typeof(signal_target) == TYPE_NODE_PATH:
		signal_target = get_node(signal_target)

		if self.connect("went_back", signal_target, "_on_keybindmenu_exit") != OK:
			push_error("Failed to connect keybind signal")

	if !Settings.setting.keybinds.empty():
		for action in Settings.setting.keybinds.keys():
			if actions.has(action):
				actions[action].key = to_inputevent(OS.find_scancode_from_string(Settings.setting.keybinds[action]))
			else: # remove action bind we don't have anymore
				Settings.setting.keybinds.erase(action)

	for action in actions:
		add_keybind_entry(action)

	Settings.update() # Save any setting changes by add_keybind_entry above

func add_keybind_entry(entry):
	var keychangeentry = ActionNode.instance()

	keychangeentry.ACTION = entry
	keychangeentry.LABEL = actions[entry].label + " - "

	if !InputMap.has_action(entry):
		InputMap.add_action(entry)
		InputMap.action_add_event(entry, actions[entry].key)

		Settings.setting.keybinds[entry] = OS.get_scancode_string(actions[entry].key.scancode)

	$Panel/Scroll/KeyList.add_child(keychangeentry)

func to_inputevent(x):
	var out = InputEventKey.new()

	out.set_scancode(x)

	return out

func _on_button_activate(button):
	$Back/Blip.volume_db = -4.0 + Settings.setting.audio_volume_shift
	$Back/Blip.play()
	if button == "back":
		self.visible = false
		emit_signal("went_back")
