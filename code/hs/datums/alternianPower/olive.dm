datum
	alternians
		olive
			var/mob/target
			var/smokeCooldown = 0
			var/nearest_dist = 30
			var/jumpCooldown = 0
			var/_cooldown = 0
			verb/highJump()
				set name = "High Jump"
				set category = "Alternian"
				if(jumpCooldown < world.time)
					catJump(8)
					jumpCooldown = world.time + 13
			verb/jumpAttack()
				set name = "Jump Attack!"
				set category = "Alternian"
				for(var/mob/i in Mobs)
					if(i != usr && !target && i.health >= 0)
						var/dist = GetDist(usr,i)
						if(get_dist(i,usr) <= 1)
							target = i
						else if(dist < nearest_dist && !target)
							target = i
						else
							continue
				if(target && _cooldown < world.time && get_dist(target,usr) <= nearest_dist + 1 && target.health >= 0)
					new /obj/Particle/leo(usr.loc)
					new /obj/Particle/crosshair(target.loc)
					catJump(8)
					usr.say(pick("Slash slash!","mweow :3","ass nigga"))
					for(var/mob/M in hearers())
						if(M.client)
							if(M != usr)
								M << "\red [usr.name] dashes towards [target.name]!"
					usr << "\red You dash towards [target.name]!"
					while(get_dist(target,usr) < nearest_dist && get_dist(target,usr) > 1 && !usr.stat)
						spawn(1) usr.Dash_Effect(usr.loc)
						walk_towards(usr,target,0.5,0)
						if(get_dist(target,usr) <= 1 || get_dist(target,usr) >= nearest_dist)
							break
						spawn(tick_lag_original * 50)
							break
						sleep(tick_lag_original)
					_cooldown = world.time + 90
					if(get_dist(src,target) <= 1)
						usr.density = 0
						usr.loc = target.loc
						if(usr.loc == target.loc)
							catJump(8)
							walk_towards(usr,target,0.5,0)
							spawn(3) usr.density = 1
						target:TakeBruteDamage(40)
						usr << "\red You slash [target.name]'s face!"
						for(var/mob/M in hearers())
							if(M.client)
								if(M != usr)
									M << "\red [usr.name] slashes [target.name]!"
						return
				else
					usr << "\blue You can't use this action right now!"

			verb/smokeExplosion()
				set name = "Smoke Explosion!"
				set category = "Alternian"
				if(smokeCooldown < world.time)
					new /obj/Particle/leo(usr.loc)
					var/datum/effects/system/harmless_smoke_spread/SM = new(usr.loc)
					SM.attach(usr)
					SM.set_up(10, 0, usr.loc)
					playsound(usr.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
					spawn(0)
						SM.start()
					smokeCooldown = world.time + 30
				else
					usr << "\blue Smoke Explosion is in cooldown"

			proc/catJump(ysped)
				owner.ySpeed = ysped
				owner.onFloor = 0
				//while(!owner.onFloor)
					//sleep(tick_lag_original)