/*
-----------------------READ!!!!!!!!!!!!!!-----------------------
Animation System By AlcaroIsAFrick
No credit required, but credit me if you want, praise me, idc tbh but please code your own animations, thanks. It's been extensively commented.

WARNING : This is not really well optimized, and could cause memory leaks, No CPU spikes though. I think.

This is plug and play, but follow the advice below :
	1. Make sure your player icon (ingame) is a /icon, and not like this.
		icon = 'lol.dmi'
		Should be
		icon = new /icon('lol.dmi',"state")
		(you need to set that in runtime though, in a proc like new(), but I think TG already does that. Not sure.)

	2. Make it so the player/mob can't move while ANIMATION_RUNNING is 1. And do not let them change directions. Dir should stay at 2. REMINDER THAT THIS ANIMATION SYSTEM IS NOT 4 DIR!!!

I have included one animation in this, which is the dab animation. Edit it and find out what happens.

Limbs (if animating):
	Limb1 - Head
	Limb2 - Torso
	Limb3 - Left Arm
	Limb4 - Right Arm
	Limb5 - Left Leg
	Limb6 - Right Leg


ok thank you for reading this now you can freely do whatever you want
*/

mob
	var/obj/dance_displayer/danc
	var/ANIMATION_RUNNING = 0 //You might want to make it so you can't move when this is true. (or 1)
	living
		carbon
			human
				verb
					T_Pose()
						set category = "Animations"
						set name = {""T-Pose""}
						if(!ANIMATION_RUNNING)
							dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

							view() << "<b>[name]</b> does a T-Pose!"

							danc = new(locate(x,y,z),src)
							ANIMATION_RUNNING = 1 //This part initializes the animation.

							var/matrix/RightArm = matrix()
							var/matrix/LeftArm = matrix() //You can create as much matrixes, then control them, as seen below.

							RightArm.Turn(-90)
							RightArm.Translate(7,-1)
							LeftArm.Turn(90)
							LeftArm.Translate(-8,-2)

							animate(danc.Limb3,transform = LeftArm, time = 10, easing = SINE_EASING | EASE_OUT)
							animate(danc.Limb4,transform = RightArm, time = 10, easing = SINE_EASING | EASE_OUT) //This is what causes the magic.

							sleep(20)

							danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

							danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
							ANIMATION_RUNNING = 0
					Fart()
						set category = "Animations"
						set name = {""The Fart""}
						spawn()
							if(!ANIMATION_RUNNING)
								dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

								view() << "<b>[name]</b> farts."
								playsound(src, 'sound/fart.ogg', 100, 0, 4, 0) //hilarity %100

								danc = new(locate(x,y,z),src)
								ANIMATION_RUNNING = 1 //This part initializes the animation.

								var/matrix/RightLeg = matrix()
								var/matrix/LeftLeg = matrix() //You can create as much matrixes, then control them, as seen below.

								RightLeg.Turn(-5)
								//RightLeg.Translate(-1,10)
								LeftLeg.Turn(5)
								//LeftLeg.Translate(-8,0)

								animate(danc.Limb5,transform = LeftLeg, time = 2)
								animate(danc.Limb6,transform = RightLeg, time = 2) //This is what causes the magic.

								sleep(5)

								danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

								danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
								ANIMATION_RUNNING = 0

					Dab()
						set category = "Animations"
						set name = {""Dab""}
						spawn()
							if(!ANIMATION_RUNNING)
								dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

								view() << "<b>[name]</b> dabs!"

								danc = new(locate(x,y,z),src)
								ANIMATION_RUNNING = 1 //This part initializes the animation.

								var/matrix/RightArm = matrix()
								var/matrix/LeftArm = matrix() //You can create as much matrixes, then control them, as seen below.

								RightArm.Turn(90)
								RightArm.Translate(-1,10)
								LeftArm.Turn(90)
								LeftArm.Translate(-8,0)

								animate(danc.Limb3,transform = LeftArm, time = 2)
								animate(danc.Limb4,transform = RightArm, time = 2) //This is what causes the magic.

								sleep(5)

								danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

								danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
								ANIMATION_RUNNING = 0
					Clap()
						set category = "Animations"
						set name = {""The Clap""}
						spawn()
							if(!ANIMATION_RUNNING)
								dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

								view() << "<b>[name]</b> claps."

								danc = new(locate(x,y,z),src)
								ANIMATION_RUNNING = 1 //This part initializes the animation.

								var/matrix/Reset = matrix()
								var/matrix/RightArm = matrix()
								var/matrix/LeftArm = matrix() //You can create as much matrixes, then control them, as seen below.

								RightArm.Turn(45)
								RightArm.Translate(-1,5)
								LeftArm.Turn(-45)
								LeftArm.Translate(1,5)
								for(var/i in 1 to 20)
									animate(danc.Limb3,transform = LeftArm, time = 1)
									animate(danc.Limb4,transform = RightArm, time = 1) //This is what causes the magic.
									sleep(1)
									view() << 'sound/clap.ogg'
									animate(danc.Limb3,transform = Reset, time = 1)
									animate(danc.Limb4,transform = Reset, time = 1)
									sleep(1)


								danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

								danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
								ANIMATION_RUNNING = 0
					Disco_Fever()
						set category = "Animations"
						set name = {""Disco Fever""}
						spawn()
							if(!ANIMATION_RUNNING)
								dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

								playsound(src, 'sound/disco fever.ogg', 100, 0, 7, 0)

								danc = new(locate(x,y,z),src)
								ANIMATION_RUNNING = 1 //This part initializes the animation.

								var/matrix/RightArm = matrix()
								var/matrix/RightArm2 = matrix()
								var/matrix/LeftArm = matrix() //You can create as much matrixes, then control them, as seen below.
								var/matrix/LeftArm2 = matrix()
								var/matrix/RightLeg = matrix()
								var/matrix/LeftLeg = matrix()
								var/matrix/RightLeg2 = matrix()
								var/matrix/LeftLeg2 = matrix()
								var/matrix/Head = matrix()

								RightArm.Turn(10)
								RightArm.Translate(0,0)
								RightArm2.Turn(-10)
								RightArm2.Translate(0,0)

								LeftArm.Turn(-45)
								LeftArm.Translate(3,6)
								LeftArm2.Turn(90)
								LeftArm2.Translate(-6,-3)

								RightLeg.Turn(-10)
								RightLeg.Translate(1,0)
								RightLeg2.Turn(-10)
								RightLeg2.Translate(-1,0)
								//RightLeg.Translate(-6,-8)
								LeftLeg.Turn(10)
								LeftLeg2.Translate(1,0)
								LeftLeg2.Turn(10)
								LeftLeg2.Translate(-1,0)
								//LeftLeg.Translate(5,-9)
								//Head.Turn(-10)

								animate(danc.Limb1,transform = Head, time = 2)

								animate(danc.Limb6,transform = RightLeg, time = 2)
								animate(danc.Limb5,transform = LeftLeg, time = 2)

								animate(danc.Limb3,transform = LeftArm, time = 2)
								spawn()
									for(var/i in 1 to 42) //This would be 4 seconds.
										animate(danc.Limb4,transform = RightArm, time = 2) //This is what causes the magic.
										sleep(2)
										animate(danc.Limb4,transform = RightArm2, time = 2)
										sleep(2)
								spawn()
									for(var/i in 1 to 24)
										animate(danc.Limb5,transform = LeftLeg2, time = 4)
										animate(danc.Limb6,transform = RightLeg2, time = 4)
										animate(danc.Limb3,transform = LeftArm, time = 3)
										sleep(4)
										animate(danc.Limb5,transform = LeftLeg, time = 4)
										animate(danc.Limb6,transform = RightLeg, time = 4)
										animate(danc.Limb3,transform = LeftArm2, time = 3)
										sleep(4)
								sleep(180)
								danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

								danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
								ANIMATION_RUNNING = 0
					Hate_Niggers()
						set category = "Animations"
						set name = {""I hate niggers""}
						spawn()
							if(!ANIMATION_RUNNING)
								dir = 2 //Makes it so you face south. I don't plan to add support for 4-dir animations.

								playsound(src, 'sound/hate niggers.ogg', 100, 0, 7, 0)

								danc = new(locate(x,y,z),src)
								ANIMATION_RUNNING = 1 //This part initializes the animation.

								var/matrix/Reset = matrix()
								var/matrix/RightArm = matrix()
								var/matrix/LeftArm = matrix() //You can create as much matrixes, then control them, as seen below.
								var/matrix/Torso = matrix()
								var/matrix/Head = matrix()

								RightArm.Scale(1,-1)
								RightArm.Translate(0,7)
								LeftArm.Scale(1,-1)
								LeftArm.Translate(0,7)
								Torso.Translate(0,-1)
								Head.Translate(0,-1)
								sleep(4.5)
								for(var/i in 1 to 8)
									animate(danc.Limb1,transform = Head,time=2)
									animate(danc.Limb2,transform = Torso,time=2)
									animate(danc.Limb3,transform = LeftArm, time = 1)
									animate(danc.Limb4,transform = Reset, time = 1)
									sleep(3)
									animate(danc.Limb1,transform = Reset,time=2)
									animate(danc.Limb2,transform = Reset,time=2)
									animate(danc.Limb3,transform = Reset, time = 1)
									animate(danc.Limb4,transform = RightArm, time = 1) //This is what causes the magic.
									sleep(3)

								sleep(1)
								danc.Reset_Limbs() //make sure to put this at the end of a animation (or anywhere), since it resets your body part positions.

								danc.End_Animation() //This also, but only put this if you're gonna put ANIMATION_RUNNING = 0 below.
								ANIMATION_RUNNING = 0

