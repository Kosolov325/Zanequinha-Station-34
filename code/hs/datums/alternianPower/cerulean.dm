datum
	alternians
		cerulean
			var/list/a = list()

			verb/getRandomThing()
				set name = "Spawn Random Thing"
				set category = "Alternian"
				var/_cooldown = 0

				if(_cooldown > world.time)
					usr << "\blue This actions is in cooldown b8tch!"
					return


				for(var/obj/item/i in typesof(/obj/item/))
					a += i
				var/obj/item/b = pick(a)
				new b.type (usr.loc)

				new /obj/Particle/luck(usr.loc)

				_cooldown = world.time + 50