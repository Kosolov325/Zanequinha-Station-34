/turf/unsimulated/snow
	icon = 'icons/turf/floors.dmi'
	name = "snow"
	icon_state = "snow"
	sand
		icon = 'extra images/water2.dmi'
		icon_state = "snad"

/turf/unsimulated/grass
	icon = 'icons/turf/grasstiles.dmi'
	name = "grass"
	icon_state = "1"
	TurfCeiling = 0

/turf/simulated/grass
	icon = 'icons/turf/grasstiles.dmi'
	name = "grass"
	icon_state = "1"
	TurfCeiling = 0

/turf/unsimulated/dirt
	icon = 'icons/turf/grasstiles.dmi'
	name = "dirt"
	icon_state = "dirt"

/obj/greenland
	density = 1
	layer = MOB_LAYER + 1
	anchored = 1
	icon = 'icons/turf/greenland.dmi'
	ex_act()
		return
	Move()
		return
	snowy_tree
		pixel_x = -23
		icon_state = "tree"
/area/greenland
	icon = 'icons/turf/floors.dmi'
	icon_state = "snowarea"
	forced_lighting = 0
	ambi = 0
	CAN_GRIFE = 0 //this is not even funny ikea stop torturing me