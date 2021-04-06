/obj/stool
	var/pixel_x_off = 0
	var/pixel_y_off = 0


/obj/stool/chair/vehicle
	icon = 'icons/mob/vehicles.dmi'
	icon_state = "pussywagon"
	glide_size = 0.66
	var/lastdelay = 0
	glide_size = 16
	pixel_x_off = 12
	pixel_y_off = 6

	relaymove(var/mob/user, direction) //This relays a move.
		if(world.time < lastdelay)
			return
		step(src,direction)
		user.loc = loc
		lastdelay = world.time + 1