/obj/machinery/power/core
	name = "Core power generator."
	desc = "A core-powered generator. It could overheat. Thus blowing up."
	icon = 'icons/obj/power.dmi'
	icon_state = "core"
	anchored = 1
	density = 1
	directwired = 1
	var/temp = 0
	var/melt_down_alert = 0
	layer = 3
	var/list/particles = list()
	New()
		..()
		if(type == /obj/machinery/power/core)
			var/rnd = rand(0,90)
			for(var/i in 1 to 4)
				var/obj/Particle/Core_Particle/P = new()
				P.loc = locate(x,y,z)
				P.owner = src
				P.timer = rnd+i*45
				particles += P
		special_processing += src
	Del()
		special_processing -= src
		for(var/obj/Particle/G in particles)
			del G
		..()

/obj/machinery/power/core/special_process()
	temp = temp + tick_lag_original/4
	if(temp < 0)
		temp = 0
	if(temp > 3500 && melt_down_alert == 0)
		for(var/mob/living/carbon/human/M in Mobs)
			if(istype(M.ears,/obj/item/device/radio/headset))
				M << "<font color='red'><b>Alert! Core temperature is higher than 3500 C*, meltdown possible."
		melt_down_alert = 1
	if(temp < 3500 && melt_down_alert == 1)
		melt_down_alert = 0
	if(temp > 5000)
		explosion(locate(x,y,z), 11, 15, 20, 30,1) //deadly ass explosion, it's your fault it blew up
		del(src)
		return

	if(stat & BROKEN)
		return

	var/sgen = 4000+(temp*2)
	add_avail(sgen)

/obj/machinery/power/core/examine()
	set src in view()
	if(temp < 0)
		temp = 0
	usr << "This is a core power generator, it's temperature seems to display : [temp] C*"

/obj/machinery/power/core/coolant
	name = "Coolant tank"
	desc = "Looks like it's used to cool the core. Click on it to toggle it!"
	icon = 'icons/obj/power.dmi'
	icon_state = "core_cooler9"
	var/coolant_left = 999999
	var/max_coolant = 3000
	var/on = 1

/obj/machinery/power/core/coolant/attack_hand(mob/user as mob)
	on = !on
	user << "You flip the coolant's switch to <b>[on ? "<font color='green'>ON</font>" : "<font color='red'>OFF (Recharge)</font>"]</b>!"

/obj/machinery/power/core/coolant/special_process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)
	if(coolant_left > max_coolant)
		coolant_left = max_coolant //cap
	icon_state = "core_cooler[round((coolant_left/max_coolant)*18)]"
	if(coolant_left > 0 && on)
		for(var/obj/machinery/power/core/e in orange(1,src))
			e.temp -= tick_lag_original/2
			coolant_left -= tick_lag_original/2
	if(!on)
		var/obj/water/device/connector/D = locate(/obj/water/device/connector) in locate(x,y,z)
		if(D)
			if(D.water_pressure > 1)
				coolant_left += 1 //now epic
				D.water_pressure -= 1
	if(coolant_left < 0)
		coolant_left = 0

/obj/machinery/power/core/coolant/examine()
	set src in view()
	usr << "This is a coolant tank, the amount left is : [coolant_left]/[max_coolant]"
