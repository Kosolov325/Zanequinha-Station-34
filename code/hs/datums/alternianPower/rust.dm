datum
	alternians
		rust
			var/_cooldown = 0
			var/cdmsg = "Necromancy is in cooldown blacko."
			verb
				beUseless()
					set name = "Kill your fucking self"
					set category = "Alternian"

					new /obj/Particle/skull(owner.loc)
					spawn(5) owner:gib()

				necromancy()
					set name = "Necromancy"
					set category = "Alternian"

					if(_cooldown < world.time)
						new /obj/Particle/skull(owner.loc)
						var/mob/living/carbon/enemy/hs/rustFollower/r = new(owner.x+rand(1,2),owner.y+rand(1,2))
						spawn(1) r.__owner = owner
						while(r.health > 0)
							_cooldown = world.time + 5
							cdmsg = "The nigra is still alive."
							usr.loc = r.loc
							sleep(tick_lag_original)
						_cooldown = world.time + rand(10,90)
					else
						usr << "[initial(cdmsg)]"