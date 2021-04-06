/mob/living/carbon/bee
	name = "bee"
	desc = "These look really big. Are they even bees?"
	voice_name = "bee"
	voice_message = "buzzes"
	icon = 'bee.dmi'
	icon_state = "petbee-wings"
	heightSize = 14
	var/l_delay = 0
	var/nice = 0
	var/s = 0
	var/mob/owner
	var/recalling = FALSE
	gender = NEUTER
	New()
		..()
		nice = nice + rand(0,90)
	ProcessHeight()
		nice = nice + 2
		s = 16+(sin(nice)*4)
		heightZ = ((((s) - heightZ)/8) + heightZ)

		ySpeed = 0
		..()
	Life()
		if(world.time < l_delay)
			return
		if(!client)
			while(recalling == TRUE && owner)
				spawn(tick_lag_original)
					spawn(1) src.Dash_Effect(src.loc)
					density = 0
					walk_towards(src,owner,0.5,0)
					spawn(1)
						if(get_dist(owner,src) <= 1)
							recalling = FALSE
							density = 1
					spawn(tick_lag_original * 500) recalling = FALSE
				sleep(tick_lag_original)

			step_rand(src)
			l_delay = world.time+rand(5,7)

	proc/changeRecalling()
		recalling = !recalling