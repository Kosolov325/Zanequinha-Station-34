/mob/living/carbon/human/
	verb/CheckMood()
		set category = "Mood"
		set name = "Check Mood"

		if(mood)
			var/mood_text = mood_handler.currentMoodDescs()
			usr << "\white ||||||||||||||||||||"
			usr << "\white Your mood is:"
			usr << mood_text
			usr << "\white Mood meter:"
			usr << mood * 10
			usr << "[mood * 10 > 50 ? mood * 10 >= 100? "\green" : mood * 10 <= 20 ? "\red" : "\yellow" : "\black" ] [ValueToMeter(usr:mood)]"
			usr << "\white ||||||||||||||||||||"
		else
			usr << "\red You have no mood!"

	Stat()
		..()
		statpanel("Status",{"<font color=#b54d4d><IMG SRC='[src.icon]' ICONSTATE="[src.icon_state]" ICONDIR=SOUTH><b>[src.name]</b></font>"})


proc/ValueToMeter(value)
	var/_value = value * 10
	var/text = ""
	switch(_value)
		if(1 to 10)
			text = "|||"
		if(11 to 20)
			text = "||||"
		if(21 to 30)
			text = "|||||"
		if(31 to 40)
			text = "||||||"
		if(41 to 50)
			text = "|||||||"
		if(51 to 60)
			text = "||||||||"
		if(61 to 70)
			text = "|||||||||"
		if(71 to 80)
			text = "||||||||||"
		if(81 to 90)
			text = "|||||||||||"
		if(91 to 100)
			text = "||||||||||||"
	return text