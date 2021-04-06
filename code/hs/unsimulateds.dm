/turf/lobby
	density = 1
	icon = 'zanequinha_lobby.dmi'
	icon_state = "lobby"
	layer = 100000000

/turf/unsimulated/wall
	var/smooth_shit = "none"
	var/joinflag = 0
	var/joinable = 0
	metal
		joinable = 1
		icon_state = "metal0"
		smooth_shit = "metal"
	r_wall
		icon_state = "rwall0"
		smooth_shit = "rwall"
		joinable = 1

/turf/unsimulated/wall/New()
	..()
	if(src.joinable) AutoJoin()
	spawn(1)
		for(var/turf/unsimulated/wall/g in range(1,src))
			if(abs(src.x-g.x)-abs(src.y-g.y)) //doesn't count diagonal walls
				if(g.joinable)
					g.AutoJoin()

/turf/unsimulated/wall/proc/AutoJoin()

	var/junction = 0 //will be used to determine from which side the wall is connected to other walls

	for(var/turf/simulated/wall/W in orange(src,1))
		if(abs(src.x-W.x)-abs(src.y-W.y)) //doesn't count diagonal walls
			junction |= get_dir(src,W)

	icon_state = "[smooth_shit][junction]"
	return