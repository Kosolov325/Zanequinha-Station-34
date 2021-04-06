
/obj/machinery/computer/dab_coin
	name = "Dabcoin Bank Computer"
	icon_state = "dabcoin"
	var/datum/credit_card/Cred = null

	attack_hand(mob/user)
		user << browse(cssStyleSheetDab13 + return_text(),"window=computer")
		user.machine = src
		onclose(user, "computer")
	attackby(I as obj, user as mob)
		if(istype(I,/obj/item/weapon/dabdollar))
			var/obj/item/weapon/dabdollar/E = I
			if(Cred)
				Cred.dabcoins += E.worth
				user << "\green You add [E.worth] dab coins to the machine!"
				del I
			else
				user << "\red Error, not logged in."
		else
			..()

	proc/return_text()
		var/output
		if(Cred)
			output = {"Logged in : [Cred.owner]'s card<br>
			Current Dabcoins : [Cred.dabcoins]<br>
			To add more dabcoins, get a dab dollar and insert it into the machine, examine your dollar to find out it's value.<br>
			<A href='?src=\ref[src];logout=1'>Log out</A>"}
		else
			output = {"Welcome to the dabcoins bank service.<br><br>
			What do you want to do today?<br><br>
			<A href='?src=\ref[src];loadcard=1'>Log in (with card)</A>"}
		return output

	Topic(href, href_list)
		if(..())
			return

		if (href_list["loadcard"])
			if(istype(usr,/mob/living/carbon/human))
				var/obj/item/weapon/card/C = usr:wear_id
				if(C && istype(C,/obj/item/weapon/card))
					if(C.credit)
						var/cod = input(usr,"Security Code","Credit Card Check") as num|null
						if("[cod]" == "[C.credit.code]")
							Cred = C.credit
		if (href_list["logout"])
			Cred = null //Log out.
		src.add_fingerprint(usr)
		src.updateUsrDialog()