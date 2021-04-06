#define MAX_PLEASURE 100

mob/var
	partner
	potenzia
	pleasure
	tired = 0
	penisSize = 0

mob/New()
	..()
	if(src.gender == "Male")
		penisSize = rand(5,40)

/obj/cleanable/cum
	name = "Semen"
	desc = "Cream pie ......... delicious"
	icon = 'code/hs/mob/interactions/interact.dmi'
	icon_state = "cum1"

	New()
		..()
		icon_state = pick("cum1","cum2","cum3","cum4","cum5","cum6","cum7","cum8","cum9","cum10","cum11","cum12")

	Click()
		set src in oview(1)
		view() << "<font color=blue>[usr] cleans up the [src.name]</font>"
		del(src)

/mob/living/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(M == src || src == usr || M != usr)		return

	var/mob/living/H = usr
	H.partner = src
	usr << 	browse(null,"fuck")
	fug()

mob/proc/fuck()
	if(usr.tired == 0 && usr.gender == "male")
		usr.dir = get_dir(usr,usr.partner)
		var/p = usr.partner
		view() << "<font color=purple><b>[usr]</b> Bangs <b>[usr.partner]</b>'s ass</font>"
		usr.do_fucking_animation(p)
		usr.pleasure += 10
		if(usr.penisSize >= 30)
			view() << "<font color=red><b>[usr] SCREAMS!</b></font>"
			view() << "<font color=purple><b>[usr]</b> Pounds <b>[usr.partner]</b>'s ass</font>"
			if(istype(src,/mob/living/))
				var/mob/living/w = p
				w.TakeBruteDamage(usr.penisSize)
	else
		usr << "<font color=blue>You are too tired to do that.</font>"
	if(usr.pleasure >= 100)
		discord_relay("**[usr] gozou em [usr.partner] :sweat_drops: **")
		view() << "<big><font color=purple><b>[usr]</b> Cums!</font></big>"
		usr.pleasure = 0
		var/obj/cleanable/cum/C = new(usr.loc)
		C.name = "Semen"
		sleep(500)
		usr.tired = 0

mob/proc/fug()
	var/erpHTML ={"
	<Title> ERP </Title>
	<Body style="background-color: #dfdfdf;">
	<p>Select an action</p>
	<a href='?src=\ref[src];action=sex' class="aButton">
	Anal (10 . 15)
	</a>
	</Body>
	"}
	usr<<browse(erpHTML,"window=sex")

mob/Topic(href,href_list[])
	switch(href_list["action"])
		if("startgame")
			usr << "Starting game..."
		if("sex")
			usr.fuck()


/mob/proc/do_fucking_animation(mob/living/P)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)

	var/direction = get_dir(src, P)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	if(pixel_x_diff == 0 && pixel_y_diff == 0)
		pixel_x_diff = rand(-3,3)
		pixel_y_diff = rand(-3,3)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
		animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)
		return

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)
