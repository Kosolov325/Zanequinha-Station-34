/*
this is _A_MASTER
the ultimate master controller except it sucks

there's no limitation on this.

Functions :
CHECK_TICK() - Do actions, but give the game a moment if we have done too much. So the CPU doesnt have a stroke, Use before procs, Works really weird. I think it could be done better.
CHECK_TICK_ATMOS() (only use in atmospherics code) - Do actions, but give the game a moment if we have done way too much.
*/

var/global/datum/controller/game_controller/master_controller //Set in world.New()
var/lighting_inited = 0
var/frm_counter = 0
var/listofitems = ""
var/listofitems2 = "" //admin list
var/list/clients = list()

var/list/water_objects = list() //_A_WATER.dm
var/list/water_changed = list()

var/special_processing = list()

#define CPU_WARN 55 //How much CPU should trigger the warning that it's going too high?
#define CPU_STABLE_LEVEL 25 //What CPU does dab13 normally run on?
#define CPU_CHECK_MAX 40 //if cpu goes higher than this, some things will do sleep(tick_lag_original) and throttle.
#define ATMOS_CPU_FORCE_SLEEP 70 //Force atmos/water to sleep (and throttle) if CPU goes higher than this value to stabilize the CPU.

client
	New()
		..()
		clients += src
	Del()
		clients -= src
		if(src in admin_clients)
			admin_clients -= src
		..()


var/plrs = 1

obj
	proc/special_process() //special_processing
		return

var/list/rand_spawns = list()

var/actions_per_tick = 0
var/max_actions = 40 //Max actions per tick, Really fast. of course this can be loewr!!!!!!!!!!!

var/CPU_warning = 0

var/actions_per_tick_atmos = 0
var/max_actions_atmos = 50 //Max actions per tick (FOR ATMOS), also fast. i definitely think this could be higher if optimized.

var/actions_per_tick_water = 0
var/max_actions_water = 120 //Max actions per tick (FOR WATER), also fast.

var/list/typepaths = list()

var/master_Processed = 0
var/atmos_processed = 0
var/water_processed = 0
var/water_cycles = 0 //how

proc/CHECK_WHILE_TICK()
	if(world.tick_usage > 60)
		sleep(world.tick_lag)

proc/CHECK_TICK_WATER() //epic optimizer used for our water system.
	actions_per_tick_water += 1
	water_processed += 1
	if(actions_per_tick_water > max_actions_water - ((max(0,min(world.cpu,50))/50)*(max_actions_water/1.5)) || world.cpu > ATMOS_CPU_FORCE_SLEEP)
		sleep(tick_lag_original)
		actions_per_tick_water = 0

proc/CHECK_TICK_ATMOS() //epic optimizer (ATMOS EDITION)
	actions_per_tick_atmos += 1
	atmos_processed += 1
	if(actions_per_tick_atmos > max_actions_atmos || world.cpu > ATMOS_CPU_FORCE_SLEEP)
		sleep(tick_lag_original)
		actions_per_tick_atmos = 0

proc/CHECK_TICK() //epic optimizer
	master_Processed += 1
	actions_per_tick += 1
	if(actions_per_tick > max_actions - ((max(0,min(world.cpu,100))/100)*(max_actions/2)*(CPU_warning)))
		sleep(tick_lag_original)
		actions_per_tick = 0

