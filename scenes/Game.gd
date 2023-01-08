extends Node2D

var words = [
	"PROJECT",
	"HARVEST",
	"EXPLOSION",
	"MESSENGER",
	"ALIEN",
	"PLANET",
	"CANDY",
	"MASSIVE",
	"DESTRUCTION",
	"DECONSTRUCTION",
	"EXTRATERRESTRIAL",
	"BLACKHOLE",
	"ANOMALY",
	"CONTRAPTION",
	"SPACESHIP",
	"MYSTERY",
	"UNIDENTIFIED",
	"COUNCIL",
	"ENGINEERING",
	"DESIGN",
	"BLUEPRINTS",
	"MATERIAL",
	"ASSEMBLY",
	"INTEGRITY",
	"TESTING",
]

var story = {
"0":
"""Consider the word [b]HARVEST[/b][brk]... to most people that probably suggests fresh produce, or the grim reaper,[brk] but for you, it's your latest job[brk]...

The government recently got their hands on an encrypted copy of the enemy's [i]Project HARVEST[/i] plans[brk]...
They've reached out to you for help, and you have a tool that can fully decrypt them, but you first need to decrypt a few specific key words[brk].

[color=#9999ff]<Agent>[/color] Greetings, I've sent you the first set of data from the encrypted documents.
[color=#9999ff]<Agent>[/color] I will send you any intel on what they might contain as soon as we learn of it. For now all we know is that this is about Project HARVEST

[hack]start[/hack]
""",

"1":
"""[color=#9999ff]<Agent>[/color] Nice work. We'll start [brk]'harvesting', that data for potential future keywords, haha.
[color=#9999ff]<Agent>[/color] While you wait you can try guessing at some other data if you'd like.

[hackguess]1001[/hackguess] | [next]2[/next]
""",

"1001":
"""[color=#9999ff]<Agent>[/color] Great! I'll submit that to my team too.

[url=startnext_2]Continue[/url]
""",

"2":
"""The next day...[brk]

[color=#9999ff]<Agent>[/color] Alright. It looks like Project HARVEST involves causing a [i]huge[/i] explosion, [i]aliens[/i], and deconstruction of one of their ships for research purposes.
[color=#9999ff]<Agent>[/color] They've either lost it or our surveillance department has been slacking.[brk]
We'll need that next page decrypted to learn more.

[hack]steptwo[/hack]
""",

"3":
"""[color=#9999ff]<Agent>[/color] Nice. My team has begun research on the latest data.

[hackguess]1003[/hackguess] | [next]4[/next]
""",

"1003":
"""[color=#9999ff]<Agent>[/color] Great! I'll submit that to my team too.

[url=startnext_4]Continue[/url]
""",

"4":
"""The next day...[brk]

[color=#9999ff]<Agent>[/color] The data is processed. We're going to assume they're not crazy until we can get to the bottom of this.
[color=#9999ff]<Agent>[/color] Project Harvest is a giant spaceship filled with some sort of ransom payment, and enough explosives to destroy their target, which is probably where the ransom is being sent.[brk]
[color=#9999ff]<Agent>[/color] Hurry up and finish this next set of data. We need to figure out what they're targeting.

[hack]ransom[/hack]
""",

"5":
"""[color=#9999ff]<Agent>[/color] Good work. I'll get this sent over.

[hackguess]1005[/hackguess] | [url=startnext_2005]Mention the 'candy' keyword[/url] | [next]6[/next]
""",

"2005":
"""[color=#9999ff]<Agent>[/color] The ransom payment is candy? Must be a codename, I'll have my team look into it.

[hackguess]1005[/hackguess] | [next]6[/next]
""",

"1005":
"""[color=#9999ff]<Agent>[/color] Great! I'll submit that to my team too.

[url=startnext_6]Continue[/url]
""",

"6":
"""8 hours later...[brk]

[color=#9999ff]<Agent>[/color] The data is processed. We still don't know what CANDY stands for, I draw the line at it being literal. Why not sugar, drugs, or humans?
[color=#9999ff]<Agent>[/color] The target is the alien's home planet. The ship is going to be sent there, but they're still building it.
[color=#9999ff]<Agent>[/color] The next set of data will probably explain how to construct the ship, why the alien is unable to give them one large enough, and how they plan to destroy a large planet.

[color=#9999ff]<Agent>[/color] I said to hurry before, but hurry faster, we need to learn more about these explosive(s) of theirs

[hack]hurryfaster[/hack]
""",

"7":
"""[color=#9999ff]<Agent>[/color] Sending to my team. This should have all we need to know regarding the explosions. Going to skim over it...

(Two minutes pass)[brk]

[color=#9999ff]<Agent>[/color] Done, the next part is probably about their construction and research locations.
[color=#9999ff]<Agent>[/color] The government is preparing their best strike teams. This data will tell them how to handle things. All they need are those locations. Get to work.

[hack]locations[/hack]
""",

"8":
"""[color=#9999ff]<Agent>[/color] Well done. Just one set of data left. The strike teams have headed out.

[hack]foreboding[/hack]
""",

"9":
"""[color=#9999ff]<Agent>[/color] A trap?[brk]
[color=#9999ff]<Agent>[/color] OH SHOOT, I need to warn them. Your job is done, will send pay later

[color=#9999ff][CHAT CLOSED][/color][brk]

[color=#339922][NEW MESSAGE FROM UNKNOWN]:[/color][brk][brk]

[color=#339922]<Harvest Moon>[/color] Hello, nice work. You might find this data to be of interest:[brk] >[hack]theend[/hack]<
""",

"1337":
"""[center]Thanks for playing to the end![/center]

As you've probably guessed, that's all there is for now. I might continue the story in a future game though.

I don't think my 'wordle' puzzle is as fun to play as it could be. But if for some reason you enjoyed it you can play more below:

[hack]allwords[/hack]
""",

# "pagenum":
# """The next day...[brk]

# [color=#9999ff]<Agent>[/color] Hello Sir

# [hack][/hack]
# """,


}

