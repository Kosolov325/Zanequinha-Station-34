/obj/machinery/hydroponics
	icon = 'icons/obj/hydroponics.dmi'
	anchored = 1 //wow lol
	tray
		var/planted_crop = null
		icon_state = "hydrotray"
		pixel_y = 4
		density = 1
		var
			grow_state = 0 //0 to 6
			grow_state_old = -1
		New()
			..()
			special_processing += src
		Del()
			special_processing -= src
			..()
		attack_hand(mob/user as mob)
			attackby(null,user)
		attackby(var/obj/D, mob/user as mob)
			if(istype(D,/obj/item/weapon/reagent_containers/food/snacks/hydro))
				planted_crop = D.icon_state
				user << "<b>You plant some [D.icon_state]."
				del D
			else
				if(min(7,round(grow_state)) >= 7)
					var/path = text2path("/obj/item/weapon/reagent_containers/food/snacks/hydro/[planted_crop]")
					if(path)
						user << "<b>You harvest some [planted_crop]."
						for(var/i in 1 to 7)
							new path(user.loc)
						grow_state = 0
						planted_crop = null
						Get_Overlay()
		special_process()
			if(planted_crop)
				desc = "It's a hydroponics tray. It has <b>[planted_crop]</b> planted.<br><font color='#00FF00'><b>Grow Status : %[round((min(7,grow_state)/7)*100)]</b>"
				//every crop has a grow time of 6
				var/obj/water/device/connector/D = locate(/obj/water/device/connector) in locate(x,y,z)
				if(D && frm_counter % 3 == 1)
					if(D.water_pressure > 1)
						D.water_pressure -= 1
						grow_state += tick_lag_original/40
				if(round(grow_state) != grow_state_old)
					grow_state_old = round(grow_state)
					Get_Overlay()
			else
				grow_state = 0
				grow_state_old = -1

		proc/Get_Overlay()
			overlays = null
			if(planted_crop)
				src.overlays += image("icon" = 'icons/obj/hydroponics.dmi', "icon_state" = "[planted_crop][min(7,round(grow_state))]")

/obj/item/weapon/reagent_containers/food/snacks/hydro
	name = "hydro food"
	desc = "developers developers developers developers"
	icon_state = "tomato"
	icon = 'icons/obj/hydroponics.dmi'
	amount = 5
	heal_amt = 2
	tomatoes
		icon_state = "tomatoes"
		desc = "Tomatoes."
		name = "Tomatoes"
		amount = 2
		heal_amt = 1