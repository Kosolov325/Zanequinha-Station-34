/area/forest
	icon = 'icons/turf/floors.dmi'
	icon_state = "eartharea"
	forced_lighting = 0
	atmos_simulation_required = 0
	//song = 'music/grass.ogg'
	CAN_GRIFE = 0
	name = "Forest Area"

/obj/structure/forest
	anchored = 1
	density = 1
	icon = 'icons/misc/forest.dmi'
	ex_act()
		return
	Tree1
		icon_state = "tree1"
		name = "Tree"
		pixel_x = -36
		plane = MOB_PLANE_ALT
		New()
			..()
			Get_Layer_Y(0.1)
	deco1
		icon = 'icons/turf/grasstiles.dmi'
		icon_state = "2"
		mouse_opacity = 0
		layer = TURF_LAYER
		density = 1
		New()
			..()
			icon_state = "[rand(2,7)]"