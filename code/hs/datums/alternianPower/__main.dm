datum
	alternians
		parent_type = /obj

		var/mob/owner

		var/cooldown = 0
		var/allowActions = 0

		New(_owner)
			owner = _owner

		proc/Cooldown()
			if(cooldown > world.time)
				owner << "\blue This action is in cooldown!"
			while(cooldown > world.time)  //Se o cooldown for maior que o tempo atual
				sleep(1) //Esperar o tempo atual superar o cooldown
			allowActions = 0   //Flag