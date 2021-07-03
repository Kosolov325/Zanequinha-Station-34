var/nuke_enabled = 0
var/nuke_timer = 120
var/sinewave = 1
var/sinemult = 0.5
/*
for it not to shake, requirements must be met

Y < 100
X < 97
*/
/datum/controller/gameticker/proc/process_timer()

	if(nuke_enabled == 1)
		nuke_timer -= tick_lag_original //Decrement!
		if(nuke_timer < 41 && nuke_timer > 40)
			world << sound('sound/chaos dunk.ogg',channel=SOUND_CHANNEL_2)
		if(nuke_timer < 3.8 && nuke_timer > 3.7)
			world << sound('sound/oh no.ogg',channel=SOUND_CHANNEL_4)
		if(nuke_timer < 3.8)
			sinemult = sinemult * 1.01
		if(nuke_timer < 3.5 && nuke_timer > 2.5)
			world << sound('sound/ass.ogg',channel=SOUND_CHANNEL_3)
		//world << "<font color='red'>[nuke_timer]"
		if(nuke_timer < 0)
			nuke_enabled = 2
			world << sound('sound/nice.ogg',channel=SOUND_CHANNEL_2)
		if(nuke_timer < 41)
			sinemult = sinemult * -1
			sinewave = 2+sin(nuke_timer*2) //dang
			for(var/client/i in clients)
				if(i.mob.x < 194 && i.mob.y < 200)
					i.pixel_w = sinewave*sinemult
					if(i.color != "#FFDFDF")
						i.color = "#FFDFDF"
				else
					i.pixel_w = 0
					//i << sound(null,channel=768)
					if(i.color != "#FFFFFF")
						i.color = "#FFFFFF"
	if(nuke_enabled == 2)
		for(var/client/i in clients)
			i.pixel_w = 0
			if(i:mob.x < 194 && i:mob.y < 200)
				i:mob:gib()
		nuke_enabled = 3
		for(var/obj/machinery/nuclearbomb/Bomb in world)
			explosion(Bomb.loc, 30, 60, 120, 0, 0)


/datum/controller/gameticker/proc/nuke_enable()
	if(nuke_enabled == 0)
		world << sound('sound/escape1.ogg',channel=MUSIC_CHANNEL,repeat=1)
		nuke_enabled = 1
		call_shuttle_proc(src)

/datum/controller/gameticker/proc/nuke_disable()
	if(nuke_enabled == 1)
		nuke_timer = initial(nuke_timer)
		world << sound(null,channel=MUSIC_CHANNEL)
		nuke_enabled = 0
		cancel_call_proc()

proc/timer_enable()
	ticker.nuke_enable()

client/Stat()
	..()
	if(nuke_enabled == 1)
		stat("Seconds Left Till Explosion",round(nuke_timer))

/obj/screen_number
	icon = 'extra images/number_font.dmi'
	plane = 10