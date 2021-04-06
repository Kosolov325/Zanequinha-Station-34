/mob/Login()
	log_access("Login: [key_name(src)] from [src.client.address ? src.client.address : "localhost"]")
	src.lastKnownIP = src.client.address
	src.computer_id = src.client.computer_id

	if(!src.dna) src.dna = new /datum/dna(null)
	//src.client.screen -= main_hud1.contents

	world.update_status()
	//if (!src.hud_used)
	//	src.hud_used = main_hud1

	if (!src.hud_used)
		var/obj/hud/h = new
		h.mymob = src
		src.hud_used = h
		h.instantiate()
	else
		del(src.hud_used)
		var/obj/hud/h = new
		h.mymob = src
		src.hud_used = h
		h.instantiate()

	if (client)
		if(veh)
			client.perspective = EYE_PERSPECTIVE
			client.eye = veh
			client.pixel_y1 = 0
			client.pixel_y2 = 0
			client.pixel_y3 = 0
			client.pixel_y4 = 0

			client.pixel_x = 0
			client.pixel_z = 0
			client.pixel_w = 0
		else
			client.eye = client.mob
			client.perspective = MOB_PERSPECTIVE
			client.pixel_y1 = 0
			client.pixel_y2 = 0
			client.pixel_y3 = 0
			client.pixel_y4 = 0

			client.pixel_x = 0
			client.pixel_z = 0
			client.pixel_w = 0
	src.next_move = 1
	src.logged_in = 1

	..()
