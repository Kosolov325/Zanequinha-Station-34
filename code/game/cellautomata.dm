/world/proc/load_motd()
	discord_link = file2text("config/discord.txt")
	join_motd = file2text("config/motd.txt")

var/list/gamemodes_list=list()

/world/proc/load_configuration()
	config = new /datum/configuration()

/world/New()
	src.load_configuration()
	gamemodes_list = typesof(/datum/game_mode)-/datum/game_mode

	if (config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	src.load_motd()

	makepowernets()

	sun = new /datum/sun()

	radio_controller = new /datum/controller/radio()
	//main_hud1 = new /obj/hud()
	data_core = new /obj/datacore()

	..()

	sleep(1) //Make this a 1

	plmaster = new /obj/overlay(  )
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = 20
	plmaster.mouse_opacity = 0

	slmaster = new /obj/overlay(  )
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = 20
	slmaster.mouse_opacity = 0


	master_controller = new /datum/controller/game_controller()
	spawn()
		master_controller.setup()
	return

//Crispy fullban
/world/Reboot(var/reason)
	spawn(0)
		if(prob(40))
			for(var/mob/M in world)
				if(M.client)
					M << sound('sound/misc/NewRound2.ogg')
		else
			for(var/mob/M in world)
				if(M.client)
					M << sound('sound/misc/NewRound.ogg')

	..()

/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai))
		return 1
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	spawn( 0 )
		if ((A && yes))
			A.last_bumped = world.timeofday
			A.Bumped(src)
		return
	..()
	return

// **** Note in 40.93.4, split into obj/mob/turf point verbs, no area

/atom/verb/point()
	set src in oview()

	if (!usr || !isturf(usr.loc))
		return
	else if (usr.stat != 0 || usr.restrained())
		return

	var/tile = get_turf(src)
	if (!tile)
		return

	var/P = new /obj/decal/point(tile)
	spawn (20)
		del(P)

	usr.visible_message("<b>[usr]</b> points to [src]")

/obj/decal/point/point()
	set src in oview()
	set hidden = 1
	return