/datum/sun
	var/angle
	var/dx
	var/dy


// calculate the sun's position given the time of day

/datum/sun/proc/calc_position()

	var/Time = world.timeofday
	//world << "Current day time = [Time] seconds. [Time/600] minutes. [Time/36000] hours."

	angle = (Time/864000)*360 //Gives us about a day rotation.
	//world << "That would set the angle to [angle]"


	var/s = sin(angle)
	var/c = cos(angle)

	if(c == 0)

		dx = 0
		dy = s

	else if( abs(s) < abs(c))

		dx = s / abs(c)
		dy = c / abs(c)

	else
		dx = s/abs(s)
		dy = c / abs(s)


	for(var/obj/machinery/power/tracker/T in machines)
		T.set_angle(angle)


//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2angle(var/D)
	switch(D)
		if(1)
			return 0
		if(2)
			return 180
		if(4)
			return 90
		if(8)
			return 270
		if(5)
			return 45
		if(6)
			return 135
		if(9)
			return 315
		if(10)
			return 225
		else
			return null

