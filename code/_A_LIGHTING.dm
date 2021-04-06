/*
lighting based off forum_account's library.
except i got tired of tile by tile so instead we use a obj with special blend modes, see RGBlights.dmi and spotlight.dmi
*/

atom
	var
		obj/light/light


Lighting
	var
		// the list of all light sources
		list/lights = list()
	New()
		spawn(1)
			loop()

	proc
		loop()
			for(var/obj/light/l in lights)
				l.loop()
		init()
			for(var/z in 1 to world.maxz)
				// to intialize a z level, we create a /shading object
				// on every turf of that level
				for(var/x = 1 to world.maxx)
					for(var/y = 1 to world.maxy)
						var/turf/t = locate(x, y, z)
						var/area/a = t.loc
						if(a)
							//if(a.storm)
								//t.init_storm(1)
							//else
							if(a.forced_lighting == 1)
								if(a.sd_lighting == 1)
									// create the shading object for this tile
									t.init_light(1)
								else
									if(!istype(t,/turf/space))
										// create the shading object for this tile
										t.init_light(1)
									else
										t.init_space(1)

/turf/space/New()
	alpha = 0
	init_space()

/obj/screen_alt/plane_master_turf3
	plane = SHADING_PLANE
	screen_loc = "1,1"
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER | PLANE_MASTER
	blend_mode = BLEND_MULTIPLY

turf
	proc
		del_lights()
			if(lighting_inited)
				for(var/obj/shading/g in src)
					del g
		init_light(force = 0)
			if(lighting_inited || force)
				del_lights()
				create_shading()
		init_space(force = 0)
			if(lighting_inited || force)
				del_lights()
				create_space()
		create_shading()
			if(!shading)
				shading = new(locate(x,y,z))
		create_space()
			if(!shading)
				shading = new(locate(x,y,z))
				shading.icon_state = "noAlpha"
				layer = LIGHT_LAYER

turf
	var
		obj/shading/shading

obj/shading
	mouse_opacity = 0
	anchored = 1
	plane = SHADING_PLANE
	layer = LIGHT_LAYER
	icon_state = "black"
	icon = 'extra images/RGBlights.dmi'
	ex_act()
		return 0


obj/light
	anchored = 1
	plane = SHADING_PLANE
	blend_mode = BLEND_ADD
	appearance_flags = RESET_COLOR | LONG_GLIDE
	icon = 'extra images/spotlight.dmi'
	//icon_state = "light"
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

	layer = LIGHT_LAYER + 1
	Move()
		//Do Nothing
	ex_act()
		return
	var
		// the atom the light source is attached to
		atom/ownerF

		// the radius, intensity, and ambient value control how large of
		// an area the light illuminates and how brightly it's illuminated.
		radius = 0
		intensity = 1

		// whether the light is turned on or off.
		on = 1

		// this flag is set when a property of the light source (ex: radius)
		// has changed, this will trigger an update of its effect.
		changed = 1

		// this is used to determine if the light is attached to a mobile
		// atom or a stationary one.
		mobile = 0

	New(atom/a, radius = 3, intensity = 1)
		if(!a || !istype(a))
			CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[a]' instead.")

		ownerF = a

		if(istype(ownerF, /atom/movable))
			loc = ownerF.loc
			mobile = 1
		else
			loc = ownerF
			mobile = 0

		src.radius = radius
		src.intensity = intensity

		x = a.x
		y = a.y

		// the lighting object maintains a list of all light sources
		lighting.lights += src

	proc
		// this used to be called be an infinite loop that was local to
		// the light object, but now there is a single infinite loop in
		// the global lighting object that calls this proc.
		loop()
			// if the light is mobile (if it was attached to an atom of
			// type /atom/movable), check to see if the owner has moved
			if(mobile && ownerF)
				if(x != ownerF.x || y != ownerF.y || pixel_x != ownerF.pixel_x+ownerF.pixel_w-32 || pixel_y != ownerF.pixel_y+ownerF.pixel_z-32)
					glide_size = ownerF:glide_size
					x = ownerF.x
					y = ownerF.y
					pixel_x = ownerF.pixel_x+ownerF.pixel_w-32
					pixel_y = ownerF.pixel_y+ownerF.pixel_z-32
			if(changed)
				//world << "<font color='yellow'>received light change"
				var/matrix/M = matrix()
				M.Scale((max(0,radius)*on)*0.75)
				animate(src,alpha=round(255*intensity),transform = M,time = 5)
				changed = 0


		// turn the light source on
		on()
			if(on)
				return

			on = 1
			changed = 1

		// turn the light source off
		off()
			if(!on)
				return

			on = 0
			changed = 1

		// toggle the light source's on/off status
		toggle()
			if(on)
				off()
			else
				on()

		radius(r)
			if(radius == r)
				return

			radius = r
			changed = 1

		intensity(i)
			if(intensity == i)
				return

			intensity = i
			changed = 1


/*

light source.dm

*/

area
	var
		sd_lighting = 0
		forced_lighting = 1

atom
	var
		sd_lumcount = 0
	Del()
		if(light)
			del light
		..()
	proc
		sd_SetLuminosity(var/amount)
			if(lighting_inited == 0)
				return
			//world << "<font color='yellow'>Received light call to [amount] (FROM [src])"
			if(!light)
				//world << "<font color='yellow'>Creating new light."
				light = new(src, round(amount),0.5)
			else
				light.radius(round(amount))
				light.intensity(0.5)

		sd_SetOpacity(var/newOpacity)
			opacity = newOpacity
		sd_NewOpacity(var/newOpacity)
			opacity = newOpacity


/area/black_space
	icon = 'icons/mob/idk.dmi'
	icon_state = "area"
	forced_lighting = 0
	CAN_GRIFE = 0

/area/New()

	src.icon = 'icons/effects/alert.dmi'
	spawn(1)
	//world.log << "New: [src] [tag]"

		master = src
		related = list(src)

		src.icon = 'icons/effects/alert.dmi'
		src.layer = 10

		if(name == "Space")			// override defaults for space
			requires_power = 0

		if(!requires_power)
			power_light = 1
			power_equip = 1
			power_environ = 1
			luminosity = 1
			if(indestructible_by_explosions == 1)
				sd_lighting = 1
			else
				sd_lighting = 0			// *DAL*
		else
			sd_lighting = 1
			luminosity = 1
	spawn(15)
		src.power_change()		// all machines set to current power level, also updates lighting icon
