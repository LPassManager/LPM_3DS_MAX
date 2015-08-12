struct LPM_EnFuzionSubmitAPI
(	
	--Copy this file to C:\Program Files\Autodesk\3ds Max 2009\ui\macroscripts\LPM\plugins
	type="EnFuzion",
	fn submit=
	(
		rollout LPM_EnFuzionSubmit_Ro "EnFuzion Submit" width:300 height:130
		(
			button pickPathButton "..." pos:[13,22] width:35 height:17
			button generateMaxFilesButton "Submit" pos:[7,97] width:100 height:28
			edittext pathText "" pos:[48,22] width:244 height:17 enabled:false
			progressBar submitProgress "" pos:[111,97] width:185 height:30 visible:true
			GroupBox grp1 "Max File Directory" pos:[8,2] width:289 height:65
			button openButton "Open" pos:[13,42] width:35 height:18

			on LPM_EnFuzionSubmit_Ro open do
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
				--start here
		      firstFrame = (animationRange.start as integer)/TicksPerFrame
		      lastFrame = (animationRange.end as integer)/TicksPerFrame
			if (rendTimeType == 1) then (
    		firstFrameNum = (sliderTime as integer)/TicksPerFrame
			lastFrameNum = firstFrameNum
			step = 1
		) else if (rendTimeType == 2) then (
			firstFrameNum = (animationRange.start as integer)/TicksPerFrame
			lastFrameNum = (animationRange.end as integer)/TicksPerFrame
			step = rendNThFrame
		) else if (rendTimeType == 3) then (
			firstFrameNum = (rendStart as integer)/TicksPerFrame
			lastFrameNum = (rendEnd as integer)/TicksPerFrame
			step = rendNThFrame
		) else if (rendTimeType == 4) then (
			-- this type is not yet supported, use the range instead
			firstFrameNum = (rendStart as integer)/TicksPerFrame
			lastFrameNum = (rendEnd as integer)/TicksPerFrame
			step = rendNThFrame
		)	
				
				--end here
				flag=true
				renderCollect = LPM_Fun.getWhoToRender()

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
					--start here
					  infoName = theFileName + "_enf.xml"
					  f = openFile infoName mode:"w"
     				  format "<Job>\n" to: f
					  format "  <JobInfo>\n" to: f
					  format "    <Name>%</Name>\n" theFileName to: f
					  format "  </JobInfo>\n" to: f
					  format "  <JobDetails>\n" to: f
					  format "    <D3dsMaxData>\n" to: f
					  format "      <MaxJob>\n" to: f
					  format "        <FirstFrame>%</FirstFrame>\n" firstFrame to: f
					  format "        <LastFrame>%</LastFrame>\n" lastFrame to: f
					  format "        <Step>%</Step>\n" step to: f
					  format "      </MaxJob>\n" to: f
					  format "      <Outputs>\n" to: f
					  format "        <Output>\n" to: f
					  format "          <Name>%</Name>\n" rendOutputFilename to: f
					  format "        </Output>\n" to: f
					  format "      </Outputs>\n" to: f
					  format "    </D3dsMaxData>\n" to: f
					  format "  </JobDetails>\n" to: f
					  format "</Job>\n" to: f
					  close f
					  params = "-file \"" + theFileName + "\""
					  ShellLaunch "C:\\enfuzion\\bin\\enfuzion3d.exe" params
					--end here
					
					-- MaxFileJob Job prepared and submitted
					LPM_Render.fnPostRenderAction renderCollect[i][1] renderCollect[i][2]
					if(keyboard.escPressed) then flag=false
				)
				


				
				try(destroyDialog LPM_EnFuzionSubmit_Ro)catch()
			
			)
			on openButton pressed do
			(
				shelllaunch pathText.text ""
			)
		)
		createdialog LPM_EnFuzionSubmit_Ro pos:(LPM_Fun.getRoPos LPM_EnFuzionSubmit_Ro.width)
		
		return #SUCCESS
	)
)

append LPM_NetworkPlugins (LPM_EnFuzionSubmitAPI())