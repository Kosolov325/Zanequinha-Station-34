/proc/start_events()
	if (!event && prob(eventchance))
		event()
		hadevent = 1
		spawn(1300)
			event = 0
	spawn(1200)
		start_events()

/proc/event()
	switch(rand(1,3))

		if(1)
			event = 1
			command_alert("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert")
			var/list/turfs = list(	)
			var/turf/picked
			for(var/turf/T in world)
				if(T.z == 1 && istype(T,/turf/simulated/floor) && !istype(T,/turf/space))
					turfs += T
			for(var/turf/T in world)
				if(prob(20) && T.z == 1 && istype(T,/turf/simulated/floor))
					spawn(50+rand(0,3000))
						picked = pick(turfs)
						var/obj/portal/P = new /obj/portal( T )
						P.target = picked
						P.creator = null
						P.icon = 'icons/obj/objects.dmi'
						P.failchance = 0
						P.icon_state = "anom"
						P.name = "wormhole"
						spawn(rand(300,600))
							del(P)

		if(2)
			event = 1
			command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
			for(var/mob/living/carbon/human/H in world)
				H.radiation += rand(5,25)
				if (prob(5))
					H.radiation += rand(30,50)
				if (prob(25))
					if (prob(75))
						randmutb(H)
						domutcheck(H,null,1)
					else
						randmutg(H)
						domutcheck(H,null,1)
		if(3)
			event = 1
			viral_outbreak()

/proc/power_failure()
	command_alert("Abnormal activity detected in [Station_Name]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = 0
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 0
			A.power_equip = 0
			A.power_environ = 0
			A.power_change()

/proc/power_restore()
	command_alert("Power has been restored to [Station_Name]. We apologize for the inconvenience.", "Power Systems Nominal")
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()

/proc/viral_outbreak()
	command_alert("Confirmed outbreak of level 7 viral biohazard aboard [Station_Name]. All personnel must contain the outbreak.", "Biohazard Alert")
	var/virus_type = pick(/datum/disease/dnaspread,/datum/disease/cold)
	for(var/mob/living/carbon/human/H in world)
		if((H.virus) || (H.stat == 2))
			continue
		if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
			if((!H.dna) || (H.sdisabilities & 1)) //A blindness disease would be the worst.
				continue
			var/datum/disease/dnaspread/D = new
			D.strain_data["name"] = H.real_name
			D.strain_data["UI"] = H.dna.uni_identity
			D.strain_data["SE"] = H.dna.struc_enzymes
			D.carrier = 1
			D.affected_mob = H
			H.virus = D
			break
		else
			H.virus = new virus_type
			H.virus.affected_mob = H
			H.virus.carrier = 1
			break