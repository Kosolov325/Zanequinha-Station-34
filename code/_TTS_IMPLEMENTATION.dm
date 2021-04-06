/mob
	var/tts_cooldown = 0
	var/tts_extra_pitch = 0
	proc/texttospeech(var/text)
		if(world.time > tts_cooldown)
			text2speech(text,key,src)
			tts_cooldown = world.time+5

proc/text2speech(var/text,var/name,var/mob/location)
	spawn()
		var/list/voiceslist = list()
		voiceslist["msg"] = text
		voiceslist["ckey"] = name
		var/params = list2params(voiceslist)
		text2file(params,"scripts/voicequeue.txt")
		sleep(1)
		shell("Speak.exe")
		if(fexists("sound/playervoices/[name].wav"))
			playsound(location,"sound/playervoices/[name].wav",101,1,15,location.tts_extra_pitch)

			if(fexists("scripts/voicequeue.txt"))
				fdel("scripts/voicequeue.txt")