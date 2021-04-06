#define CHECK_IP_TIMES 3 //how much parts of a ip should we check, for ex : YYY,YYY.YYY.XXX with this setup we are only checking the Y's.

/*
anti nigger system
*/
var/list/client/Player_CID_list = list()

client/proc/check_ip_if_local()
	if(key == world.host)
		return 1
	if(key in AdministrationTeam)
		return 1
	var/list/splitted_list_world = splittext("[world.address]",".")
	var/list/splitted_list_client = splittext("[address]",".")
	var/checks = 0
	for(var/i in 1 to CHECK_IP_TIMES)
		if(splitted_list_world[i] == splitted_list_client[i])
			checks += 1
	if(checks == CHECK_IP_TIMES)
		return 1
	else
		return 0

client/New()
	..()
	spawn(1)
		if(clients.len > MAX_PLAYERS && !holder)
			src << "\red <b>Server is full."
			del src
	src << browse_rsc('html_assets/back.png',"back.png")
	spawn(10)
		if(!(check_ip_if_local()))
			if(!(key in Player_CID_list))
				if(Player_CID_list[key] != "Checked")
					Player_CID_list[key] = computer_id
					src << "<font size=4><font color='red'>You will now be reconnected to the game server to check if you are using ban evasion tools." //Uh Oh!!!
					check_cid = 1
					message_admins("[key] will be checked for ban evasion tools (JOIN)")
					src << link("byond://[world.internet_address]:[world.port]")
			else
				if (Player_CID_list[key] != computer_id && Player_CID_list[key] != "Checked")
					src << "<font size=4><font color='red'>You have been detected using ban evasion tools. The administrators have been messaged." //trolled.
					message_admins("[key] is using a CID changer. might want to get involved.")
					discord_relay("<@&464594497901166613> <@&480598635197759508> ALERT : [key] is using a CID changer. (CID changed during 2 joins.)",AdminhelpWebhook)
					Join_Message()
				else
					Player_CID_list[key] = "Checked" //don't bring that message up
					check_cid = 0
					Join_Message()
		else
			Join_Message()
client
	var/check_cid = 0
	proc/Join_Message()
		if(byond_version < 512)
			spawn(20)
				src << "<font size=6><font color='red'><b>Your byond is too outdated. Please update to BYOND [world.byond_version] or higher if you want to see the game properly, you won't see effects."
		if(!(world.port in PORTS_NOT_ALLOWED))
			spawn()
				call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"**[key]** joined (BYOND Version [byond_version].[byond_build]).\" } ", "Content-Type: application/json")
		world << "<font color='yellow'>[key] joined."
	Del()
		if(!(world.port in PORTS_NOT_ALLOWED) && check_cid == 0)
			spawn()
				call("ByondPOST.dll", "send_post_request")("[WebhookURL]", " { \"content\" : \"**[key]** left.\" } ", "Content-Type: application/json")
		world << "<font color='yellow'>[key] left the game."
		..()
