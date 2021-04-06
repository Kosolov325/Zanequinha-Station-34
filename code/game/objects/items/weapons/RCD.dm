/*
CONTAINS:
RCD

*/
/obj/item/weapon/rcd/New()
	desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
	src.spark_system = new /datum/effects/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/rcd/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/rcd_ammo))
		if ((matter + 10) > max_matter)
			user << "The RCD cant hold any more matter."
			return
		del(W)
		matter += 10
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		user << "The RCD now holds [matter]/[max_matter] matter-units."
		desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
		return

/obj/item/weapon/rcd/attack_self(mob/user as mob)
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	if (mode == 1)
		mode = 2
		user << "Changed mode to 'Airlock'"
		src.spark_system.start()
		return
	if (mode == 2)
		mode = 3
		user << "Changed mode to 'Deconstruct'"
		src.spark_system.start()
		return
	if (mode == 3)
		mode = 1
		user << "Changed mode to 'Floor & Walls'"
		src.spark_system.start()
		return
	// Change mode

/obj/item/weapon/rcd/afterattack(atom/A, mob/user as mob)
	if (!(istype(A, /turf) || istype(A, /obj/machinery/door/airlock)))
		return

	if (istype(A, /turf) && mode == 1)
		if (istype(A, /turf/space) && matter >= 1)
			user << "Building Floor (1)..."
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			spark_system.set_up(5, 0, src)
			src.spark_system.start()
			ReplaceWithFloor(A)
			matter--
			user << "The RCD now holds [matter]/[max_matter] matter-units."
			desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
		if (istype(A, /turf/simulated/floor) && matter >= 3)
			user << "Building Wall (3)..."
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, rcd_delay))
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				ReplaceTurfWithWall(A)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				matter -= 3
				user << "The RCD now holds [matter]/[max_matter] matter-units."
				desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
	else if (istype(A, /turf/simulated/floor) && mode == 2 && matter >= 10)
		user << "Building Airlock (10)..."
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, rcd_delay))
			spark_system.set_up(5, 0, src)
			src.spark_system.start()
			var/obj/machinery/door/airlock/T = new /obj/machinery/door/airlock( A )
			matter -= 10
			T.autoclose = 1
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			user << "The RCD now holds [matter]/[max_matter] matter-units."
			desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			playsound(src, 'sound/effects/sparks2.ogg', 50, 1)
		return
	else if (mode == 3 && (istype(A, /turf) || istype(A, /obj/machinery/door/airlock) ) )
		if (istype(A, /turf/simulated/wall) && matter >= 5)
			user << "Deconstructing Wall (5)..."
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, rcd_delay))
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				matter -= 5
				ReplaceWithFloor(A)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "The RCD now holds [matter]/[max_matter] matter-units."
				desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
		if (istype(A, /turf/simulated/wall/r_wall) && matter >= 5)
			user << "Deconstructing RWall (5)..."
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, rcd_delay))
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				matter -= 5
				ReplaceTurfWithWall(A)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "The RCD now holds [matter]/[max_matter] matter-units."
				desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
		if (istype(A, /turf/simulated/floor) && matter >= 5)
			user << "Deconstructing Floor (5)..."
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, rcd_delay))
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				matter -= 5
				ReplaceTurfWithSpace(A)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "The RCD now holds [matter]/[max_matter] matter-units."
				desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
		if (istype(A, /obj/machinery/door/airlock) && matter >= 10)
			user << "Deconstructing Airlock (10)..."
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			if(do_after(user, rcd_delay))
				spark_system.set_up(5, 0, src)
				src.spark_system.start()
				matter -= 10
				del(A)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "The RCD now holds [matter]/[max_matter] matter-units."
				desc = "A RCD. It currently holds [matter]/[max_matter] matter-units."
			return