var _last_page = -1
var _hacking = false

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	$Music.volume_db += Settings.setting.audio_volume_shift

	update_game(Settings.setting.current_page as String)

func start_next(page):
	Settings.setting.current_page = page

	update_game(page as String)

func start_hacking(command):
	_hacking = true

	update_game(Settings.setting.current_page as String)

	if command == "start":
		$HackingScreen.bringup("start", [
			"PROJECT",
			"HARVEST"
		], false, true, true)
	elif command == "steptwo":
		$HackingScreen.bringup("steptwo", [
			"MASSIVE",
			"EXTRATERRESTRIAL",
			"SPACESHIP",
		], false, true, true)
	elif command == "ransom":
		$HackingScreen.bringup("ransom", [
			"CANDY",
			"PLANET",
		], false)
	elif command == "hurryfaster":
		$HackingScreen.bringup("hurryfaster", [
			"BLUEPRINTS",
			"MESSENGER",
			"BLACKHOLE",
		], false)
	elif command == "locations":
		$HackingScreen.bringup("locations", [
			"ANTARCTICA",
			"INDIANOCEAN"
		], false)
	elif command == "foreboding":
		$HackingScreen.bringup("foreboding", [
			"INTERFERENCE",
			"TRAP"
		], false, true)
	elif command == "theend":
		$HackingScreen.bringup("theend", [
			"TO",
			"BE",
			"CONTINUED",
		], false)
	elif command == "allwords":
		var list = words.duplicate(true)

		randomize()
		list.shuffle()

		$HackingScreen.bringup("theend", list, false)
	else:
		var queue = []

		for _i in range(1, rng.randi_range(2, 5)):
			queue.push_back(words[rng.randi_range(0, words.size()-1)])

		$HackingScreen.bringup(command, queue, true)

func stop_hacking(success = false, id = ""):
	_hacking = false

	if success:
		if id == "start":
			Settings.setting.current_page = 1
		elif id == "steptwo":
			Settings.setting.current_page = 3
		elif id == "ransom":
			Settings.setting.current_page = 5
		elif id == "hurryfaster":
			Settings.setting.current_page = 7
		elif id == "locations":
			Settings.setting.current_page = 8
		elif id == "foreboding":
			Settings.setting.current_page = 9
		elif id == "theend":
			Settings.setting.current_page = 1337
		else:
			Settings.setting.current_page = id as int

	update_game(Settings.setting.current_page as String)

func update_game(current_page):
	Settings.update()

	if _hacking:
		$Page.visible = false
	elif story.has(current_page):
		$Page.visible = true
		$HackingScreen.visible = false

		if !$Page.content_set || _last_page != current_page:
			$Page.set_content(story[current_page])
			_last_page = current_page
	else:
		$Page.set_content(current_page + ": [color=red]Whoops, something went wrong, this page doesn't exist[/color]")

func _on_button_activate(button):
	$Blip.volume_db = -4.0 + Settings.setting.audio_volume_shift
	$Blip.play()

	if button == "keybinds":
		$KeyChangeMenu.visible = true
