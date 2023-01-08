extends VScrollBar

func _ready():
	self.value = -Settings.setting.audio_volume_shift
	_update_label()

func _update_label():
	if self.value == 0:
		$Label.text = "Volume: Default"
	else:
		$Label.text = "Volume: " + ((-self.value) as String)

var queue_update = false
var timer = 0
func _process(delta):
	if (!queue_update):
		return

	timer = timer + delta

	if (timer >= 3):
		queue_update = false
		Settings.update()


func _on_VolumeSlider_value_changed(value:float):
	Settings.setting.audio_volume_shift = -value
	_update_label()
	$Blip.volume_db = 0.0 + Settings.setting.audio_volume_shift
	$Blip.play()
	queue_update = true
