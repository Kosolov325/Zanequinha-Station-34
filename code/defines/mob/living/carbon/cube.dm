//Despacito

/mob/living/carbon/baldi
	name = "baldi"
	voice_name = "baldi"
	desc = "from the edutainment game............"
	voice_message = "says"
	icon = 'cube.dmi'
	icon_state = "baldi"
	heightSize = 30
	var/l_delay = 0
	var/proceso = 0
	gender = NEUTER
	Life()
		if(!client)
			if(proceso == 0)
				proceso = 1
				spawn()
					var/mob/living/carbon/human/g = null
					for(var/mob/living/carbon/human/e in view("30x30",src))
						g = e
					if(g)
						walk_to(src,g,1,1,0)
						playsound(loc,'slap.ogg',100,1,-10)
						playsound(loc,'slap.ogg',100,1,-10)
						playsound(loc,'slap.ogg',100,1,-10)
						icon_state = "slap"
						sleep(5)
						walk(src,0)
						for(var/mob/f in orange(1,src))
							if(f.type != type)
								f:gib()
						icon_state = "baldi"
						dir = get_dir(src,g)
						sleep(20)
					proceso = 0
		else
			var/mob/living/carbon/human/targ = null
			for(var/mob/living/carbon/human/h in oview(1,src))
				targ = h
			if(targ)
				if(targ in oview(1,src))
					targ:gib()
					sleep(20)
