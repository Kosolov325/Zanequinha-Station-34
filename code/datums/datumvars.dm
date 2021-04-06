client
	proc/debug_variables(datum/D in world)
		set category = "Admin"
		set name = "(ADMIN) Modify And View Variables"


		var/title = ""
		var/body = ""
		var/atom/A
		if (istype(D, /atom))
			A = D
			title = "[A.name] (\ref[A]) = [A.type]"

			title = "[D] (\ref[D]) = [D.type]"


			body += "<ol>"

			var/list/names = list()
			for (var/V in D.vars)
				names += V

			names = sortList(names)

			for (var/V in names)
				body += debug_variable(V, D.vars[V], 0, A)

			body += "</ol>"

			var/html = "<html><head>"
			if (title)
				html += "<title>[title]</title>"
			html += {"<style>
		body
		{
			font-family: Verdana, sans-serif;
			font-size: 9pt;
		}
		.value
		{
			font-family: "Courier New", monospace;
			font-size: 8pt;
		}
		</style>"}
			html += "</head><body>"
			html += body
			html += "</body></html>"

			usr << browse(cssStyleSheetDab13 + html, "window=variables\ref[D]")

			return




	proc/debug_variable(name, value, level, atom/E)
		var/html = ""

		html += "<li>"

		if (isnull(value))
			html += "[name] = <span class='value'>null</span>"

		else if (istext(value))
			html += "[name] = <span class='value'>\"[value]\"</span>"

		else if (isicon(value))
			html += "[name] = /icon (<span class='value'>[value]</span>)"

		else if (isfile(value))
			html += "[name] = <span class='value'>'[value]'</span>"

		else if (istype(value, /datum))
			var/datum/D = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [D.type]"

		else if (istype(value, /client))
			var/client/C = value
			html += "<a href='byond://?src=\ref[src];Vars=\ref[value]'>[name] \ref[value]</a> = [C] [C.type]"
	//
		else if (istype(value, /list))
			var/list/L = value
			html += "[name] = /list ([L.len])"

			if (L.len > 0 && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > 500))
				// not sure if this is completely right...
				if (0) // (L.vars.len > 0)
					html += "<ol>"
					for (var/entry in L)
						html += debug_variable(entry, L[entry], level + 1)
					html += "</ol>"
				else
					html += "<ul>"
					for (var/index = 1, index <= L.len, index++)
						html += debug_variable("[index]", L[index], level + 1)
					html += "</ul>"
		else
			html += "[name] = <span class='value'>[value]</span>"

		html += "<a href='?src=\ref[src];VarsEdit=[name];Ass=\ref[E]'>Edit Value</a></li>"

		return html

	Topic(href, href_list, hsrc)

		if (href_list["Vars"])
			debug_variables(locate(href_list["Vars"]))
		else if (href_list["VarsEdit"])
			if(href_list["Ass"])
				edit_variable(href_list["VarsEdit"],locate(href_list["Ass"]))
		else
			..()



/mob/proc/Delete(atom/A in view())
	set category = "Debug"
	switch (alert("Are you sure you wish to delete \the [A.name] at ([A.x],[A.y],[A.z]) ?", "Admin Delete Object","Yes","No"))
		if("Yes")
			log_admin("[usr.key] deleted [A.name] at ([A.x],[A.y],[A.z])")

/client/proc/edit_variable(var/variable,var/atom/O)
	if(!variable || !istype(O,/atom))
		src << "Error in editing [O]."
		return
	var/default
	var/var_value = O.vars[variable]
	var/dir

	if(isnull(var_value))
		usr << "Unable to determine variable type."

	else if(isnum(var_value))
		usr << "Variable appears to be <b>NUM</b>."
		default = "num"
		dir = 1

	else if(istext(var_value))
		usr << "Variable appears to be <b>TEXT</b>."
		default = "text"

	else if(isloc(var_value))
		usr << "Variable appears to be <b>REFERENCE</b>."
		default = "reference"

	else if(isicon(var_value))
		usr << "Variable appears to be <b>ICON</b>."
		var_value = "\icon[var_value]"
		default = "icon"

	else if(istype(var_value,/atom) || istype(var_value,/datum))
		usr << "Variable appears to be <b>TYPE</b>."
		default = "type"

	else if(istype(var_value,/list))
		usr << "Variable appears to be <b>LIST</b>."
		default = "list"

	else if(istype(var_value,/client))
		usr << "Variable appears to be <b>CLIENT</b>."
		default = "cancel"

	else
		usr << "Variable appears to be <b>FILE</b>."
		default = "file"

	usr << "Variable contains: [var_value]"
	if(dir)
		switch(var_value)
			if(1)
				dir = "NORTH"
			if(2)
				dir = "SOUTH"
			if(4)
				dir = "EAST"
			if(8)
				dir = "WEST"
			if(5)
				dir = "NORTHEAST"
			if(6)
				dir = "SOUTHEAST"
			if(9)
				dir = "NORTHWEST"
			if(10)
				dir = "SOUTHWEST"
			else
				dir = null
		if(dir)
			usr << "If a direction, direction is: [dir]"

	var/class = input("What kind of variable?","Variable Type",default) as null|anything in list("text",
		"num","type","reference","mob reference", "icon","file","list","edit referenced object","restore to default")

	if(!class)
		return

	var/original_name

	if (!istype(O, /atom))
		original_name = "\ref[O] ([O])"
	else
		original_name = O:name

	switch(class)

		if("list")
			src << "Lists cannot be modified yet."
			return

		if("restore to default")
			O.vars[variable] = initial(O.vars[variable])

		if("edit referenced object")
			return .(O.vars[variable])

		if("text")
			O.vars[variable] = input("Enter new text:","Text",\
				O.vars[variable]) as text

		if("num")
			O.vars[variable] = input("Enter new number:","Num",\
				O.vars[variable]) as num

		if("type")
			O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
				in typesof(/obj,/mob,/area,/turf)

		if("reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob|obj|turf|area in world

		if("mob reference")
			O.vars[variable] = input("Select reference:","Reference",\
				O.vars[variable]) as mob in world

		if("file")
			O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
				as file

		if("icon")
			O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
				as icon

	log_admin("[key_name(src)] modified [original_name]'s [variable] to [O.vars[variable]]")
	message_admins("[key_name_admin(src)] modified [original_name]'s [variable] to [O.vars[variable]]", 1)

