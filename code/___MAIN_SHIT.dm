//THese are special variables used for The Game.

#define FLOOR_PLANE 0
#define WALL_PLANE 1
#define LIGHT_PLANE 3
#define ALARM_PLANE 2
#define CABLE_PLANE 0
#define TOP_PLANE 7
#define BELOW_SHADING 8
#define SHADING_PLANE 9
#define SPECIAL_PLANE 10
#define AIRLOCK_PLANE 5
#define MOB_PLANE 4 //ive never used these so its time to put a use to them?
#define MOB_PLANE_ALT 6
#define AREA_PLANE 10
#define WINDOW_PLANE 3
#define MACHINERY_PLANE 2
#define PARTICLE_PLANE 5
#define ITEM_PLANE 2
#define HUD_PLANE 99
#define HUD_PLANE_2 100
#define SPACE_PLANE_0 -98
#define SPACE_PLANE_1 -97

#define MAX_PLAYERS 25 //change this I guess

#define SOUND_CHANNEL_1 1120
#define SOUND_CHANNEL_AMBI 1
#define SOUND_CHANNEL_2 1000
#define SOUND_CHANNEL_3 1001
#define SOUND_CHANNEL_4 1002
#define MUSIC_CHANNEL 768
#define LOBBY_CHANNEL 767
#define MUSIC_CHANNEL_ALT 769
#define MOTOR_CHANNEL 900
#define PORTS_NOT_ALLOWED list(0,9999)
#define ALT_SERVERS list(25500,25501,25502)

#if DM_VERSION < 512
#error Your BYOND is too outdated, please use 512 or higher. Dab13 is only supposed to compile on 512, because 511 doesn't support filters and stuff like that.
#endif

/*
THE JOBS CAN BE FOUND HERE!!!!!!!!! CHANGE MAX SLOTS AS REQUIRED
*/

var
	captainMax = 1
	hopMax = 1
	hosMax = 1
	chiefMax = 1
	engineerMax = 2
	scientistMax = 2
	chemistMax = 2
	geneticistMax = 2
	securityMax = 2
	doctorMax = 2
	atmosMax = 3

	barmanMax = 2
	directorMax = 1
	detectiveMax = 2
	chaplainMax = 3
	janitorMax = 1
	clownMax = 14
	chefMax = 4
	roboticsMax = 8
	cargoMax = 5
	hydroponicsMax = 20

obj
	item
		plane = ITEM_PLANE
	machinery
		plane = MACHINERY_PLANE

mob
	plane = MOB_PLANE
	appearance_flags = PIXEL_SCALE | LONG_GLIDE


var
	const
		LIGHT_LAYER = 100
	Lighting/lighting = new()

var/tick_lag_original = 0
world
	fps = 60
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	New()
		..()
		tick_lag_original = tick_lag

proc
	animate_flash(var/type,var/atom/se)
		se.icon_state = type
		switch(type)
			if("flash")
				se.alpha = 255
				animate(se,alpha=0,time=20)
			if("e_flash")
				se.alpha = 255
				animate(se,alpha=0,time=40)

obj
	disco_ball
		icon = 'extra images/boring shit.dmi'
		icon_state = "discoball"
		anchored = 1
		New()
			..()
			special_processing += src
		Del()
			special_processing -= src
			..()
		special_process()
			if(frm_counter % 15 == 1) // A full sec
				if(light)
					animate(light, color = rgb(rand(180,255),rand(180,255),rand(180,255)), time = 2.5)
			else
				sd_SetLuminosity(10)
				if(light)
					light.intensity = 1
	spotlight
		icon = 'icons/obj/speciallighting.dmi'
		icon_state = "stand"
		plane = SPECIAL_PLANE
		anchored = 1
		var/obj/spotlight/the_light/l = null
		var/can_light = 1
		New()
			..()
			if(can_light)
				l = new(locate(x,y,z))
		Del()
			if(l)
				del l
			..()
		ex_act()
			return
		the_light
			mouse_opacity = 0
			var/sine = 0
			var/obj/spotlight/effect/A1
			icon = 'icons/obj/speciallighting3.dmi'
			icon_state = "light"
			can_light = 0
			pixel_y = -1016
			New()
				..()
				sine = sine + rand(0,360)
				special_processing += src
			Del()
				special_processing -= src
				..()
			special_process()
				sine = sine + 0.75
				var/matrix/M = matrix()
				M.Turn(sin(sine)*75)
				pixel_x = sin(sine)*-16
				pixel_y = -1028+abs(sin(sine)*16)
				transform = M
	title_screen
		icon = 'extra images/dab13.dmi'
		pixel_w = 16
		layer = 5
		mouse_opacity = 0
		plane = TOP_PLANE
		ex_act()
			return
		New()
			..()
			special_processing += src
		Del()
			special_processing -= src
			..()
		special_process()
			pixel_z = 10+(sin(frm_counter)*15)
	title_screen_shadow
		pixel_w = 16
		mouse_opacity = 0
		icon = 'extra images/dab13.dmi'
		icon_state = "shadow"
		ex_act()
			return


client
	fps = 60

/mob/living/carbon/human/kryfrac
	species = "shark"
	species_icon = 'icons/mob/shark.dmi'
	species_color = rgb(40,40,40)
	gender = FEMALE
	tail = "shark"
	desc = "Dances to get rid of her PTSD."
	name = "Kryfrac"
	real_name = "Kryfrac"
	hair_icon_state = "hair_kleeia"
	h_style = "Kleeia"
	tail_color = rgb(40,40,40)
	r_hair = 255
	g_hair = 20
	b_hair = 147
	Life()
		..()
		//if(src.stat != 2)
			//Disco_Fever()

//We don't give furfucks any more love.