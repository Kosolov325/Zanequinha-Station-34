/image/slime_face
	icon = 'blobbies.dmi'
	icon_state = "aslime-:)"
	appearance_flags = RESET_COLOR

/mob/living/carbon/blobby
	name = "blobby"
	voice_name = "blobby"
	icon = 'blobbies.dmi'
	desc = "Ranchero De Slimes!"
	icon_state = "grey baby slime"
	pixel_y = -4
	color = "#DD4569"
	heightSize = 17
	var/l_delay = 0
	var/j_delay = 0
	gender = NEUTER
	New()
		..()
		src.overlays += new /image/slime_face
	Life()
		if(MyShadow)
			MyShadow.pixel_y = pixel_y
		if(onFloor && world.time > j_delay)
			ySpeed = rand(600,800)/256
			playsound(src, pick('bounce1.wav','bounce2.wav','bounce3.wav','bounce4.wav'), 100, 0, 4, (rand()-0.5)/10)
			j_delay = world.time+rand(2,6)
		if(world.time > l_delay)
			if(!client)
				step_rand(src)
				l_delay = world.time+rand(10,20)