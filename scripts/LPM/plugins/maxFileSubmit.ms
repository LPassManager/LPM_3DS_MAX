struct LPM_MaxFileSubmitAPI
(
	type="MaxFile",
	fn submit=
	(
		rollout LPM_MaxFileSubmit_Ro "Max File / 3rd-Party Submit" width:300 height:420
		(
			button pickPathButton "..." pos:[13,22] width:35 height:17
			button generateMaxFilesButton "Submit" pos:[7,97] width:100 height:28
			edittext pathText "" pos:[48,22] width:244 height:17 enabled:false
			progressBar submitProgress "" pos:[111,97] width:185 height:30 visible:true
			GroupBox grp1 "Max File Directory" pos:[8,2] width:289 height:65
			button openButton "Open" pos:[13,42] width:35 height:18
			checkbox usecommandCheck "Generate Batch File" pos:[13,147] width:118 height:15 checked:LPM_Root.useCommand
			checkbox runBatchCheck "Run Batch File" pos:[13,165] width:94 height:15 checked:LPM_Root.runBatch
			dropdownList AddDDL "" pos:[13,199] width:274 height:21 items:#("=== Switches ===","-preRenderScript:\"filename\"","-postRenderScript:\"filename\"","-workPath:\"pathname\"","-pathFile:\"pathname\"","-bitmapPath:\"pathname\"","-xrefPath:\"pathname\"","-split:4,10","-strip:4,10,1","-stitch:4,10"\
			,"-dateFormat:<dateformat>","-timeFormat:<timeformat>","=== Render Parameters ===","-imageSequenceFile:2","-gammaCorrection:1","-gammaValueIn:2.2","-gammaValueOut:2.2","-continueOnError","-videopostJob:1"\
			,"=== Render Flags ===","-showRFW:1","-skipRenderedFrames:1","-videoColorCheck:1","-force2Sided:1","-renderHidden:1","-atmospherics:1","-superBlack:1","-renderFields:1","-fieldOrder:even","-displacements:1","-effects:1","-useAreaLights:1","-useAdvLight:1","-computeAdvLight:1","-ditherPaletted:1","-ditherTrueColor:1","-renderElements:1"\
			,"=== Backburner Job ===","-submit:\"manager_name\"","-port:3186","-netmask:\"255.255.255.0\"","-jobName:\"string\"","-priority:50","-suspended:1","-writeJobFile","-readJobFile:\"filename\"","-waitLoad:20","-waitRender:600","-waitUnload:10")
			edittext commandText "" pos:[9,225] width:276 height:170  
  
			button Help1Button "General Help" pos:[166,148] width:120 height:21
			button Help2Button "Render Switches Help" pos:[166,171] width:120 height:21
			groupBox grpCmdLine "Command Line" pos:[2,131] width:295 height:280		
			on AddDDL selected item do
			(
			if(commandText.text=="") then
				LPM_Root.commandLine=commandText.text=AddDDL.items[item]
			else
				LPM_Root.commandLine=commandText.text+="\n" + AddDDL.items[item]
			)
			on commandText entered text do
			(
				LPM_Root.commandLine=text
			)
			on useCommandCheck changed value do 
			(
				runBatchCheck.enabled=AddDDL.enabled=commandText.enabled=LPM_Root.useCommand=value
			)
			on runBatchCheck changed value do LPM_Root.runBatch=value
			on help1Button pressed do
			(
				shellLaunch "http://www.kxcad.net/autodesk/3ds_max/Autodesk_3ds_Max_9_Reference/command_line_rendering.html" ""
			
			)
			on help2Button pressed do
			(
				shellLaunch "http://www.kxcad.net/autodesk/3ds_max/Autodesk_3ds_Max_9_Reference/command_line_rendering_switches.html" ""
			
			)
			on LPM_MaxFileSubmit_Ro open do
			(
				if(LPM_Root.maxFileRenderRoot==undefined) then
				(	
					LPM_Root.maxFileRenderRoot=maxFilePath
					pathText.text=maxFilePath
					
				)
				else
					pathText.text=LPM_Root.maxFileRenderRoot

			)
			on pickPathButton pressed do
			(
				thePath=getSavePath caption:"Pick the pass root" initialDir:LPM_Root.rootDir
				if(thePath!=undefined) then
				(	
					LPM_Root.maxFileRenderRoot=thePath+"\\"
					pathText.text=LPM_Root.maxFileRenderRoot
				)		
			)

			on generateMaxFilesButton pressed do
			(
				submitProgress.value = 0
				submitProgress.visible = true
				
				renderCollect = LPM_Fun.getWhoToRender()
				flag=true
				print renderCollect
				for i=1 to renderCollect.count where flag do
				(
					submitProgress.value = (100*(i-1))/renderCollect.count
					
					
					LPM_Render.fnPreRenderAction renderCollect[i][1] renderCollect[i][2]
					-- prepare MaxFileJob Job --
					thePass=renderCollect[i][1]
					theShot=renderCollect[i][2]

					if(theShot==undefined) then
						theFileName=	((LPM_Fun.getname thePass.name)+"_"+maxFileName)
					else
						theFileName= ((LPM_Fun.getname theShot.name) +"_" +(LPM_Fun.getname thePass.name) +"_"+maxFileName) 
					
					for i=1 to theFileName.count do if (theFileName[i]==" ") then theFileName[i]="_"--replace spaces with _ for Deadline
					theFilename=LPM_Root.maxFileRenderRoot+theFileName
					saveMaxFile theFileName useNewFile:false quiet:true	
					
					if(LPM_Root.useCommand) then
					(
						theCommand = "\""+(getDir #maxroot)+"3dsmaxcmd.exe\" "+"\""+theFileName +"\""+ " -o " +"\""+ rendOutputFilename+" \" "
						theCommand +=LPM_Root.commandLine
					
						--remove \n's
						split=filterString theCommand "\n"
						theCommand=""
						for it in split do theCommand+=" "+it
					
						batFileName=substitutestring  theFilename ".max" ".bat"
						batFile=createFile batFileName

						if(batFile!=undefined) then
						(	
							format "%\n"theCommand to:batFile
							close batFile
						)
						else
						(
							messagebox "ERROR OCCURED CREATING BAT FILE"
						)
						

						if(LPM_Root.runBatch) then
						(
							print theCommand
							doscommand  ("\"" +batFileName+ "\"")
						)
					
					)
					
					-- MaxFileJob Job prepared and submitted
					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
					if(keyboard.escPressed) then flag=false
				)
				


				
				try(destroyDialog LPM_MaxFileSubmit_Ro)catch()
			
			)
			on openButton pressed do
			(
				shelllaunch pathText.text ""
			)
		)
		createdialog LPM_MaxFileSubmit_Ro pos:(LPM_Fun.getRoPos LPM_MaxFileSubmit_Ro.width)
		
		return #SUCCESS
	)
)

append LPM_NetworkPlugins (LPM_MaxFileSubmitAPI())