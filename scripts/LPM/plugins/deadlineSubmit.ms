/*
Deadline job submission written by Jacob Jeziorski (www.JakubJeziorski.com)
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/

global SMTDSettings, SMTDFunctions

struct LPM_DeadlineAPI
(
	type="Deadline",
	fn findSMTDFunctionsFile=
	(
		repoLocation=LPM_Fun.GetIni "Deadline Settings" "RepositoryLocation" string ""

		--Deadline 5
		functionsFile=repoLocation + "/submission/3dsmax/SubmitMaxToDeadline_Functions.ms"
		if(doesfileexist functionsFile) then
			return functionsFile

		--Deadline 6, 7
		functionsFile=repoLocation + "/submission/3dsmax/Main/SubmitMaxToDeadline_Functions.ms"
		if(doesfileexist functionsFile) then
			return functionsFile

		--Couldnt find it in the repo
		return undefined

	),

	fn setRepositoryLocation =
	(
		repoLocation=GetSavePath()
		if(repoLocation == undefined) then
			return false

		repoLocation=substitutestring repoLocation "\\" "/"
		repoLocation=trimright repoLocation "/"

		LPM_Fun.SetIni "Deadline Settings" "RepositoryLocation" repoLocation

	),

	fn executeSMTDFunctions =
	(
		--Get the Repository SMTD file
		functionsFile=findSMTDFunctionsFile()
		if(functionsFile == undefined) then
		(
			messagebox "Please Select the Root Folder of the Deadline Repository."
			
			setRepositoryLocation()

			functionsFile=findSMTDFunctionsFile()
			if(functionsFile == undefined) then
			(
				return false
			)
		)

		--Load the deadline functions
		filein functionsFile
		return true
	),

	fn submit=
	(
		rollout LPM_DeadlineSubmitRo "Deadline" width:320 height:386
		(
			GroupBox grp_pool "Pool and Priority" pos:[6,41] width:304 height:70
			label lbl_pool "Pool:" pos:[12,65] width:24 height:13
			dropdownList ddl_pool "" pos:[56,61] width:140 height:21
			label lbl_priority "Priority:" pos:[12,87] width:34 height:13
			progressBar sld_priority "" pos:[56,85] width:188 height:18 range:[0,100,50] type:#integer
			spinner spn_priority "" pos:[254,85] width:47 height:16 type:#integer fieldwidth:35
			
			GroupBox grp_job "Job Options" pos:[6,113] width:304 height:156
			label lbl_chunk "Render Task Chunk Size (Frames Per Task):" pos:[12,133] width:211 height:13
			spinner spn_chunkSize "" pos:[254,133] width:47 height:16 range:[1,1000,1] type:#integer fieldwidth:35

			checkbox chk_limitEnabled "Limit No. of Machines Rendering Concurrently  " pos:[12,153] width:246 height:15
			spinner spn_machineLimit "" pos:[254,153] width:47 height:16 enabled:false range:[1,1000,1] type:#integer fieldwidth:35

			dropdownList ddl_OutOfOrderMethod "" pos:[12,173] width:200 height:21 items:#("First To Last (Forward)", "Every Nth, Then Forward", "Every Nth - Block Fill", "Every Nth - Half Raster Refine", "Last To First (Reverse)", "From Both Ends", "From Center", "From Both Ends And From Center", "Random")
			spinner spn_outOfOrderStep "Nth:" pos:[234,175] width:67 height:16 range:[2,1000,10] type:#integer fieldwidth:35
			
			checkbox chk_EnforceSequentialRendering "Enforce Sequential Rendering" pos:[12,197] width:166 height:15

			checkbox chk_submitAsSuspended "Submit Job As Suspended" pos:[12,217] width:148 height:15
			checkbox chk_autodelete "Delete Complete Job" pos:[180,217] width:122 height:15
			
			label lbl_MaxVersionToForce "Force 3ds Max Build:" pos:[12,242] width:99 height:13
			dropdownList ddl_MaxVersionToForce "" pos:[130,238] width:80 height:21 items:#("none", "32bit", "64bit")
			
			GroupBox grp_options "Options" pos:[6,273] width:304 height:50
			dropdownList ddl_SubmitExternalFilesMode "" pos:[12,293] width:200 height:21 items:#("Do NOT copy Textures to Repository", "Copy LOCAL Textures to Repository", "Copy ALL Textures to Repository")
			checkbox chk_showvfb "Show VFB" pos:[229,297] width:74 height:15
			
			GroupBox grp_submit "Submit" pos:[6,333] width:307 height:50
			button btn_submit "Submit" pos:[13,350] width:135 height:27
			progressBar prg_submitProgress "" pos:[13,350] width:290 height:27 visible:false
			groupBox grpDeadlineRepository "Deadline Repository Settings" pos:[5,0] width:305 height:41
			button btnChangeRepo "Change Deadline Repository Location" pos:[11,16] width:294 height:19



			fn loadSettings =
			(
				--store settings as last settings
				
				SMTDSettings.PoolName = LPM_Fun.GetIni "Deadline Settings" "PoolName" string "3dsmax"
				SMTDSettings.Priority = LPM_Fun.GetIni "Deadline Settings" "Priority" integer 50
				SMTDSettings.ChunkSize = LPM_Fun.GetIni "Deadline Settings" "ChunkSize" integer 1
				SMTDSettings.LimitEnabled = LPM_Fun.GetIni "Deadline Settings" "LimitEnabled" booleanClass false
				SMTDSettings.machineLimit = LPM_Fun.GetIni "Deadline Settings" "machineLimit" integer 0
				
				SMTDSettings.OutOfOrderMethod = LPM_Fun.GetIni "Deadline Settings" "OutOfOrderMethod" string #normal
				SMTDSettings.OutOfOrderStep = LPM_Fun.GetIni "Deadline Settings" "OutOfOrderStep" integer 1
				SMTDSettings.SequentialJob = LPM_Fun.GetIni "Deadline Settings" "SequentialJob" booleanClass false
				SMTDSettings.SubmitAsSuspended = LPM_Fun.GetIni "Deadline Settings" "SubmitAsSuspended" booleanClass false
				SMTDSettings.AutoDelete = LPM_Fun.GetIni "Deadline Settings" "AutoDelete" booleanClass false
				SMTDSettings.MaxVersionToForce = LPM_Fun.GetIni "Deadline Settings" "MaxVersionToForce" string "none"
				SMTDSettings.SubmitExternalFilesMode = LPM_Fun.GetIni "Deadline Settings" "SubmitExternalFilesMode" integer 1
				SMTDSettings.ShowFrameBuffer = LPM_Fun.GetIni "Deadline Settings" "ShowFrameBuffer" booleanClass true
				--set controls to loaded state
				
				if (isValidNode $LPM_Deadline_Settings) then
				(
					localSettings = $LPM_Deadline_Settings
					SMTDSettings.PoolName = LPM_Fun.getProp localSettings "PoolName" string SMTDSettings.PoolName
					SMTDSettings.Priority = LPM_Fun.getProp localSettings "Priority" integer SMTDSettings.Priority
					SMTDSettings.ChunkSize = LPM_Fun.getProp localSettings "ChunkSize" integer SMTDSettings.ChunkSize
					SMTDSettings.LimitEnabled = LPM_Fun.getProp localSettings "LimitEnabled" booleanClass SMTDSettings.LimitEnabled
					SMTDSettings.machineLimit = LPM_Fun.getProp localSettings "machineLimit" integer SMTDSettings.machineLimit
					SMTDSettings.OutOfOrderMethod = LPM_Fun.getProp localSettings "OutOfOrderMethod" string SMTDSettings.OutOfOrderMethod
					SMTDSettings.OutOfOrderStep = LPM_Fun.getProp localSettings "OutOfOrderStep" integer SMTDSettings.OutOfOrderStep
					SMTDSettings.SequentialJob = LPM_Fun.getProp localSettings "SequentialJob" booleanClass SMTDSettings.SequentialJob
					SMTDSettings.SubmitAsSuspended = LPM_Fun.getProp localSettings "SubmitAsSuspended" booleanClass SMTDSettings.SubmitAsSuspended
					SMTDSettings.AutoDelete = LPM_Fun.getProp localSettings "AutoDelete" booleanClass SMTDSettings.AutoDelete
					SMTDSettings.MaxVersionToForce = LPM_Fun.getProp localSettings "MaxVersionToForce" string SMTDSettings.MaxVersionToForce
					SMTDSettings.SubmitExternalFilesMode = LPM_Fun.getProp localSettings "SubmitExternalFilesMode" integer SMTDSettings.SubmitExternalFilesMode
					SMTDSettings.ShowFrameBuffer = LPM_Fun.getProp localSettings "ShowFrameBuffer" booleanClass SMTDSettings.ShowFrameBuffer
				)
				
				spn_chunkSize.value = SMTDSettings.ChunkSize
				chk_limitEnabled.state = spn_machineLimit.enabled = SMTDSettings.LimitEnabled
				spn_machineLimit.value = SMTDSettings.machineLimit
				local theVal = findItem #(#normal, #nth, #NthBlock, #NthRasterRefine, #reverse, #fromBothEnds, #FromCenter, #fromBothEndsAndCenter, #random) SMTDSettings.OutOfOrderMethod 
				if theVal == 0 do theVal = 1
				ddl_outOfOrderMethod.selection = theVal
				chk_submitAsSuspended.state = SMTDSettings.SubmitAsSuspended 
				chk_autoDelete.state = SMTDSettings.AutoDelete 
				spn_outOfOrderStep.value = SMTDSettings.OutOfOrderStep
				chk_EnforceSequentialRendering.state = SMTDSettings.SequentialJob
				theVal = findItem #("none", "32bit", "64bit") SMTDSettings.MaxVersionToForce 
				if theVal == 0 do versionVal = 1
				ddl_MaxVersionToForce.selection = theVal
				ddl_SubmitExternalFilesMode.selection = 	SMTDSettings.SubmitExternalFilesMode 
				chk_showvfb.state = SMTDSettings.ShowFrameBuffer
			)


			fn saveSettings =
			(
				--store settings as last settings
				LPM_Fun.SetIni "Deadline Settings" "PoolName" SMTDSettings.PoolName
				LPM_Fun.SetIni "Deadline Settings" "Priority" SMTDSettings.Priority
				LPM_Fun.SetIni "Deadline Settings" "ChunkSize" SMTDSettings.ChunkSize
				LPM_Fun.SetIni "Deadline Settings" "LimitEnabled" SMTDSettings.LimitEnabled
				LPM_Fun.SetIni "Deadline Settings" "machineLimit" SMTDSettings.machineLimit
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderMethod" SMTDSettings.OutOfOrderMethod
				LPM_Fun.SetIni "Deadline Settings" "OutOfOrderStep" SMTDSettings.OutOfOrderStep
				LPM_Fun.SetIni "Deadline Settings" "SequentialJob" SMTDSettings.SequentialJob
				LPM_Fun.SetIni "Deadline Settings" "SubmitAsSuspended" SMTDSettings.SubmitAsSuspended
				LPM_Fun.SetIni "Deadline Settings" "AutoDelete" SMTDSettings.AutoDelete
				LPM_Fun.SetIni "Deadline Settings" "MaxVersionToForce" SMTDSettings.MaxVersionToForce
				LPM_Fun.SetIni "Deadline Settings" "SubmitExternalFilesMode" SMTDSettings.SubmitExternalFilesMode
				LPM_Fun.SetIni "Deadline Settings" "ShowFrameBuffer" SMTDSettings.ShowFrameBuffer
				--store settings in scene
				
				if (isValidNode $LPM_Deadline_Settings) then 
					localSettings = $LPM_Deadline_Settings
				else
				(
					localSettings = LPM_Fun.createNode "Deadline_Settings" "empty"
					localSettings.parent = $LPM_Root
				)
				LPM_Fun.setProp localSettings "PoolName" SMTDSettings.PoolName
				LPM_Fun.setProp localSettings "Priority" SMTDSettings.Priority
				LPM_Fun.setProp localSettings "ChunkSize" SMTDSettings.ChunkSize
				LPM_Fun.setProp localSettings "LimitEnabled" SMTDSettings.LimitEnabled
				LPM_Fun.setProp localSettings "machineLimit" SMTDSettings.machineLimit
				LPM_Fun.setProp localSettings "OutOfOrderMethod" SMTDSettings.OutOfOrderMethod
				LPM_Fun.setProp localSettings "OutOfOrderStep" SMTDSettings.OutOfOrderStep
				LPM_Fun.setProp localSettings "SequentialJob" SMTDSettings.SequentialJob
				LPM_Fun.setProp localSettings "SubmitAsSuspended" SMTDSettings.SubmitAsSuspended
				LPM_Fun.setProp localSettings "AutoDelete" SMTDSettings.AutoDelete
				LPM_Fun.setProp localSettings "MaxVersionToForce" SMTDSettings.MaxVersionToForce
				LPM_Fun.setProp localSettings "SubmitExternalFilesMode" SMTDSettings.SubmitExternalFilesMode
				LPM_Fun.setProp localSettings "ShowFrameBuffer" SMTDSettings.ShowFrameBuffer
			)

			-- FUNCTIONS from SubmitMaxToDeadline --
			fn job_priority_update val =
			(
				if val <= 100 do
				(
					theRed = (255.0 - 255.0*val/100.0)*2.0
					if theRed > 255 do theRed = 255
					theGreen = 512.0*val/100.0
					if theGreen > 255 do theGreen = 255
					sld_priority.color = [theRed, theGreen, 0]
					sld_priority.value = spn_priority.value = val
				)
				val
			)	

			fn displayPoolsList =
			(
				if SMTDSettings.PoolsSort then
				(
					local tempArray = for i in SMTDSettings.Pools collect i
					ddl_pool.items = sort tempArray 
				)	
				else
					ddl_pool.items = SMTDSettings.Pools
					
				local theIndex = findItem ddl_pool.items SMTDSettings.PoolName
				btn_submit.enabled = true
				if theIndex > 0 then 
					ddl_pool.selection = theIndex 
				else	
					ddl_pool.selection = 1
					
				if ddl_pool.selection < 2 then
				(	
					btn_submit.enabled = false
				)	
			)
			-- On open handler
			fn onOpen =
			(
				--Initialize gui
				loadSettings()
				if SMTDSettings.Pools.count == 0 do SMTDFunctions.CollectPools()
				displayPoolsList()
				itm = ddl_outOfOrderMethod.selection
				spn_outOfOrderStep.enabled = itm >= 2 AND itm <= 4
				job_priority_update SMTDSettings.Priority

			)

			--EVENT HANDLERS--
			on btnChangeRepo pressed do
			(
				::LPM_DeadlineAPI.setRepositoryLocation()

				--Check if its an invalid repository
				functionsFile=::LPM_DeadlineAPI.findSMTDFunctionsFile()
				if(functionsFile == undefined) then
				(
					messagebox "Invalid repository location."
					return false
				)

				filein functionsFile

				onOpen()
			)

			on ddl_pool selected itm do 
			(
				SMTDSettings.PoolName = ddl_pool.selected
				displayPoolsList()
			)

			on sld_priority clicked value do
			(
				SMTDSettings.Priority= (job_priority_update value)
			)
			
			on spn_priority changed value do
			(	
				SMTDSettings.Priority= (job_priority_update value)
			)

			on spn_chunkSize changed value do 
			(
				SMTDSettings.ChunkSize = value
			)	

			on chk_limitEnabled changed state do 
			(
				SMTDSettings.LimitEnabled = state
				spn_machineLimit.enabled = state 
			)	
			
			on spn_machineLimit changed value do 
			(
				SMTDSettings.machineLimit = value
			)	

			on ddl_outOfOrderMethod selected itm do
			(
				theMethod= case itm of
				(
						1: #normal
						2: #nth
						3: #NthBlock
						4: #NthRasterRefine
						5: #reverse
						6: #fromBothEnds
						7: #fromCenter
						8: #fromBothEndsAndCenter
						9: #random
				)
				SMTDSettings.OutOfOrderMethod = theMethod
				spn_outOfOrderStep.enabled = itm >= 2 AND itm <= 4
			)

			on spn_outOfOrderStep changed value do 
			(
				SMTDSettings.OutOfOrderStep = value
			)	
				
			on chk_EnforceSequentialRendering changed state do 
			(
				SMTDSettings.SequentialJob = state
			)		
				
			on chk_submitAsSuspended changed state do 
			(
				SMTDSettings.SubmitAsSuspended = state
			)	

			on chk_autoDelete changed state do 
			(
				SMTDSettings.AutoDelete = state
			)	
			
			on ddl_MaxVersionToForce selected itm do
			(
				case itm of
				(
					1: SMTDSettings.MaxVersionToForce = "none"
					2: SMTDSettings.MaxVersionToForce = "32bit"
					3: SMTDSettings.MaxVersionToForce = "64bit"
				)
			)
			
			on ddl_SubmitExternalFilesMode selected itm do
			(
				SMTDSettings.SubmitExternalFilesMode = ddl_SubmitExternalFilesMode.selection
			)
			
			on chk_showvfb changed state do 
			(
				SMTDSettings.ShowFrameBuffer = state
			)	
			
			on LPM_DeadlineSubmitRo open do
			(
				onOpen()
			)

			on LPM_DeadlineSubmitRo close do
			(
				saveSettings()
			)

			on btn_submit pressed do
			(
				saveSettings()

				prg_submitProgress.value = 0
				prg_submitProgress.visible = true
				btn_submit.visible = false
				grp_submit.text = "Submit progress"
			
				renderCollect = LPM_Fun.getWhoToRender()
				flag=true
				for i=1 to renderCollect.count where flag do
				(
					prg_submitProgress.value = (100*(i-1))/renderCollect.count
					
					--Pre render action
					LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
					thePass=renderCollect[i][1]
					theShot=renderCollect[i][2]
						
					-- prepare Deadline Job
					try(

					
						if (theShot==undefined) then 
							SMTDSettings.JobName = ("Pass: "+(LPM_Fun.getName renderCollect[i][1].name))
						else
							SMTDSettings.JobName = ("Shot: "+(LPM_Fun.getName renderCollect[i][2].name)+" Pass: "+(LPM_Fun.getName renderCollect[i][1].name))
						
						SMTDSettings.Comment = "LPM Deadline Submission"
						SMTDSettings.UserName = sysInfo.username
					)catch()
					local result = SMTDFunctions.SubmitJob()
					if result != #success do
					(
						flag = false
						messagebox ("Error while submitting to Deadline (error code: "+result+")")
					)
					-- Deadline Job prepared and submitted
					
					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
					if(keyboard.escPressed) then flag=false
				)

				try(destroydialog LPM_DeadlineSubmitRo)catch()

			)
		)
		
		try(destroyDialog LPM_RenderRo)catch()
		
		--Execute the critical deadline submission functions
		if not (executeSMTDFunctions()) then
		(
			return "Invalid Deadline Repository Root Folder.\nCould not find SubmitMaxToDeadline_Functions.ms\n(Error Code 1003)"
		)

		--Create the dialog
		createDialog LPM_DeadlineSubmitRo lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos LPM_DeadlineSubmitRo.width)

		return #SUCCESS
	)	
)

append LPM_NetworkPlugins (LPM_DeadlineAPI())