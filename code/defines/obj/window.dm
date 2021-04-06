/obj/window
	name = "window"
	icon = 'icons/obj/windows.dmi'
	plane = WINDOW_PLANE
	icon_state = "window"
	desc = "A window."
	density = 1
	var/smooth_shit = "window"
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	New()
		..()
		AutoJoin()
		spawn(1)
			for(var/obj/window/g in orange(1,src))
				if(abs(src.x-g.x)-abs(src.y-g.y)) //doesn't count diagonal walls
					g.AutoJoin()
	Del()
		..()
	proc/AutoJoin()
		var/junction = 0 //will be used to determine from which side the wall is connected to other walls
		for(var/obj/window/W in orange(src,1))
			if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
				junction |= get_dir(src,W)
		icon_state = "[smooth_shit][junction]"
		return
	proc/healthcheck()
		if(health <= 0)
			del src
	water_act(height)
		if(height > 40)
			del src
	bullet_act()
		src.health -= 4
		healthcheck()
// Reinforced

/obj/window/reinforced
	reinf = 1
	icon_state = "rwindow"
	name = "reinforced window"
	smooth_shit = "rwindow"
	health = 28

/obj/window_spawner //this is the most helpful object in mapping. use it wisely. -eric from epic games
	name = "window"
	icon = 'icons/obj/windows.dmi'
	plane = WINDOW_PLANE
	icon_state = "spawner"
	density = 1
	anchored = 1.0
	proc/Initialize_Window()
		new /obj/grille(locate(x,y,z))
		new /obj/window/reinforced(locate(x,y,z))
		del src