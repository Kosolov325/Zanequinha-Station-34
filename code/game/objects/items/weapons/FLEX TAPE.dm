
/turf/simulated/floor/flex_tape
	icon = 'icons/obj/flex_tape.dmi'
	density = 0
	opacity = 0
	icon_state = "floor"

/obj/item/weapon/flex_tape
	name = "Flex Tape"
	icon = 'icons/obj/flex_tape.dmi'
	desc = "It can seal anything!"
	icon_state = "tape"
	var/uses = 5
	afterattack(atom/A, mob/user as mob)
		if (!A.density && istype(A,/turf))
			uses -= 1
			if(uses > 0)
				user << "The flex tape has [uses] left."
				new /turf/simulated/floor/flex_tape(locate(A.x,A.y,A.z))
			else
				del src