/*
Deadline job submission written by Lukas Lepicovsky
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/

struct LPM_RenderPalAPI
(
	type="RenderPal",
	
	fn submit=
	(
		rollout LPM_RenderPalSubmitRo "RenderPal" width:320 height:612
		(
			GroupBox grp_pool "Pool and Priority" pos:[6,136] width:304 height:253
			label lbl_pool "Pools:" pos:[12,173] width:24 height:13
			dotNetControl lvPools "System.Windows.Forms.ListView" pos:[47,174] width:258 height:207
			label lbl_priority "Priority:" pos:[12,154] width:34 height:13
			spinner spn_priority "" pos:[254,153] width:47 height:16 range:[0,10,5] type:#integer fieldwidth:35
			
			GroupBox grp_job "Job Options" pos:[6,398] width:304 height:156
			label lbl_chunk "Render Task Chunk Size (Frames Per Task):" pos:[12,418] width:211 height:13
			spinner spn_chunkSize "" pos:[254,418] width:47 height:16 range:[1,1000,1] type:#integer fieldwidth:35
			checkbox chk_cacheScenes "Cache Scenes Locally On Clients" pos:[12,484] width:263 height:16
			checkbox chk_limitEnabled "Limit No. of Machines Rendering Concurrently  " pos:[12,438] width:246 height:15
			spinner spn_machineLimit "" pos:[254,438] width:47 height:16 range:[1,1000,1] type:#integer fieldwidth:35

			dropdownList ddl_OutOfOrderMethod "" pos:[12,458] width:200 height:21 items:#("Forward", "Backwards", "Evenly Distributed", "Random")
			
			checkbox chk_submitAsSuspended "Submit Job As Suspended" pos:[12,502] width:148 height:15

			label lbl_MaxVersionToForce "Force 3ds Max Build:" pos:[12,527] width:99 height:13
			dropdownList ddl_MaxVersionToForce "" pos:[130,523] width:80 height:21 items:#("none", "32bit", "64bit")
			
			GroupBox grp_submit "Submit" pos:[6,558] width:307 height:50
			button btn_submit "Submit" pos:[13,575] width:135 height:27
			progressBar prg_submitProgress "" pos:[13,575] width:290 height:27 visible:false
			
			GroupBox grpServer "Configuration" pos:[5,3] width:305 height:90
			edittext edt_ServerIP "" pos:[216,35] width:88 height:16
			label lbl5 "Server IP Address" pos:[13,36] width:89 height:16
			label lbl6 "Submission Dir" pos:[14,55] width:73 height:16
			edittext edt_SubmissionDir "" pos:[84,54] width:188 height:16 readOnly:true
			button btn_PickSubmissionDir "..." pos:[274,55] width:32 height:18
			button btn_OpenSubmissionDir "Open" pos:[274,75] width:32 height:15
			label lbl25 "RenderPal Installation Dir" pos:[13,18] width:131 height:16
			edittext edt_InstallationDir "" pos:[148,16] width:119 height:16 readOnly:true
			button btn_PickInstallationDir "..." pos:[272,14] width:32 height:18
			GroupBox grpRenderer "Renderer" pos:[5,92] width:302 height:40
			dropdownList ddl_Renderer "" pos:[69,106] width:235 height:21
			label lbl26 "Renderer:" pos:[11,110] width:48 height:13
	
			--ASSUMING THIS IS AT THE STANDARD LOCATION
			local cmdPath=""
			local cmdExe="RpRcCmd.exe"
			
			fn listPools serverIp=
			(
				cmd = cmdExe
				tempFile=(getdir #temp)+"\\pool.txt"
				cmd+= " -server \""+serverIP+"\""
				cmd += " -listpools -compact > \""+tempFile+"\""
				local result = 1
				hiddendoscommand cmd startPath:cmdPath donotwait:false ExitCode:&result
				
				if(result != 0) then
					return undefined
				
				f = openfile tempFile
				pools = #()
				while not (eof f) do
				(
					pool=readline f
					pool=trimright pool "\r\n"
					if(pool != "") then
						append pools pool
				)
				
				close f
				
				return pools
			)
			
			fn listRenderers serverIp=
			(
				cmd = cmdExe
				tempFile=(getdir #temp)+"\\renderers.txt"
				cmd+= " -server \""+serverIP+"\""
				cmd += " -listrenderers -compact > \""+tempFile+"\""
				
				local result = 1
				hiddendoscommand cmd startPath:cmdPath donotwait:false ExitCode:&result
				
				if(result != 0) then
					return undefined
				
				f = openfile tempFile
				rends = #()
				while not (eof f) do
				(
					rend=readline f
					rend=trimright rend "\r\n"
					if(matchpattern rend pattern:"3ds max*") then
						append rends rend
				)
				close f
				
				return rends
			)
			
			fn loadSettings =
			(
				btn_Submit.enabled=false
				
				--Load settings
				edt_InstallationDir.text = LPM_FUN.GetIni "RenderPal Settings" "InstallationDir" string "C:\\Program Files (x86)\\RenderPal V2\\"
				serverIp = LPM_FUN.GetIni "RenderPal Settings" "ServerIP" string "127.0.0.1"
				edt_submissionDir.text= LPM_FUN.GetIni "RenderPal Settings" "SubmissionDir" string ""
				poolName = LPM_Fun.GetIni "RenderPal Settings" "PoolName" string ""
				rendererName = LPM_Fun.GetIni "RenderPal Settings" "RendererName" string ""
				RenderPriority = LPM_Fun.GetIni "RenderPal Settings" "Priority" integer 5
				ChunkSize = LPM_Fun.GetIni "RenderPal Settings" "ChunkSize" integer 1
				CacheScenes = LPM_Fun.GetIni "RenderPal Settings" "CacheScenes" booleanClass true
				LimitEnabled = LPM_Fun.GetIni "RenderPal Settings" "LimitEnabled" booleanClass false
				machineLimit = LPM_Fun.GetIni "RenderPal Settings" "machineLimit" integer 0
				OutOfOrderMethod =  LPM_Fun.GetIni "RenderPal Settings" "OutOfOrderMethod" integer 1
				SubmitAsSuspended = LPM_Fun.GetIni "RenderPal Settings" "SubmitAsSuspended" booleanClass false
				MaxVersionToForce = LPM_Fun.GetIni "RenderPal Settings" "MaxVersionToForce" integer 1

				--set controls to loaded state
				
				if (isValidNode $LPM_Renderpal_Settings) then
				(
					localSettings = $LPM_Renderpal_Settings
					PoolName = LPM_Fun.getProp localSettings "PoolName" string PoolName
					RendererName = LPM_Fun.getProp localSettings "RendererName" string RendererName
					RenderPriority = LPM_Fun.getProp localSettings "Priority" integer RenderPriority
					ChunkSize = LPM_Fun.getProp localSettings "ChunkSize" integer ChunkSize
					CacheScenes = LPM_Fun.getProp localSettings "CacheScenes" booleanClass CacheScenes
					LimitEnabled = LPM_Fun.getProp localSettings "LimitEnabled" booleanClass LimitEnabled
					machineLimit = LPM_Fun.getProp localSettings "machineLimit" integer machineLimit
					OutOfOrderMethod = LPM_Fun.getProp localSettings "OutOfOrderMethod" integer OutOfOrderMethod
					SubmitAsSuspended = LPM_Fun.getProp localSettings "SubmitAsSuspended" booleanClass SubmitAsSuspended
					MaxVersionToForce = LPM_Fun.getProp localSettings "MaxVersionToForce" integer MaxVersionToForce
				)

				--Check for a valid installation
				cmdPath = edt_InstallationDir.text + "CmdRc\\"
				exe = cmdPath + cmdExe
				if(not doesfileexist exe) then
				(
					messagebox ("Couldnt find " + exe +"\nPlease check RenderPal Installation Dir")
					return false
				)
				
				--Server IP
				edt_ServerIP.text=serverIP
				
				--Query pools
				poolItems = listPools serverIp
				if(poolItems == undefined) then
				(
					messagebox ("Couldnt query pools, please check the server ip")
					return false	
				)
				if(poolItems.count == 0) then
				(
					messagebox ("Couldnt find any pools please check the pool configuration")
					return false	
				)
				
				rows=#()
				checkedPools = filterstring poolName ";"
				for poolItem in poolItems do
				(
					li=dotNetObject "System.Windows.Forms.ListViewItem" poolItem
					if (findItem checkedPools poolItem) > 0 then
						li.checked = true
					append rows li	
				)
				
				lvPools.items.addRange rows

				--:Query Renderers
				rendererItems=listRenderers serverIp
				if(rendererItems == undefined) then
				(
					messagebox ("Couldnt query renderers, please check the server ip")
					return false	
				)
				
				if(rendererItems.count == 0) then
				(
					messagebox ("Couldnt find any renders named starting with 3ds Max, please check the renderer configuration")
					return false		
				)
				
				ddl_renderer.items=rendererItems
				index=finditem ddl_renderer.items rendererName
				if index > 0 then 
					ddl_renderer.selection = index 

				--Check the submission dir
				if(not doesfileexist edt_submissionDir.text) then
				(
					messagebox ("Submission dir does not exist, please choose a valid directory.\nAll render nodes should have access to this directory.")
					return false	
				)
				
				--Gui Stuff
				spn_priority.value=RenderPriority
				spn_chunkSize.value = ChunkSize
				chk_cacheScenes.state = cacheScenes
				chk_limitEnabled.state = spn_machineLimit.enabled = LimitEnabled
				spn_machineLimit.value = machineLimit
				ddl_OutOfOrderMethod.selection = OutOfOrderMethod
				chk_SubmitAsSuspended.checked=SubmitAsSuspended
				ddl_MaxVersionToForce.selection=MaxVersionToForce
				btn_Submit.enabled=true
			)
			
			fn getPoolName = 
			(
				poolName = ""
				for i=0 to (lvPools.items.count - 1) do
				(
					item =  lvPools.items.item[i]
					if item.checked then
						poolName += item.text + ";"
				)
				
				poolName = trimright poolName ";"		
			)
			
			fn saveSettings =
			(
				poolName = getPoolName()
				
				--store settings as last settings
				LPM_Fun.SetIni "RenderPal Settings" "ServerIP" edt_ServerIP.text
				LPM_Fun.SetIni "RenderPal Settings" "InstallationDir" edt_InstallationDir.text
				LPM_Fun.SetIni "RenderPal Settings" "SubmissionDir" edt_SubmissionDir.text
				LPM_Fun.SetIni "RenderPal Settings" "PoolName" poolName
				LPM_Fun.SetIni "RenderPal Settings" "RendererName" ddl_Renderer.selected
				LPM_Fun.SetIni "RenderPal Settings" "Priority" spn_priority.value
				LPM_Fun.SetIni "RenderPal Settings" "ChunkSize" spn_chunkSize.value
				LPM_Fun.SetIni "RenderPal Settings" "CacheScenes" chk_cacheScenes.state
				LPM_Fun.SetIni "RenderPal Settings" "LimitEnabled" chk_limitEnabled.state
				LPM_Fun.SetIni "RenderPal Settings" "machineLimit" spn_machineLimit.value
				LPM_Fun.SetIni "RenderPal Settings" "OutOfOrderMethod" ddl_OutOfOrderMethod.selection
				LPM_Fun.SetIni "RenderPal Settings" "SubmitAsSuspended" chk_SubmitAsSuspended.checked
				LPM_Fun.SetIni "RenderPal Settings" "MaxVersionToForce" ddl_MaxVersionToForce.selection
				--store settings in scene
				
				if (isValidNode $LPM_Renderpal_Settings) then 
					localSettings = $LPM_Renderpal_Settings
				else
				(
					localSettings = LPM_Fun.createNode "Renderpal_Settings" "empty"
					localSettings.parent = $LPM_Root
				)
				LPM_Fun.setProp localSettings "PoolName" poolName
				LPM_Fun.setProp localSettings "RendererName" ddl_Renderer.selected
				LPM_Fun.setProp localSettings "Priority" spn_priority.value
				LPM_Fun.setProp localSettings "ChunkSize" spn_chunkSize.value
				LPM_Fun.setProp localSettings "CacheScenes" chk_CacheScenes.state
				LPM_Fun.setProp localSettings "LimitEnabled" chk_limitEnabled.state
				LPM_Fun.setProp localSettings "machineLimit" spn_machineLimit.value
				LPM_Fun.setProp localSettings "OutOfOrderMethod" ddl_OutOfOrderMethod.selection
				LPM_Fun.setProp localSettings "SubmitAsSuspended" chk_SubmitAsSuspended.checked
				LPM_Fun.setProp localSettings "MaxVersionToForce" ddl_MaxVersionToForce.selection
				
			)
			fn initializeListView lv =
			(
				lv.hideSelection = false
				lv.fullRowSelect = true
				lv.checkboxes = true
				lv.View = (dotNetClass "System.Windows.Forms.View").Details
				lv.Columns.add "Pool Name" lv.width
			)

			on LPM_RenderPalSubmitRo open do
			(
				initializeListView lvPools
				loadSettings()
			)

			on LPM_RenderPalSubmitRo close do
			(
				saveSettings()
			)
	
			on edt_ServerIp entered text do
			(
				saveSettings()
				loadSettings()
			)
						
			on chk_limitEnabled changed state do
				spn_machineLimit.enabled=state
			
			on btn_pickSubmissionDir pressed do
			(
				thePath=getSavePath caption:"Pick the pass root" initialDir:(::LPM_Root.rootDir)
				if(thePath!=undefined) then
				(	
					edt_SubmissionDir.text=thePath+"\\"
					saveSettings()
					loadSettings()
				)		
			)
			
			on btn_pickInstallationDir pressed do
			(
				thePath=getSavePath caption:"Pick the pass root" initialDir:"C:\\Program Files (x86)\\RenderPal V2\\"
				if(thePath!=undefined) then
				(	
					edt_InstallationDir.text=thePath+"\\"
					saveSettings()
					loadSettings()
				)		
			)
			
			on btn_OpenSubmissionDir pressed do
				shelllaunch edt_SubmissionDir.text ""
			
			
			fn makeSubmissionDir root jobName=
			(
				unTime=getUniversalTime()
				str=unTime[1] as string
				if(unTime[2] < 10) then
					str+="_0"+unTime[2] as string
				else
					str+="_"+unTime[2] as string
				
				if(unTime[4] < 10) then
					str+="_0"+unTime[4] as string
				else
					str+="_"+unTime[4] as string
				
				dir=Root+str+"\\"

				dir+=jobName+"_"
				num=1000
				while doesfileexist (dir+num as string) do
					num+=1
				
				dir+=(num as string) +"\\"
				
				print dir
				makedir dir all:true
				return dir
			)
			
			fn frameListStr=
			(
				case rendTimeType of
				(
					1:(return (((slidertime /ticksperframe) as integer) as string))
					2:(return ((((animationRange.start /ticksperframe) as integer) as string) + "-"+(((animationRange.end /ticksperframe) as integer) as string)))
					3:(return ((((rendstart /ticksperframe) as integer) as string) + "-"+(((rendend /ticksperframe) as integer) as string)))
					4:(return rendPickupFrames )
				)
			)
			
			fn makeBatFile jobDir jobName sceneName =
			(
				batFileName=jobDir+"Submit.bat"
				batFile = createfile batFileName
				
				str="\""+cmdPath + cmdExe+"\""
				str+=" -server \"" +edt_ServerIp.text+"\""
				str+=" -nj_name \""+jobName+"\""
				str+=" -nj_pools \""+(getPoolName())+"\""
				str+=" -nj_renderer \""+ddl_renderer.selected+"\""
				str+=" -nj_priority \""+spn_priority.value as string+"\""
				str+=" -nj_splitmode \"2," +spn_chunkSize.value as string+"\""
				
				if(chk_cacheScenes.state) then
					str+= " -nj_cachescenes"
				
				if(chk_limitEnabled.state) then
					str+=" -nj_clientlimit \""+spn_machineLimit.value as string+"\""
				str+=" -nj_dispatchorder \""+ (ddl_OutOfOrderMethod.selection - 1) as string+"\""
				if(chk_SubmitAsSuspended.checked) then
					str+=" -nj_paused"
				if(ddl_MaxVersionToForce.selection == 2) then
					str+=" -nj_render32bit"
				if(ddl_MaxVersionToForce.selection == 3) then
					str+=" -nj_render64bit"
					
				str+=" -outdir \""+(getfilenamepath rendOutputFilename)+"\""
				str+=" -frames \""+(frameListStr())+"\""
				str+=" \""+sceneName+"\""				
				str+=" > error.txt"
				format str to:batFile
				close batFile
				
				--Execute the bat file
				local result = 1
				hiddendoscommand ("\""+batFileName+"\"") startPath:jobDir donotwait:false ExitCode:&result
				if(result != 0) then
				(
					str="Error code: "+(result as string)+"\n"
					if (doesfileexist (jobDir+"error.txt")) then
					(

						f=openfile (jobDir+"error.txt")
						while not(eof f) do
							str+=readline f+"\n"
						close f
					)
					messagebox str
				)
				
				return result
			)
			
			on btn_submit pressed do
			(
				if lvPools.checkedItems.count == 0 then
				(
					messagebox "Please choose at least one pool"
					return false
				)
				
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
					jobName=""
					if (theShot==undefined) then 
						JobName = ("Pass_"+(LPM_Fun.getName renderCollect[i][1].name))
					else
						JobName = ("Shot_"+(LPM_Fun.getName renderCollect[i][2].name)+"_Pass_"+(LPM_Fun.getName renderCollect[i][1].name))
						
					Comment = "LPM Submission"
					UserName = sysInfo.username
					
					--Make the job dir
					jobDir=makeSubmissionDir edt_submissionDir.text jobName
					
					--Scene file
					sceneName= (jobDir+jobName+".max")
					savemaxfile sceneName useNewFile:false
					
					--make the bat file
					result=makeBatFile jobDir jobName sceneName
					if(result != 0) then
					(
						flag=false
					)
					
					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
					if(keyboard.escPressed) then flag=false
				)

				try(destroydialog LPM_RenderPalSubmitRo)catch()

			)
		)
		
		try(destroyDialog LPM_RenderRo)catch()
		

		--Create the dialog
		createDialog LPM_RenderPalSubmitRo lockHeight:false lockWidth:true style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos LPM_RenderPalSubmitRo.width)

		return #SUCCESS
	)	
)

append LPM_NetworkPlugins (LPM_RenderPalAPI())