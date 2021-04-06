datum
	alternians
		telephaty
			verb/teleTalk(mob/m as mob in oview(30,usr))
				set name = "Tele Talk"
				set category = "Alternian"
				var/msg = input("Tele Talk(tm) [m]")as null|text //if this doesn't work...
				if(msg)
					usr << "You said \"[msg]\" telephatically to [m]"
					m << "[usr] talks through your mind: [msg]"