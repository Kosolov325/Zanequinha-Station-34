/mob/living/carbon/enemy/hs/rustFollower
	name = "Rust Follower"
	desc = "RUN BOI"
	icon_state = "droid"
	density = 1
	maxhealth = 10
	heightSize = 32
	var/mob/living/carbon/human/__owner
	var/acting = FALSE
	var/cooldown = 0
	var/nearest_dist = 5
	var/mob/living/nearest_mob = null

	/*New(var/mob/living/carbon/human/_owner)
		. = ..()
		owner = _owner
		if(owner)
			src.loc = owner.loc
		return .*/

	ex_act()
		return

	EnemyProcess()
		if(frm_counter % 5 == 3)
			src.alpha--
		spawn(50)
			if(cooldown < world.time)
				if(!__owner)
					if(prob(70))
						step_rand(src)
				else
					if(!acting)
						findTargets()
					if(GetDist(src,__owner) > 10)
						src.loc = __owner.loc
				cooldown = world.time + 10
				if(prob(10))
					speakAss(pick("really cool kanye","FODA-SE"))
		if(src.alpha <= 0)
			new /obj/Particle/skull (src.loc)
			del src

	proc
		speakAss(ass)
			message_admins("The nigra said [ass]")
			src << text("\blue You said [].", ass)
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << text("\red [] says \"[]\".", usr,ass)

		Shoot()
			acting = TRUE
			if(nearest_mob)
				speakAss("Shooting [nearest_mob.name]")
			for(var/i in 1 to 5)
				spawn(tick_lag_original)
					var/obj/projectile/hs/spine/G = new(locate(x,y,z))
					G.owner = src
					G.X_SPEED = cos(frm_counter*30)*5
					G.Y_SPEED = sin(frm_counter*30)*5
			sleep(10)
			acting = FALSE

		findTargets()
			return
			acting = TRUE
			for(var/mob/i in Mobs)
				spawn(tick_lag_original)
					if(i != __owner && !nearest_mob && i != src/*&& i:alternian_blood_type != "Rust"*/)
						var/dist = GetDist(src,i)
						if(dist < nearest_dist)
							nearest_mob = i
							nearest_dist = dist
							break
			if(nearest_mob)
				new /obj/Particle/skull (nearest_mob.loc)
				glide_size = 32 / 0.5 * tick_lag_original
				if(prob(1))
					src.loc = nearest_mob.loc
				else
					while(GetDist(src,nearest_mob) > 1)
						spawn(1) src.Dash_Effect(src.loc)
						walk_towards(src,nearest_mob,0.5,0)
						if(GetDist(src,nearest_mob) <= 1)
							break
				if(prob(50))
					Shoot()
			if(!nearest_mob)
				nearest_mob = null
			sleep(10)
			acting = FALSE