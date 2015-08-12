/*
Backburner job submission written by Jacob Jeziorski (www.JakubJeziorski.com)
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/

struct LPM_BackburnerAPI
(
	type="Backburner",
	fn submit=
	(
		rollout LPM_BackburnerSubmitRo "Backburner" width:323 height:355
		(
			dotNetControl serversLV "System.Windows.Forms.ListView" width:168 height:94 pos:[130,90]

			radiobuttons serverTypeRadio "" pos:[16,92] width:104 height:32 labels:#("All Servers", "Selected Servers", "All Idle Servers","Group") columns:1
			checkbox autoSearchCheck "Automatic Search" pos:[87,40] width:108 height:16 checked:true
			checkbox autoConnectCheck "Auto" pos:[16,40] width:60 height:16 checked:true
			GroupBox grp1 "Server Usage" pos:[6,69] width:303 height:124
			dropdownlist serverGroup pos:[16,160] items:#() width:104 enabled:false

			GroupBox grp2 "Enter Subnet Mask" pos:[6,1] width:303 height:61
			edittext ip1 text:"255.255.255.0" pos:[86,18] width:200 height:16
			button connectButton "Connect" pos:[15,16] width:65 height:21

			GroupBox grp4 "Options" pos:[6,247] width:304 height:50
			GroupBox grp5 "Priority" pos:[6,196] width:304 height:50
			spinner prioritySpinner "" pos:[15,215] width:50 height:16 range:[0,100,50] type:#integer

			checkbox includeMapsCheck "Include Maps" pos:[10,268] width:122 height:22
			checkbox sendSuspendedCheck "Initially Suspended" pos:[160,268] width:122 height:22
			GroupBox grp6 "Submit" pos:[6,300] width:307 height:50
			button SubmitButton "Submit" pos:[13,317] width:75 height:27 enabled:false
			progressBar submitProgress pos:[13,317] width:290 height:27 visible:false

			local mmBackburner, servers

			fn getIconFromBitmap thePath number iconFileName =
			(
				theFileName = (getFilenamePath thePath) + iconFileName + ".bmp"

				if not doesFileExist theFileName do
				(
					tempBmp = openBitmap thePath
					iconBmp = bitmap 12 12
					for v = 0 to 11 do
						setPixels iconBmp [0,v] (getPixels tempBmp [(number-1)*12, v] 12)
					iconBmp.filename = theFileName
					save iconBmp
					close iconBmp
					close tempBmp
				)
				return theFileName
			)


			fn initListView lv =
			(
				local iconPath=(::LPM_DIR+ "icons\\LPM\\serversStatus.bmp")

				lv.hideSelection = false
				lv.fullRowSelect = true
				lv.ownerDraw = false

				lv.Columns.add "Server" 84
				lv.Columns.add "Status" 64

				lv.View = (dotNetClass "System.Windows.Forms.View").Details

				ilLV = dotNetObject "System.Windows.Forms.ImageList"
				ilLV.imageSize = dotNetObject "System.Drawing.Size" 12 12

				img = dotNetClass "System.Drawing.Image"
				ilLV.images.add (img.fromFile (getIconFromBitmap iconPath 1 "serverAbsent" ) )
				ilLV.images.add (img.fromFile (getIconFromBitmap iconPath 2 "serverBusy" ) )
				ilLV.images.add (img.fromFile (getIconFromBitmap iconPath 3 "serverIdle" ) )
				ilLV.images.add (img.fromFile (getIconFromBitmap iconPath 4 "serverError" ) )
				ilLV.TransparentColor = (dotNetClass "System.Drawing.Color").White
				lv.SmallImageList = ilLV

			)


			fn saveSettings =
			(
				LPM_Fun.SetIni "Backburner Settings" "managerIP" ip1.text
				LPM_Fun.SetIni "Backburner Settings" "autoSearch" autoSearchCheck.checked
				LPM_Fun.SetIni "Backburner Settings" "autoConnect" autoConnectCheck.checked
				LPM_Fun.SetIni "Backburner Settings" "includeMaps"  includeMapsCheck.checked
				LPM_Fun.SetIni "Backburner Settings" "sendSuspended" sendSuspendedCheck.checked
				LPM_Fun.SetIni "Backburner Settings" "serverUsageType" serverTypeRadio.state
				LPM_Fun.SetIni "Backburner Settings" "priority"  prioritySpinner.value
				LPM_Fun.SetIni "Backburner Settings" "serverGroup" serverGroup.selection
				
				if (isValidNode $LPM_Backburner_Settings) then 
					localSettings = $LPM_Backburner_Settings
				else
				(
					localSettings = LPM_Fun.createNode "Backburner_Settings" "empty"
					localSettings.parent = $LPM_Root
				)
				
				LPM_Fun.setProp localSettings "managerIP" ip1.text
				LPM_Fun.setProp localSettings "autoSearch" autoSearchCheck.checked
				LPM_Fun.setProp localSettings "autoConnect" autoConnectCheck.checked
				LPM_Fun.setProp localSettings "includeMaps"  includeMapsCheck.checked
				LPM_Fun.setProp localSettings "sendSuspended" sendSuspendedCheck.checked
				LPM_Fun.setProp localSettings "serverUsageType" serverTypeRadio.state
				LPM_Fun.setProp localSettings "priority"  prioritySpinner.value
				LPM_Fun.setProp localSettings "serverGroup" serverGroup.selection
			)

			fn loadSettings =
			(
				ip1.text = LPM_Fun.getIni "Backburner Settings" "managerIP" string "255.255.255.0"
				autoSearchCheck.checked = LPM_Fun.getIni "Backburner Settings" "autoSearch" booleanClass true
				autoConnectCheck.checked = LPM_Fun.getIni "Backburner Settings" "autoConnect" booleanClass false
				includeMapsCheck.checked =LPM_Fun.getIni "Backburner Settings" "includeMaps" booleanClass false
				sendSuspendedCheck.checked = LPM_Fun.getIni "Backburner Settings" "sendSuspended" booleanClass false
				serverTypeRadio.state = LPM_Fun.getIni "Backburner Settings" "serverUsageType" integer 1
				prioritySpinner.value = LPM_Fun.getIni "Backburner Settings" "priority" integer 50
				serverGroup.selection = LPM_Fun.getIni "Backburner Settings" "serverGroup" integer 1

				if (isValidNode $LPM_Backburner_Settings) then
				(
					localSettings = $LPM_Backburner_Settings
					ip1.text = LPM_Fun.getProp localSettings "managerIP" string ip1.text
					autoSearchCheck.checked = LPM_Fun.getProp localSettings "autoSearch" booleanClass autoSearchCheck.checked
					autoConnectCheck.checked = LPM_Fun.getProp localSettings "autoConnect" booleanClass autoConnectCheck.checked
					includeMapsCheck.checked = LPM_Fun.getProp localSettings "includeMaps" booleanClass includeMapsCheck.checked
					sendSuspendedCheck.checked = LPM_Fun.getProp localSettings "sendSuspended" booleanClass sendSuspendedCheck.checked
					serverTypeRadio.state = LPM_Fun.getProp localSettings "serverUsageType" integer serverTypeRadio.state
					prioritySpinner.value = LPM_Fun.getProp localSettings "priority" integer prioritySpinner.value
					serverGroup.selection = LPM_Fun.getProp localSettings "serverGroup" integer serverGroup.selection
				)
				serverGroup.enabled = (serverGroup.selection==4)
			)
			
			fn doManagerConnect=
			(
				connected=false
				if( autoSearchCheck.checked) then
					connected=mmBackburner.connect #automatic ip1.text
				else
					connected=mmBackburner.connect #manual ip1.text
				return (mmBackburner.connected)
			)
			
			fn netManagerConnect lv =
			(
				mmBackburner=NetRender.GetManager()
				connected=doManagerConnect()
				
				submitButton.enabled=connected
				
				lv.items.clear()
				if(connected==false) then
					messagebox "Manager Not Found"
				else
				(
					servers = mmBackburner.GetServers()
					for server in servers do
					(
						serverName = server.name
						(

							case server.state of
							(
								#idle: (serverIcon = 2; serverState="Idle")
								#busy:	(serverIcon = 1;serverState = "Busy")
								#absent: (serverIcon = 0; serverState = "Absent")
								default:	(serverIcon = 3; serverState = "Error")
							)
						)
						
						li = lv.Items.add serverName serverIcon
				--		if (findItem Backburner Settings.serverListSelection server.handle != 0) do li.selected = true
						li.subitems.add serverState
					)
					groups = #()
					for i = 1 to mmBackburner.numGroups do (
						gn = (mmBackburner.GetGroupName i)
						if (gn == "") do gn = "Global Group "+(i as string) -- bug in max9: doesn't return group names
						append groups gn
						)
					serverGroup.items = groups
				)
			)

			on autoSearchCheck changed state do
			(
				if(state==true) then
				(
					grp2.text="Enter Subnet Mask"
					ip1.text="255.255.255.0"
				)
				else
				(
					grp2.text="Enter Manager Name or IP Address"
					ip1.text="192.168.0.1"
				)
			)

			on serverTypeRadio changed index do
			(
				serverGroup.enabled = case index of
				(
					4: true
					default: false
				)
				serversLV.enabled = case index of
				(
					2: true
					default: false
				)
			)

			on connectButton pressed do
			(
				netManagerConnect serversLV
			)

			on SubmitButton pressed do
			(
				saveSettings()

				theServers=undefined

				case serverTypeRadio.state of
				(
					2: theServers=for i=1 to serversLV.items.count where (serversLV.items.item[(i-1)].selected == true) collect servers[i]
					3: theServers = for server in servers where (server.state == #idle) collect server
					4: theServers = mmBackburner.GetServers filter:#group key:serverGroup.selection
				)

				submitProgress.value = 0
				submitButton.visible = false
				submitProgress.visible = true
				grp6.text = "Submit progress"

				renderCollect = LPM_Fun.getWhoToRender()
				flag=true
				for i=1 to renderCollect.count where flag do
				(
					submitProgress.value = (100*(i-1))/renderCollect.count
					
					LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
					
					--Make sure we are connected to the manager
					print "reconnect to the manager"
					connected=doManagerConnect()
					--If we couldnt connect then fail
					if(connected == false) then
					(
						messagebox "Error reconnecting to the manager"
						LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]	
						return false							
					)

					
					-- prepare Backburner Job --
					SetQuietMode LPM_Root.quietMode				
						
					--first get the jobname
					jobList=mmBackburner.getjobs()
					jobName=""
					
					thePass=renderCollect[i][1]
					theShot=renderCollect[i][2]
					
					if (theShot==undefined) then 
						jobName="("+renderCollect[i][1].name+")"
					else
						jobName="{"+renderCollect[i][2].name+"} ("+renderCollect[i][1].name+")"
					
					jobName=jobName+" ["+maxfilename+"]"
					
					jobNameList=for it in jobList where (findString it.name jobName)!=undefined collect it.name
					
					if (jobNameList.count>0) do (
						increment=jobNameList.count + 1
						
					while(findItem jobNameList (jobName+"_#"+(increment as string)))!=0 do
						(increment+=1)
						jobName=jobName+"_#"+(increment as string)
					)

					job = mmBackburner.newjob()
					job.includeMaps=includeMapsCheck.checked
					job.name=jobName
					job.priority=prioritySpinner.value
						
					--common settings
					job.renderAtmosphericEffects=rendAtmosphere
					job.renderEffects=renderEffects
					job.renderDisplacements=renderDisplacements
					job.videoColorCheck=rendColorCheck
					job.renderFields=rendFieldRender
					job.renderHiddenObjects=rendHidden
					job.force2Sided=rendForce2Side
					job.superBlack=rendSuperBlack

					--addition/change end
					job.nthframe=rendNThFrame
					case rendTimeType of
					(
						1:
						(
							job.fromFrame=sliderTime
							job.toFrame=sliderTime
						)
						2:
						(
							job.fromFrame=animationRange.start
							job.toFrame=animationRange.end
						)
						3:
						(
							job.fromFrame=rendStart
							job.toFrame=rendEnd
						)
						4:
						(
							job.nonSeqFrames=true
							job.frames=rendPickupFrames
						)
					)

					job.suspended = sendSuspendedCheck.checked

					status=false
					if(theServers!=undefined) then
						status=job.submit servers:theServers
					else
						status=job.submit()
					
					if status == false then
					(
						flag = false
						print "Backburner submit failure."
						rollout LPM_Error "Network Submit Error" width:500
							(
								label lbl1 "Network submit error:" align:#left
								label lbl2 "If \"Include Maps\" is On try checking for Missing or Problematic Bitmaps." align:#left
								label lbl3 "1) Open File->Asset Tracking" align:#left
								label lbl4 "2) Convert All Bitmap Paths to Absolute Path, (Paths->Make Absolute Path)" align:#left
								hyperlink  lbl5 "Also check the following thread on useful information regarding \"Missing Maps Error saving Scene\"." address:"http://area.autodesk.com/index.php/forums/viewthread/14906/" color:blue align:#left
								button okButton "Close"
								on okButton pressed do try(destroydialog LPM_Error)catch()
							)
						createdialog LPM_Error
					)
					-- Backburner Job prepared and submitted
					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]	
					if(keyboard.escPressed) then flag=false

				)
				
				try(
					mmBackburner.disconnect()
				)catch(print "error disconnecting")
				try(destroydialog LPM_BackburnerSubmitRo)catch()
			)


			on LPM_BackburnerSubmitRo open do
			(
				loadSettings()
				initListView serversLV
				if(autoConnectCheck.checked) do netManagerConnect serversLV
			)

			on LPM_BackburnerSubmitRo close do
			(
				if(mmBackburner!=undefined) then
					mmBackburner.disconnect()
				saveSettings()
			)
			--Lukas Lepicovsky
			on LPM_BackburnerSubmitRo resized theSize do
			(
				delta=LPM_BackburnerSubmitRo.height-353
				if(delta < 0) then
					delta=0
				(
					serversLV.height=94+delta 
					grp1.height=124+delta
					grp4.pos=[6,247+delta]
					grp5.pos=[6,196+delta] 
					prioritySpinner.pos=[50, 215 + delta] 
					includeMapsCheck.pos=[10,268+delta]
					sendSuspendedCheck.pos=[160,268+delta]
					grp6.pos=[6,300+delta]
					SubmitButton.pos=[13,317+delta] 
					submitProgress.pos=[13,317+delta]
				)
			)

		)
		createDialog LPM_BackburnerSubmitRo lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos LPM_BackburnerSubmitRo.width)
		return #SUCCESS
	)
)

append LPM_NetworkPlugins (LPM_BackburnerAPI())