/turf
	icon = 'icons/turf/floors.dmi'
	var/intact = 1

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1

/turf/space
	icon = 'icons/turf/space.dmi'
	name = "space"
	icon_state = "placeholder"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	plane = -99

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.001
	temperature = TCMB


/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000
	var/broken = 0
	var/burnt = 0

	airless
		name = "airless floor"
		oxygen = 0.01
		nitrogen = 0.01
		temperature = TCMB

		New()
			..()
			name = "floor"

/turf/simulated/floor/plating
	name = "plating"
	icon_state = "plating"
	intact = 0

/turf/simulated/floor/plating/airless
	name = "airless plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

	New()
		..()
		name = "plating"

/turf/simulated/floor/grid
	icon = 'icons/turf/floors.dmi'
	icon_state = "circuit"

/turf/simulated/wall/r_wall
	name = "reinforced wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rwall0"
	opacity = 1
	density = 1
	var/d_state = 0


/turf/simulated/wall
	icon_state = "metal0"
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	opacity = 1
	density = 1
	plane = WALL_PLANE
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall


/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "swall0"
	opacity = 1
	density = 1
	blocks_air = 1
	plane = WALL_PLANE
	var/smooth_shit = "swall"

/turf/simulated/shuttle/wall/New()
	..()
	AutoJoin()
	spawn(2)
		for(var/turf/simulated/shuttle/wall/g in range(1,src))
			if(abs(src.x-g.x)-abs(src.y-g.y)) //doesn't count diagonal walls
				if(g.type == type)
					g.AutoJoin()

/turf/simulated/shuttle/wall/proc/AutoJoin()

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/shuttle/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			if(W.type == type)
				junction |= get_dir(src,W)

	icon_state = "[smooth_shit][junction]"
	return

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/unsimulated
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	plane = WALL_PLANE

/turf/unsimulated/black
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "black"
	density = 1
	opacity = 1

/turf/unsimulated/title
	name = "title screen"
	icon = 'extra images/title.png'
/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()
		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L
	Distance(turf/t)
		if(get_dist(src,t) == 1)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return get_dist(src,t)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L
