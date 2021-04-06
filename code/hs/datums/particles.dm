/obj/Particle
	skull
		icon_state = "fucking_death"
		time_to_disappear = 5
		Particle_Ready()
			..()
			y_pos = 14+(sin(timer*10)*24)
	leo
		icon_state = "leo"
		time_to_disappear = 14
		Particle_Ready()
			..()
			x_pos = 16+(sin(timer*10)*24)
			y_pos = 16+(cos(timer*10)*12)
			animate(src, pixel_z = -100, time = 10, easing = ELASTIC_EASING)
	attack
		icon_state = "attack"
		time_to_disappear = 14
		Particle_Ready()
			..()
			animate(src, pixel_z = -100, time = 10, easing = ELASTIC_EASING)
	luck
		name = "Lucky!"
		icon_state = "luck"
		time_to_disappear = 20
		Particle_Ready()
			..()
			x_pos = 16+(sin(timer*10)*12)
			y_pos = 16+(cos(timer*10)*6)
			if(y_pos > 16)
				layer = 2.9
			else
				layer = 3.1

	firecircle
		name = "Fire Circle"
		icon_state = "firecircle"
		time_to_disappear = 10
		Particle_Ready()
			..()
			x_pos = 16+(sin(timer*10)*12)
			y_pos = 16+(cos(timer*10)*6)
			if(y_pos > 16)
				layer = 2.9
			else
				layer = 3.1

	honeypot
		icon_state = "honeypot"
		time_to_disappear = 6
		Particle_Ready()
			..()
			animate(src,
				transform = matrix(20, MATRIX_ROTATE),
				time = 4, loop = -1,
				easing = SINE_EASING)

			animate(src,
				transform = matrix(-20, MATRIX_ROTATE),
				time = 4,
				easing = SINE_EASING)


	rage
		name = "Rage"
		icon_state = "rage"
		time_to_disappear = 2