datum/controller/game_controller
	var/processing = 1
	var/wait = 0.5
	var/SLOW_PROCESS_TIME = 10
	var/process_objects_done = 0
	var/T = 0
	proc
		setup()
		setup_objects()
		process()
		fast_process()
		slow_process()
		start_processing()
		water_process()
		CPU_CHECK()
			if(frm_counter > 200 && frm_counter % 10 == 1)
				/*if(world.cpu > 600) //we are missing alot of stuff already
					if(!(world.port in PORTS_NOT_ALLOWED))
						spawn()
							call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"**Game server has rebooted due to high processor usage, (%[world.cpu])**\" } ", "Content-Type: application/json")
					world << "<font color='red'><b><font size=5>Due to extreme lag (world CPU was %[world.cpu]), server is stopping and rebooting to prevent a crash."
					world.Reboot()
					return*/
				if(world.cpu > CPU_WARN && CPU_warning == 0)
					if(!(world.port in PORTS_NOT_ALLOWED))
						spawn()
							call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"**Game server is having high stress, CPU too high (%[world.cpu] > [CPU_WARN]), will attempt to throttle actions.**\" } ", "Content-Type: application/json")
					world << "<font color='red'><b><font size=5>Server CPU is (%[world.cpu] > [CPU_WARN]), Will attempt to throttle MC to lower CPU."
					CPU_warning = 1
	setup() //this takes way too long
		if(master_controller && (master_controller != src))
			del(src)

		if(!air_master)
			air_master = new /datum/controller/air_system()
			air_master.setup()
		if(!water_master)
			water_master = new /datum/controller/water_system()

		setup_objects()

		setupgenetics()

		var/RLstart_time = world.timeofday
		var/start_time = world.timeofday

		world << "\red \b Initializing lighting"
		lighting.init()
		lighting_inited = 1
		for(var/obj/machinery/light/l in world)
			l.update()
		world << "\green \b Initialized lighting system in [world.timeofday-start_time/10] seconds!"

		emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()

		if(!ticker)
			ticker = new /datum/controller/gameticker()

		spawn
			ticker.pregame()
		start_time = world.timeofday
		world << "Initializing Special objects"
		for(var/obj/water/tank/i in world)
			i.on = 1
		for(var/obj/window_spawner/G in world)
			G.Initialize_Window()
		for(var/obj/machinery/sleeper/spawner/e in world)
			rand_spawns += e
		world << "\green \b Initialized special objects in [world.timeofday-start_time/10] seconds!"

		start_time = world.timeofday
		world << "\red \b Creating sandbox spawn list."
		for(var/i in typesof(/obj/item)-/obj/item)
			listofitems = "[listofitems]<br><a href=?[i]>[i]</a>"
		for(var/i in typesof(/obj)+typesof(/mob))
			listofitems2 = "[listofitems2]<br><a href=?[i]>[i]</a>"
			typepaths += i
		world << "\green \b Created sandbox spawn list in [world.timeofday-start_time/10] seconds!"

		world << "\green \b Initializations complete in [world.timeofday-RLstart_time/10] seconds!"

	start_processing()
		spawn()
			slow_process()
		spawn()
			water_process()
		spawn()
			fast_process()
		spawn()
			process()
	setup_objects()

		var/start_time = world.timeofday

		world << "\red \b Initializing objects"

		for(var/obj/object in world)
			object.initialize()
		world << "\green \b Initialized objects system in [world.timeofday-start_time] seconds!"



		world << "\red \b Initializing pipe networks"

		start_time = world.timeofday
		for(var/obj/machinery/atmospherics/machine in world)
			machine.build_network()
		world << "\green \b Initialized pipe networks system in [world.timeofday-start_time] seconds!"
	fast_process()
		frm_counter += 1
		if(ticker)
			ticker.process_timer()
		for(var/obj/i in special_processing)
			i.special_process()
		for(var/obj/projectile/G in bullets)
			G.bullet_process()
		if(lighting_inited)
			lighting.loop()
		particle_process()
		do_gravity_loop()
		plrs = 0
		for(var/client/i in clients)
			i.InactivityLoop()
			i.ProcessClient()
			if(!istype(i.mob,/mob/dead))
				if(i.mob.health > 0)
					plrs = plrs + 1
					//lastplr = i
		CPU_CHECK()
		spawn(tick_lag_original)
			fast_process()
	water_process()
		water_cycles += 1
		water_master.process()
		spawn(tick_lag_original)
			water_process()
	slow_process()
		atmos_processed = 0
		air_master.process()

		for(var/datum/pipe_network/network in pipe_networks)
			CHECK_TICK_ATMOS() //first time this is used on a non atmos thing
			network.process()


		sun.calc_position()
		world.update_status()

		spawn(SLOW_PROCESS_TIME)
			slow_process()
	process()

		if(!processing)
			return 0

		master_Processed = 0

		mobs_process()

		T = T + 1
		process_objects_done = 0
		while(process_objects_done < machines.len)
			process_objects_done += 1
			var/obj/machinery/machine = machines[process_objects_done]
			if(machine)
				CHECK_TICK()
				machine.process()
				if(T % 90 == 45)
					machine.updateUsrDialog()
			else
				machines -= machine

		process_objects_done = 0
		while(process_objects_done < processing_items.len)
			process_objects_done += 1
			var/obj/item/item = processing_items[process_objects_done]
			if(item)
				CHECK_TICK()
				item.process()
			else
				processing_items -= item
		process_objects_done = 0
		while(process_objects_done < powernets.len)
			process_objects_done += 1
			var/datum/powernet/P = powernets[process_objects_done]
			if(P)
				CHECK_TICK()
				P.reset()
			else
				powernets -= P

		ticker.process()


		spawn(wait)
			process()