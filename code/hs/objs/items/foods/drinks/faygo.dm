/obj/item/weapon/reagent_containers/food/drinks/faygo
	name = "faygo"
	desc = "Honk?!!!"
	icon = 'icons/obj/faygo.dmi'
	icon_state = "faygo"
	heal_amt = 1
	New()
		var/datum/reagents/R = new/datum/reagents(50)
		reagents = R
		R.my_atom = src
		R.add_reagent(/datum/reagent/faygo, 30)