obj
	limb_dance
		icon = 'extra images/Sprited Animations.dmi'
		mouse_opacity = 0
		anchored = 1 //your codebase should already have this variable. if it gives you a error, get rid of this.
	dance_displayer
		var/obj/limb_dance/Limb1 = null
		var/obj/limb_dance/Limb2 = null
		var/obj/limb_dance/Limb3 = null
		var/obj/limb_dance/Limb4 = null
		var/obj/limb_dance/Limb5 = null
		var/obj/limb_dance/Limb6 = null
		var/mob/owner = null
		var/icon/PlayerIcon = null
		mouse_opacity = 0
		New(loc,var/g)
			owner = g
			..()
			owner.ANIMATION_RUNNING = 1
			if(PlayerIcon)
				del PlayerIcon
			icon = null
			if(owner)
				owner.alpha = 0
				SplitIcon()
			var/matrix/Reset = matrix()
			if(owner.MyShadow)
				owner.MyShadow.overlays = null
				owner.MyShadow.icon = null
				owner.MyShadow.underlays = null
				owner.MyShadow.vis_contents = null
				animate(owner.MyShadow,transform = Reset, time = 2.5)
			for(var/obj/limb_dance/A in list(Limb1,Limb2,Limb3,Limb4,Limb5,Limb6))
				A.plane = owner.plane
				A.layer = owner.layer //g
				if(A != null)
					animate(A,transform = Reset, time = 2.5)
					owner.MyShadow.vis_contents += A
			sleep(2.5)
		Del()
			if(Limb1)
				del Limb1
			if(Limb2)
				del Limb2
			if(Limb3)
				del Limb3
			if(Limb4)
				del Limb4
			if(Limb5)
				del Limb5
			if(Limb6)
				del Limb6
			..()
		proc/End_Animation()
			if(owner)
				owner.alpha = 255
			if(owner.MyShadow)
				owner.MyShadow.vis_contents = null
				owner.MyShadow.transform = owner.transform
			owner:update_clothing() //update their stuff
			del src
		proc/Reset_Limbs()
			for(var/obj/limb_dance/g in list(Limb1,Limb2,Limb3,Limb4,Limb5,Limb6))
				animate(g,transform = owner.transform, time = 5)
			/*if(owner.MyShadow)
				animate(owner.MyShadow,transform = owner.transform, time = 2.5)*/
			sleep(5)
		proc/SplitIcon()
			PlayerIcon = new('extra images/Sprited Animations.dmi',"Blank Dir 2 Template",2)

			for(var/a in owner.underlays) //big brain, i could optimize this but I'm too lazy it works though so fuck you -somebody
				var/image/Image = a
				var/icon/EE = new(Image.icon,Image.icon_state)
				PlayerIcon.Blend(EE,ICON_OVERLAY,Image.pixel_x+1,Image.pixel_y+1)
				del EE

			PlayerIcon.Blend(owner.icon,ICON_OVERLAY,1,1)

			for(var/a in owner.overlays)
				var/image/Image = a
				var/icon/EE = new(Image.icon,Image.icon_state)
				PlayerIcon.Blend(EE,ICON_OVERLAY,Image.pixel_x+1,Image.pixel_y+1)
				del EE
			/*
			coders, mess with this on your own. this proc what it does is create a /obj/limb_dance with the icon of your player icon, and the args are

			DoSplitIcon(1,2,3,4,5)

			1 - X Position 1
			2 - Y Position 1

			3 - Y Position 2
			4 - Y Position 2

			5 - Layer (any)

			You can get 1,2,3,4 with the icon editor, see this : https://i.imgur.com/efjOvno.png

			*/
			Limb1 = DoSplitIcon(10,23,22,32,1)

			Limb2 = DoSplitIcon(12,9,20,22,2)

			Limb3 = DoSplitIcon(6,11,11,21,3)
			Limb4 = DoSplitIcon(21,11,26,21,4)

			Limb5 = DoSplitIcon(1,1,15,8,5)
			Limb6 = DoSplitIcon(16,1,32,8,6)

		proc/Update_Y()
			for(var/obj/limb_dance/g in list(Limb1,Limb2,Limb3,Limb4,Limb5,Limb6))
				if(g)
					g.pixel_y = owner.pixel_z
		proc/DoSplitIcon(var/x1,var/y1,var/x2,var/y2,var/ord)
			var/icon/I = new('extra images/Sprited Animations.dmi',"Blank Dir 2 Template",2)
			I.Blend(PlayerIcon,ICON_OVERLAY,1,1)
			I.Crop(x1,y1,x2,y2)

			var/obj/limb_dance/G = new(locate(x,y,z))
			var/icon/E = new('extra images/Sprited Animations.dmi',"Blank Dir 2 Template",2)
			E.Blend(I,ICON_OVERLAY,x1,y1)

			del I
			G.transform = owner.transform
			G.layer = owner.layer + ord/10
			G.icon = E
			G.plane = owner.plane
			G.pixel_y = owner.pixel_z
			return G