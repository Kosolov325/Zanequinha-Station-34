
client
	verb/Resolution()
		set hidden = 1
		var/viewX = input("What resolution in X (pixels), Recommended : 672, Default 608","Input resolution") as num|null
		if(viewX)
			viewX = round(viewX/32)
			if(viewX < 17)
				viewX = 17
			if(viewX > 33)
				viewX = 33
		else
			viewX = 17

		var/viewY = input("What resolution in Y (pixels), Recommended : 480, Default 480","Input resolution") as num|null
		if(viewY)
			viewY = round(viewY/32)
			if(viewY < 15)
				viewY = 15
			if(viewY > 33)
				viewY = 33
		else
			viewY = 15
		view = "[viewX]x[viewY]"
		var/savefile/F = new("SavedPlayerResolutions/[key]Resolution.sav")
		WriteSaveRes(F)
	proc/WriteSaveRes(savefile/F)
		F["view"] << view
		//src << "<font color='green'><b>Saved resolution [view] successfully!"
	proc/ReadSaveRes(savefile/F)
		if(!F["view"])
			F["view"] << "17x15"
		F["view"] >> view
		//src << "<font color='green'><b>Loaded resolution [view] successfully!"
	New()
		..()
		var/savefile/F = new("SavedPlayerResolutions/[key]Resolution.sav")
		ReadSaveRes(F)


//HUD BUttons

//Inventory

/*
old ui incase you are rarted
#define ui_rhand "CENTER:16,1:8" //Center of screen, right

#define ui_lhand "CENTER:-16,1:8" //Center of screen, left


#define ui_storage1 "5,1:8" //Storage is not known yet

#define ui_storage2 "6:8,1:8" //Not yet


#define ui_iclothing "1:8,2:16" //Left Center Down

#define ui_oclothing "2:16,2:16" //Center Center Down

#define ui_glasses "1:8,5" //Left Top

#define ui_gloves "1:8,3:24" //Left Center Up

#define ui_id "3:24,1:8" //Right Bottom

#define ui_mask "2:16,3:24" //Center Center Up

#define ui_back "1:8,1:8" //Left Bottom

#define ui_shoes "2:16,1:8" //Center Bottom

#define ui_ears "3:24,3:24" //Right Top

#define ui_head "2:16,5" //Center Top

#define ui_belt "3:24,2:16" //Right Center Down
*/


#define ui_rhand "CENTER:16,1:4" //Center of screen, right

#define ui_lhand "CENTER:-16,1:4" //Center of screen, left


#define ui_storage1 "5:20,1:4" //right to rhand
#define ui_storage2 "6:24,1:4" //left to lhand

#define ui_iclothing  "1:4,2:8"
#define ui_oclothing  "2:8,2:8"
#define ui_back       "3:12,2:8"

#define ui_shoes      "2:8,1:4"

#define ui_gloves     "1:4,1:4"

#define ui_id         "4:16,1:4"
#define ui_belt       "3:12,1:4"

#define ui_mask       "2:8,3:12"
#define ui_glasses    "1:4,3:12"
#define ui_ears       "3:12,3:12"
#define ui_head       "2:8,4:16"

//HUD Details
#define ui_toxin "EAST-1:-4, SOUTH:4"
#define ui_fire "EAST:-4, SOUTH:4"

#define ui_temp "WEST+5, NORTH"
#define ui_oxygen "WEST+4, NORTH"

#define ui_internal "WEST+2, NORTH"
#define ui_health "west, NORTH"

//More Hud details


#define ui_hand "EAST,2"

#define ui_sleep "WEST+1,NORTH" //both should be there.
#define ui_rest "WEST+1,NORTH"

#define ui_acti "EAST,NORTH-1"
#define ui_movi "EAST,NORTH-2"

#define ui_resist "EAST,NORTH-3"
#define ui_dropbutton "EAST,NORTH-4" //center of screen, right to rhand
#define ui_pull "EAST,NORTH-4"

#define ui_throw2 "EAST,NORTH-3"


/*
//TESTING A LAYOUT
#define ui_mask "south:-14,1:7"
#define ui_headset "SOUTH-2:-14,1:7"
#define ui_head "south:-14,1:51"
#define ui_glasses "south:-14,2:51"
#define ui_ears "south:-14,3:51"
#define ui_oclothing "south:-49,1:51"
#define ui_iclothing "SOUTH-2:-49,1:51"
#define ui_shoes "SOUTH-3:-49,1:51"
#define ui_back "south:-49,2:51"
#define ui_lhand "SOUTH-2:-49,2:51"
#define ui_rhand "SOUTH-2:-49,0:51"
#define ui_gloves "SOUTH-3:-49,0:51"
#define ui_belt "SOUTH-2:-49,1:127"
#define ui_id "SOUTH-2:-49,2:127"
#define ui_storage1 "SOUTH-3:-49,1:127"
#define ui_storage2 "SOUTH-3:-49,2:127"

#define ui_dropbutton "SOUTH-3,12"
#define ui_swapbutton "south,13"
#define ui_resist "SOUTH-3,14"
#define ui_throw2 "SOUTH-3,15"
#define ui_oxygen "east, NORTH-4"
#define ui_toxin "east, NORTH-6"
#define ui_internal "east, NORTH-2"
#define ui_fire "east, NORTH-8"
#define ui_temp "east, NORTH-10"
#define ui_health "east, NORTH-11"
#define ui_pull "WEST+6,SOUTH-2"
#define ui_hand "south,6"
#define ui_sleep "east, NORTH-13"
#define ui_rest "east, NORTH-14"
//TESTING A LAYOUT
*/

mob/living/carbon/uses_hud = 1

/obj/hud/var/obj/screen/action_intent
/obj/hud/var/obj/screen/move_intent

