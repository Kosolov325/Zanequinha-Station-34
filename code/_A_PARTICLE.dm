/*
credit to kaiochao for his vector2 library and spaceship movement demo which is what this uses
*/

var/list/PARTICLE_LIST = list() //List of particles to process

datum/controller/game_controller/proc/particle_process()
	for(var/obj/Particle/P in PARTICLE_LIST)
		P.Particle_Ready()
		P.Particle_Process()

/obj/Particle //Default particle object
	name = "Particle"
	mouse_opacity = 0
	plane = PARTICLE_PLANE
	icon = 'extra images/particles.dmi'
	var/x_pos = 0
	var/y_pos = 0
	var/x_spd = 0
	var/y_spd = 0 //For movable particles!!
	var/timer = 0 //Timer
	var/offset_x = -5
	var/offset_y = -5
	var/time_to_disappear = 1 //Disappear In A Second
	var/alpha_fade = -10 //wait till it fades to 0
	var/atom/owner = null
	New()
		..()
		Particle_Init()
		PARTICLE_LIST += src
	Del()
		PARTICLE_LIST -= src
		..()
	proc/Particle_Init()
	proc/Particle_Ready()
	proc/Particle_Process()
		if(owner)
			loc = locate(owner.x,owner.y,owner.z)
		//world << "PROCESSSING PARTICLE"
		x_pos = x_pos + x_spd
		y_pos = y_pos + y_spd
		pixel_w = x_pos + offset_x
		pixel_z = y_pos + offset_y
		timer = timer + tick_lag_original

		if(time_to_disappear != -1)
			if(timer > time_to_disappear)
				alpha = alpha + alpha_fade
				if(alpha < 1)
					del src

/*

default particles

*/
	crosshair
		icon = 'icons/mob/extra_overlay.dmi'
		icon_state = "crosshair"
		time_to_disappear = 1

	Water
		time_to_disappear = 3
		icon_state = "water"
		offset_x = -1
		offset_y = -1
	Explosion
		time_to_disappear = 2
		icon_state = "explosion"
		offset_x = -1
		offset_y = -1
	Spark
		time_to_disappear = 6
		alpha_fade = -255
		offset_x = -3
		offset_y = -3
		color = "#FFFF00"
		Heat
			color = "#FFA500"
			Particle_Init()
				//var/rand_angle = rand(0,360)
				y_spd = rand()*-10
				x_pos = rand(-1,33)
				y_pos = 32
				icon_state = "spark[rand(1,3)]"
		Alternate
			animate_movement = 2
			color = "#00FFFF"
			var/ang = 0
			Particle_Init()
				x_spd = 0
				y_spd = 0
				x_pos = 16
				y_pos = 16
				icon_state = "spark1"
			Particle_Ready()
				..()
				x_pos = 16+(cos(ang+(timer*10))*(timer*15))
				y_pos = 16+(sin(ang+(timer*10))*(timer*15))
		Particle_Init()
			var/rand_angle = rand(0,360)
			x_spd = cos(rand_angle)*(rand(10,30)/20)
			y_spd = sin(rand_angle)*(rand(10,30)/20)
			x_pos = 16+cos(rand_angle)*3
			y_pos = 16+sin(rand_angle)*3 //Surprisingly enough, this spread looks pretty nice.
			icon_state = "spark[rand(1,3)]"
		//intended to work as a replacement for sparks.
	Core_Particle
		time_to_disappear = -1
		plane = MACHINERY_PLANE
		Particle_Ready()
			..()
			x_pos = 16+(sin(timer*10)*12)
			y_pos = 16+(cos(timer*10)*6)
			if(y_pos > 16)
				layer = 2.9
			else
				layer = 3.1

