/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com


    Copyright (C) 2010  Lukas Lepicovsky LPM, 3DS Max Pass Manager

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

struct LPM_RenderAPI
(
	
	--The only two functions to be called from outside the API is
	--fnPreRenderAction thePass theShot (Store and set render settings before a pass)
	--fnPostRenderAction thePass theShot (Restore render settings after a pass)
	
	------------------------------------------------------------------------	
	--Utility Functions
	------------------------------------------------------------------------
	fn setVray filePath=
	(
		if(classof renderers.current==vray) then
		(
			if(renderers.current.output_on) then
			(
				thePath=getFilenamePath filePath
				theFile=getFilenameFile filePath
				theType=getFilenameType filePath
				if(renderers.current.output_splitgbuffer) then
				(
					--ADD CONDITIONALS CHECK FOR VRMIMG USE AND SPLIT USE< GENERATE WARNING IF VFB BUT NEITHER
					x=bitmap 10 10 filename:(thePath+thefile+"TMP"+theType)
					save x
					renderers.current.output_splitfilename=filePath
					renderers.current.output_splitbitmap=x
					deletefile (thePath+thefile+"TMP"+theType)
				)
				
				if(renderers.current.output_saveRawFile) then
					renderers.current.output_rawFileName=thePath+theFile+".vrImg"
					
				if(not renderers.current.output_splitgbuffer) and (not renderers.current.output_splitgbuffer) then
				(	
					try(
						LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
						LPM_renderProgress_Ro.warning.color=(color 135 6 6)
						)catch()
					print "Warning: Vray is set to use VFB, but neither Raw Image or Split Render Channels are active, render data may be lost."
				)
			)
		)
	),
	fn setWarning=
	(
		try(
			LPM_renderProgress_Ro.warning.text="Warnings See Log F11"
			LPM_renderProgress_Ro.warning.color=(color 135 6 6)
		)catch()
	),
	fn saveBG=
	(
		bk=#()
		bk[1]=backgroundColor
		bk[2]=useEnvironmentMap
		bk[3]=environmentMap
		bk[4]=lightTintColor
		bk[5]=lightLevel
		bk[6]=ambientColor
		bk
	),

	fn setProp it property value=
	(
		if(value==2) then
			setProperty it property on
		if(value==3) then
			setProperty it property off
	),

	fn setPropInv it property value=
	(
		if(value==3) then
			setProperty it property on
		if(value==2) then
			setProperty it property off	
	),

	fn setCommonProps item=
	(
		cp=LPM_Fun.firstChildByType item "commonProps"
		if(cp!=undefined) and (cp.initialized) and (cp.active) then
		(
			if(cp.timeOutputTgl) then
			(
				rendTimeType=cp._rendTimeType
				rendNThFrame=cp._rendNThFrame
				rendStart=cp._rendStart
				rendEnd=cp._rendEnd
				rendFileNumberBase=cp._rendFileNumberBase
				rendPickupFrames=cp._rendPickupFrames
			)
			if(cp.outputSizeTgl) then
			(
				renderHeight=cp._renderHeight
				renderWidth=cp._renderWidth
				setRendApertureWidth cp._RendApertureWidth
				renderPixelAspect=cp._renderPixelAspect
			)
			if(cp.optionsTgl) then
			(
				rendAtmosphere=cp._rendAtmosphere
				renderEffects =cp._renderEffects
				renderDisplacements=cp._renderDisplacements
				rendColorCheck=cp._rendColorCheck
				rendFieldRender=cp._rendFieldRender
				rendHidden=cp._rendHidden
				rendSimplifyAreaLights=cp._rendSimplifyAreaLights
				rendForce2Side=cp._rendForce2Side
				rendSuperBlack=cp._rendSuperBlack
			)
			if(cp.advancedLightingTgl ) then
			(
				RadiosityPreferences.useAdvancedLighting=cp._useAdvancedLighting
				RadiosityPreferences.computeAdvancedLighting	=cp._computeAdvancedLighting
			)
			if(cp.cameraTgl) then
			(
				try(viewport.setCamera cp._Camera)catch()
			)
			if(cp.renderTypeTgl) then
			(
				try(setRenderType (cp.renderType as name))catch() 
			)
			if(cp.gammaTgl) then
			(
				fileOutGamma=cp._fileOutGamma
				displayGamma=cp._fileOutGamma 
			)
			rendSaveFile=not cp.disableFinalOutput
		)
		return cp
	),
	fn getTimeDifference startTime endTime = 
	(
		fn getDayOfYear date =
		(
			local d = 0
			-- days from beginnig of year for each month
			local months = #( 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334)
			d = months[date[2]] + date[4]
			-- adjust leap year
			if ((mod date[1] 4 == 0 ) and (d>59) ) do d+=1
			return d
		)
		local timeDiff = #()
		
		-- let's face it - calculations shouldn't take this long
		timeDiff[1] = timeDiff[2] = timeDiff[3] = 0
		timeDiff[4] = (getDayOfYear endTime) - (getDayOfYear startTime)
		if (timeDiff[4] < 0) do timeDiff[4]+=365
		timeDiff[5] = endTime[5] - startTime[5]
		if (timeDiff[5] < 0) do timeDiff[5]+=24
		timeDiff[6] = endTime[6] - startTime[6]
		if (timeDiff[6] < 0) do timeDiff[6]+=60
		timeDiff[7] = endTime[7] - startTime[7]
		if (timeDiff[7] < 0) do timeDiff[7]+=60
		timeDiff[8] = endTime[8] - startTime[8]
		if (timeDiff[8] < 0) do timeDiff[8]+=1000
		return timeDiff
	),	
	fn execScriptNodes thePass moment=
	(
		for scriptNode in thePass.children where (scriptNode.type=="script") do
		(

			if (moment==#preLPM and scriptNode.preLPM) or (moment==#postLPM and scriptNode.postLPM) or (moment==#preRender and scriptNode.preRender) or (moment==#postRender and scriptNode.postRender)  then
			(
				try
				(
					execute scriptNode.script
				)
				catch
				(
					err="Pass"+thePass.name+"\n"
					err+="Script node "+scriptNode.name+"\n"
					err+="Failed to execute\n"
					err+=(getcurrentException() as string)
					messagebox err
				)
			)
			
		)
	),
	------------------------------------------------------------------------	
	--BACKUP INFORMATION
	------------------------------------------------------------------------	
	commonSettings,
	objBackup,
	lightBackup,
	applyAtmosphericsBackup,
	elementBackup,
	effectBackup,
	atmBackup,
	envBackup,
	exposureBackup,
	xrefBackArray,
	preRenderSettings,
	viewportCamBack,
	viewportTypeBack,
	
	fn fnPreRenderAction thePass theShot isPreviewMode:false=
	(
		--clear all backup variables
		commonSettings=objBackup=lightBackup=applyAtmosphericsBackup=elementBackup=atmBackup=envBackup=xrefBackArray=preRenderSettings=viewportCamBack=viewportTypeBack=undefined
		with redraw off
		(
			with animate off
			(
				LPM_Render.execScriptNodes thePass #preLPM
				
				preProcTime=timeStamp()
					
				--Save current common properties
				----------------------------------------------------------------------------------------------
				commonSettings=#()
				commonSettings[1]=rendTimeType
				commonSettings[2]=rendNThFrame
				commonSettings[3]=rendStart
				commonSettings[4]=rendEnd
				commonSettings[5]=rendFileNumberBase 
				commonSettings[6]=rendPickupFrames
				commonSettings[7]=renderHeight
				commonSettings[8]=renderWidth
				commonSettings[9]=getRendApertureWidth()
				commonSettings[10]=renderPixelAspect
				commonSettings[11]=rendAtmosphere
				commonSettings[12]=renderEffects 
				commonSettings[13]=renderDisplacements
				commonSettings[14]=rendColorCheck
				commonSettings[15]=rendFieldRender
				commonSettings[16]=rendHidden
				commonSettings[17]=rendSimplifyAreaLights
				commonSettings[18]=rendForce2Side
				commonSettings[19]=rendSuperBlack
				commonSettings[20]=RadiosityPreferences.useAdvancedLighting
				commonSettings[21]=RadiosityPreferences.computeAdvancedLighting
				commonSettings[22]=rendSaveFile
				commonSettings[23]=rendOutputFileName
				commonSettings[24]=skipRenderedFrames
				commonSettings[25]=rendUseNet
				
				if(getRenderType!=undefined) then
					commonSettings[26]=getRenderType()
				commonSettings[27]=fileOutGamma
				commonSettings[28]=displayGamma
				--backup active viewport
				viewportTypeBack=viewport.getType()
				viewportCamBack=viewport.getcamera()
				
				--set camera
				if(isvalidNode LPM_Root.renderCamera) then
					viewport.setCamera LPM_Root.renderCamera
				
				--Set common properties
				----------------------------------------------------------------------------------------------		
							
				rendSaveFile=true
				cp = (setCommonProps thePass)

				if(theShot!=undefined) then
					cp = (setCommonProps theShot)
								
				--Save current renderer settings
				-------------------------------------------------------------------------------------------------
				preRenderSettings=undefined
				
				--Load current renderer settings
				-------------------------------------------------------------------------------------------------		
				theRenderProps=for it in thePass.children where ((it.type=="renderProps") and (it.initialized) and (it.active)) collect it
				if( theRenderProps[1]!=undefined) then
				(
					preRenderSettings=LPM_Fun.saveRenderPreset()
					--preRenderSettings=renderers.current
					LPM_Fun.loadRenderPreset theRenderProps[1].props
				)
				
				--backup object sets/set properties
				-------------------------------------------------------------------------------------------------
			
				objBackup=for it in objects where ((superclassof it)!=light) collect
				(
					if(iskindof it PF_Source) then
						#(it, it.Enable_particles)
					else
					(	
						#(it,it.renderable,it.castshadows,it.receiveshadows,it.primaryVisibility,it.secondaryVisibility,it.motionBlurOn,it.renderOccluded,it.material,it.ishidden,getuserPropBuffer it)
					)
				)

				lightBackup=for it in objects where ((superclassof it)==light) collect
				(
					tmp=#(it)
					try(tmp[2]=it.on)catch()
					try(tmp[3]=it.baseObject.castShadows)catch()
					try(tmp[4]=it.color)catch()
					try(tmp[5]=it.enabled)catch()
					tmp
				)
				--change to the default mode of the pass,
				if(thePass.hideMode>1) then
				(
					val=true
					if(thePass.hideMode==3) then val=false
					
					for it in objects where ((superclassof it)!=light) do it.ishidden = val
					for it in lights where ((superclassof it)==light) do(try(it.enabled=(not val))catch(); try(it.on=(not val))catch() )				
				)
				
				--Render Switcher
				--First check if we want to use render switcher
				--Then switch the materials
				useRenderSwitcher=false
				for mat in scenematerials where (iskindof mat LPM_RenderSwitcher) do useRenderSwitcher=true;
				
				if(useRenderSwitcher) then
				(
					--remove render switcher from the ui
					for it in objects where (iskindof it.material LPM_RenderSwitcher) do
					(
						
						theRenderer=(classof renderers.current) as string
						useMat=it.material.fallBackInt
						
						if(findstring theRenderer "Scanline"!=undefined) then
							useMat=1
						else if (findstring theRenderer "Mental"!=undefined) then			
							useMat=2
						else if (findString theRenderer "V_Ray" !=undefined) then	
							useMat=3
						
						case useMat of
						(
							1: it.material=it.material.scanlineMat
							2: it.material=it.material.mentalRayMat
							3: it.material=it.material.vrayMat
							default: it.material=it.material.scanlineMat
							
						)
					)
					for i=1 to 24 where (iskindof meditmaterials[i] LPM_RenderSwitcher) do meditmaterials[i]=standardmaterial();
				)
				
				--set objects
				-------------------------------------------------------------------------------------------------	
				objNodes=#()
				objSetArray=#()	
				LPM_Fun.getObjectSetArrays thePass "objectSet" &objNodes &objSetArray
				
				--Backup Apply Atmospherics
				--Apply atmospherics are only backed up when needed, this is due to the fact that then take 1000x longer than anything else to backup....
				applyAtmosphericsFlag=false
				for it in objSetArray do
				(
					if (it.intP[7]!= 1) then
						applyAtmosphericsFlag=true
				)
				
				applyAtmosphericsBackup=#()
				if(applyAtmosphericsFlag) then
					applyAtmosphericsBackup=for it in $objects collect #(it, it.applyAtmospherics)
				-----------------------------------------------------------------------------------------------------------------------------------------
					
				hitNodes=#()
				for k=1 to objNodes.count do
				(
					i=objNodes.count+1-k
					for it in objNodes[i] where ((finditem hitNodes it)  ==0) do
					(
						append hitNodes it
						--pFlow Base
						if(iskindof it PF_Source) then
						(
							if(objSetArray[i].intP[1]==2) then
								it.Enable_Particles=True
							else if(objSetArray[i].intp[1]==3) then
								it.Enable_Particles=False
						)
						else--other stuff
						(
							setProp it #renderable objSetArray[i].intP[1]
							setPropInv it #ishidden objSetArray[i].intP[1]
							setProp it #castshadows objSetArray[i].intP[2]
							setProp it #receiveshadows objSetArray[i].intP[3]
							setProp it #primaryVisibility objSetArray[i].intP[4]
							setProp it #secondaryVisibility objSetArray[i].intP[5]
							setProp it #motionBlurOn  objSetArray[i].intP[6]
							setProp it #applyAtmospherics objSetArray[i].intP[7]
							setProp it #renderOccluded objSetArray[i].intP[8]
							--user props
							if(objSetArray[i].intP[9]==2) then
							(
								setUserPropBuffer it (objSetArray[i].userProp)
							)
							if objSetArray[i].pMatEnable then
								it.material=objSetArray[i].pMaterial
							)
					)
				)
		
				--set Lights
				-------------------------------------------------------------------------------------------------			
				lightNodes=#()
				lightSetArray=#()
				LPM_Fun.getObjectSetArrays thePass "lightSet" &lightNodes &lightSetArray
		
				hitNodes=#()
				for k=1 to lightNodes.count do
				(
					i=lightNodes.count+1-k
					--hide
					for it in lightNodes[i] where ((finditem hitNodes it)==0) do
					(
						append hitNodes it
						--hide
						try(setProp it #on lightSetArray[i].pEnable)catch()
						try(setProp it #enabled lightSetArray[i].pEnable)catch()
						try(setProp it.baseObject #castShadows lightSetArray[i].pCastShadows)catch()
						if lightSetArray[i].pColorEnable then
							try(it.color=lightSetArray[i].pColor)catch()
						
					)
				)
				--Generic Nodes
				genericNodes=for child in thePass.children where child.type=="generic" do
				(
					op=LPM_Operators.fngetByNode child
					if(op!=0) then
						op.fnPerformAction #preRender
				)
				
				
				
				--Backup/Set Elements effects atmospherics enviroments
				-------------------------------------------------------------------------------------------------
				elementBackup=#()
				effectBackup=#()
				atmBackup=#()
				envBackup=#()
				exposureBackup=SceneExposureControl.exposureControl
				
				--element backup
				-------------------------------------------------------------------------------------------------
				--Elements must always be backed up because using exposure control changes the number of elements
				re = maxOps.GetCurRenderElementMgr()
				for i=1 to re.NumRenderElements() do
				(
					
					theEle=re.GetRenderElement (i-1)

					useVray=hasProperty theEle #vrayVFB
					if(useVray==false) then
						elementBackup[i]=#(theEle.enabled,re.GetRenderElementFilename (i-1))
					else
						elementBackup[i]=#(theEle.vrayVFB,re.GetRenderElementFilename (i-1))
					if(isPreviewMode) then
						re.SetRenderElementFilename (i-1) ""
					else
						re.SetRenderElementFilename (i-1) (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot elementName:theEle.elementname )
				)

				ep=LPM_Fun.firstChildByType thePass "envProps"
				if(ep!=undefined) and (ep.initialized) and (ep.active) then
				(
					--elements backup
					-------------------------------------------------------------------------------------------------
					if(ep.elementOverride) then
					(
						
						for i=1 to re.NumRenderElements() do
						(
							theEle=re.GetRenderElement (i-1)
							useVray=hasProperty theEle #vrayVFB
							
							if((findItem ep.activeElement theEle.elementName)!=0) then
							(
								if(useVray==false) then
									theEle.enabled=true
								else
									theEle.vrayVFB=true
							)
							else
							(	
								if(useVray==false) then
									theEle.enabled=false
								else
									theEle.vrayVFB=false
							)
						)
					)
					--effectbackUP
					-------------------------------------------------------------------------------------------------
					if(ep.effectOverride) then
					(
							for i=1 to numEffects do
							(
								theEffect=getEffect i
								effectBackup[i]=IsActive theEffect
								if((findItem ep.activeEffect theEffect.name)!=0) then
									setActive theEffect true
								else
									setActive theEffect false
							)
					)	
					--AtmbackUp
					-------------------------------------------------------------------------------------------------
					if(ep.atmOverride) then
					(
		
							for i=1 to numAtmospherics  do
							(
								theAtm=getAtmospheric i
								atmBackup[i]=IsActive theAtm
								if((findItem ep.activeAtm theAtm.name)!=0) then
									setActive theAtm true
								else
									setActive theAtm false
							)
					)
					--Envbackup
					-------------------------------------------------------------------------------------------------
					if(ep.backgroundOverride) then
					(
						envBackup=saveBG()
						backgroundColor=ep.bgColor
						environmentMap=ep.envMap
						useEnvironmentMap=ep.useEnvMap
						lightTintColor=ep.tint
						lightLevel=ep.level
						ambientColor=ep.ambient
					)
					if(ep.exposureOverride) then
					(
						case ep.exposureInt of
						(
							1: SceneExposureControl.exposureControl=undefined
							2: SceneExposureControl.exposureControl=Automatic_Exposure_Control()
							3: SceneExposureControl.exposureControl=Linear_Exposure_Control()
							4: SceneExposureControl.exposureControl=Logarithmic_Exposure_Control() 
							5: SceneExposureControl.exposureControl=mr_Photographic_Exposure_Control()
							6: SceneExposureControl.exposureControl=Pseudo_Color_Exposure_Control()
						)
					)
				)
				
				xrefBackArray=#()
				xrefSceneProps=LPM_Fun.firstChildByType thePass "xrefScene"
				if(isvalidnode xrefSceneProps) then
				(
					--backup the settings
					for i=1 to xrefs.getXRefFileCount() do 
					(xrefBackArray[i] = (xrefs.getXRefFile i).disabled)
					
					--set the scenes
					for i=1 to xrefs.getXRefFileCount() do
					(
						theXref=(xrefs.getXRefFile i)
						if((findItem xrefSceneProps.fileNames theXref.fileName)!=0) then
							theXref.disabled=false
						else
							theXref.disabled=true
					)
				)

				--Prescript
				-------------------------------------------------------------------------------------------------
				psCP=LPM_fun.firstChildByType  thePass "commonProps"
				if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active) then
				(
					global LPMData = #(thePass,theShot)
					try(fileIn psCp.preScript)catch(getcurrentException())
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType theShot "commonProps" 
					if(psCP!=undefined) and (psCp.usePreScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						try(fileIn psCp.preScript)catch(getcurrentException())
					)
				)
				
				rendOutputFilename=LPM_Fun.getPassPath LPM_Root thePass theShot:theShot elementName:"Beauty"
				setVray rendOutputFilename	
				rendUseNet=false
				
				LPM_Render.execScriptNodes thePass #preRender
				
				format "Pre Processing took: % s\n" ((timeStamp() - preProcTime)/1000.0)
				
			)
		)

	),
	--RESTORE
	fn fnPostRenderAction thePass theShot=
	(
		with redraw off
		(
			with animate off
			(
				LPM_Render.execScriptNodes thePass #postRender
				--Post script
				-------------------------------------------------------------------------------------------------
				psCP=LPM_fun.firstChildByType thePass "commonProps" 
				if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
				(
					global LPMData = #(thePass,theShot)
					try(fileIn psCp.postScript)catch(getcurrentException())
				)
				if(theShot!=undefined) then
				(
					psCP=LPM_fun.firstChildByType  theShot "commonProps"
					if(psCP!=undefined) and (psCp.usePostScript) and (psCP.active)  then
					(
						global LPMData = #(thePass,theShot)
						try(fileIn psCp.postScript)catch(getcurrentException())
					)
				)
				
					
				--restore objects/ light sets
				-------------------------------------------------------------------------------------------------
				for it in objBackup do
				(
					theNode=it[1]
					
					if(iskindof theNode PF_Source) then
					(
						theNode.Enable_Particles=it[2]
					)
					else
					(
						theNode.renderable=it[2]
						theNode.castshadows=it[3]
						theNode.receiveshadows=it[4]
						theNode.primaryVisibility=it[5]
						theNode.secondaryVisibility=it[6]
						theNode.motionBlurOn=it[7]
						theNode.renderOccluded=it[8]
						theNode.material=it[9]
						theNode.isHidden=it[10]
						setUserPropBuffer theNode it[11]
					)
				)
		
				for it in lightBackup do
				(
					theNode=it[1]
					try(theNode.on=it[2])catch()
					try(theNode.baseObject.castShadows=it[3])catch()
					try(theNode.color=it[4])catch()
					try(theNode.enabled=it[5])catch()
				)
				
				--Generic Nodes
				genericNodes=for child in thePass.children where child.type=="generic" do
				(
					op=LPM_Operators.fngetByNode child
					if(op!=0) then
						op.fnPerformAction #postRender
				)
				
				--applyAtmospherics restore
				for it in applyAtmosphericsBackup do
				(
					theNode=it[1]
					theNode.applyAtmospherics=it[2]
				)
				
				
				--exposure restore
				-------------------------------------------------------------------------------------------------
				SceneExposureControl.exposureControl=exposureBackup		
				re = maxOps.GetCurRenderElementMgr()
				for i=1 to re.NumRenderElements() do
				(
					theEle=re.GetRenderElement (i-1)
					if(hasProperty theEle #vrayVFB) then
						theEle.vrayVFB=elementBackup[i][1]
					else
						theEle.enabled=elementBackup[i][1]
					if(elementBackUp[i][2]!=undefined) then
						re.SetRenderElementFilename (i-1) elementBackup[i][2] 
				)
		
				ep=LPM_Fun.firstChildByType thePass "envProps"
				if(ep!=undefined) and (ep.initialized) and (ep.active) then
				(
					--effect Restore
					-------------------------------------------------------------------------------------------------
					if(ep.effectOverride) then
					(
							for i=1 to numEffects do
							(
								theEffect=getEffect i
								setActive theEffect effectBackup[i]
							)
					)	
		
					--Atm Restore
					-------------------------------------------------------------------------------------------------
					if(ep.atmOverride) then
					(
							for i=1 to numAtmospherics  do
							(
								theAtm=getAtmospheric i
								setActive theAtm atmBackup[i]
							)
						
					)
					if(ep.backgroundOverride) then
					(
						backgroundColor=envBackup[1]
						useEnvironmentMap=envBackup[2]
						environmentMap=envBackup[3]
						lightTintColor=envBackup[4]
						lightLevel=envBackup[5]
						ambientColor=envBackup[6]
					)
						
				)
				--xref scenes restore
				if(isvalidnode xrefSceneProps) then
				(
					--backup the settings
					for i=1 to xrefBackArray.count do
					(
						 (xrefs.getXRefFile i).disabled=xrefBackArray[i]					
					)
				)
				
				--restore render settings
				-------------------------------------------------------------------------------------------------
				if(preRenderSettings!=undefined) then
				(	
					LPM_Fun.loadRenderPreset preRenderSettings
					--renderers.current=preRenderSettings
				)
				--restore common settings
				-------------------------------------------------------------------------------------------------
				rendTimeType=commonSettings[1]
				rendNThFrame=commonSettings[2]
				rendStart=commonSettings[3]
				rendEnd=commonSettings[4]
				rendFileNumberBase=commonSettings[5]
				rendPickupFrames=commonSettings[6]
				renderHeight=commonSettings[7]
				renderWidth=commonSettings[8]
				setRendApertureWidth commonSettings[9]
				renderPixelAspect=commonSettings[10]
				rendAtmosphere=commonSettings[11]
				renderEffects=commonSettings[12]
				renderDisplacements=commonSettings[13]
				rendColorCheck=commonSettings[14]
				rendFieldRender=commonSettings[15]
				rendHidden=commonSettings[16]
				rendSimplifyAreaLights=commonSettings[17]
				rendForce2Side=commonSettings[18]
				rendSuperBlack=commonSettings[19]
				RadiosityPreferences.useAdvancedLighting=commonSettings[20]
				RadiosityPreferences.computeAdvancedLighting=commonSettings[21]
				rendSaveFile=commonSettings[22]
				rendOutputFileName=commonSettings[23]
				skipRenderedFrames=commonSettings[24]
				rendUseNet=commonSettings[25]
				if(setRenderType!=undefined) then
					setRenderType commonSettings[26]
				fileOutGamma	=commonSettings[27]
				displayGamma=commonSettings[28]
				--restore viewport
				if(viewPortCamBack!=undefined) then
					viewport.setCamera viewportCamBack
				else
					viewport.setType viewportTypeBack
				
				LPM_Render.execScriptNodes thePass #postLPM
			)
		)
	)
)

fn LPM_hardwareRender thePass theShot:undefined=
(
	--create the floater
	LPM_Fun.init_LPM_renderProgress_Ro thePass theShot
	LPM_treeview_rollout.hideByPass thePass
	
	
	thePath=LPM_Fun.getPassPath LPM_Root thePass theShot:theShot elementName:"Beauty"

	theType=LPM_Fun.uppercase(LPM_Root.fileType)

	_renderHeight=renderHeight
	_renderWidth=renderWidth
	_rendTimeType=rendTimeType
	_rendNThFrame=rendNThFrame
	_rendStart=rendStart
	_rendEnd=rendEnd
	_rendFileNumberBase=rendFileNumberBase
	_rendPickupFrames=rendPickupFrames

	flagContinue=true

	if(isvalidNode LPM_Root.renderCamera) then
		viewport.setCamera LPM_Root.renderCamera

	--for the pass
	cp=LPM_Fun.firstChildByType thePass "commonProps"
	if(cp!=undefined) and (cp.initialized) then
	(
		if(cp.timeOutputTgl) then
		(
			_rendTimeType=cp._rendTimeType
			_rendNThFrame=cp._rendNThFrame
			_rendStart=cp._rendStart
			_rendEnd=cp._rendEnd
			_rendFileNumberBase=cp._rendFileNumberBase
			_rendPickupFrames=cp._rendPickupFrames
		)
		if(cp.outputSizeTgl) then
		(
			_renderHeight=cp._renderHeight
			_renderWidth=cp._renderWidth
		)
		if(cp.cameraTgl) then
		(
			try(viewport.setCamera cp._Camera)catch()
		)
	)
	
	--for the shot
	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.initialized) then
		(
			if(cp.timeOutputTgl) then
			(
				_rendTimeType=cp._rendTimeType
				_rendNThFrame=cp._rendNThFrame
				_rendStart=cp._rendStart
				_rendEnd=cp._rendEnd
				_rendFileNumberBase=cp._rendFileNumberBase
				_rendPickupFrames=cp._rendPickupFrames
			)
			if(cp.outputSizeTgl) then
			(
				_renderHeight=cp._renderHeight
				_renderWidth=cp._renderWidth
			)
			if(cp.cameraTgl) then
			(
				try(viewport.setCamera cp._Camera)catch()
			)
		)
	)
	
	timesArray=#()
	case _rendTimeType of
	(
		1:
		(
			timesArray[1]=sliderTime 
		)
		2:
		(
			timesArray=for i=animationRange.start to animationRange.end  by _rendNThFrame collect i
		)
		3:
		(
			timesArray=for i=_rendStart to _rendEnd by _rendNthFrame collect i
		)
		4:
		(
			tmpArray=LPM_Fun.stringToFrames _rendPickupFrames
			if(tmpArray==undefined) then
				flagContinue=false
			else
			(

				for it in tmpArray do
				(
					if(it.count ==1) then
						append timesArray (it[1] as time)
					else
						timesArray=timesArray + (for i=it[1] to it[2] collect (i as time))											
				)
			)
		)
	)

	if(flagContinue==false) then
		Messagebox ((LPM_Fun.getname thePass.name) + " has an incorrectly formatted frame sequence")
	else
	(
		safeFrameBack=displaySafeFrames
		displaySafeFrames=false
		startTime=amin timesArray
		endTime= amax timesArray
		if(startTime < endTime) then
			animationRange= (interval startTime endTime)
		
		
		movieMode=false
		theType=LPM_Fun.upperCase theType
		if(theType=="MOV") or (theType=="AVI") then
			movieMode=true
		
		flag=true
		if(theShot!=undefined) then
			progressStart ("S:" +(LPM_fun.getName theShot.name) + " P: "+(LPM_fun.getName thePass.name)) 
		else
			progressStart ("P: "+(LPM_fun.getName thePass.name)) 
		
				
		if(movieMode) then -- Movie mode
		(
			b = bitmap _renderWidth _renderHeight filename:thePath
			for i=1 to timesArray.count where flag do --loop though renderFrames
			(
				it=timesArray[i]
				progressUpdate (((i as float) / (timesArray.count as float)) *100.0)
				sliderTime=it
				dib = gw.getViewportDib()
				copy dib b
				save b
				if(keyboard.escpressed) then flag=false
				if(getProgressCancel()) then flag=false
				
			)
			close b
		)
		else --Sequence Mode
		(
			for i=1 to timesArray.count where flag do --loop though renderFrames
			(
				it=timesArray[i]
				progressUpdate (((i as float) / (timesArray.count as float)) *100.0)
				
				b = bitmap _renderWidth _renderHeight filename:thePath

				sliderTime=it
				dib = gw.getViewportDib()
				 copy dib b
				b.filename = (getFilenamePath thePath) +(getFilenameFile thePath)+(LPM_Fun.convertTimeToString it _rendFileNumberBase)+(getFilenametype thePath)
				save b
				close b
				b=undefined
				if(mod i 100)==0.0 then --clear the memory every 50 frames
					gc light:true
				if(keyboard.escpressed) then flag=false
				if(getProgressCancel()) then flag=false
			)
		)

		progressEnd()
		gc light:true
		
		displaySafeFrames=safeFrameBack
	)
	try (destroydialog LPM_renderProgress_Ro ) catch()
)
LPM_Render=LPM_RenderAPI()


fn LPM_renderPass thePass renderType theShot:undefined=
(
	if( maxOps.GetCurRenderElementMgr()==undefined) then
		messagebox "Please disable active shade and enable production renderer"
	else
	(
		renderscenedialog.close()
		
		-- let's use getLocalTime if available (since 2008 or with AVG)
		if ( classOf getLocalTime == MAXScriptFunction ) then
			startTime = getLocalTime()
		else 
			startTime = timeStamp()
		
		LPM_Fun.init_LPM_renderProgress_Ro thePass theShot
		if(isvalidnode theShot) then 
			format "===== S:% P:% =====\n"  (LPM_Fun.getName theShot.name) (LPM_Fun.getname thePass.name)
		else format "===== P:% =====\n" (LPM_Fun.getname thePass.name)
	
		--Pre render action
		isPreviewMode=((renderType==#preview)or(renderType==#previewHalf))
		LPM_Render.fnPreRenderAction thePass theShot isPreviewMode:isPreviewMode
	
		--Set settings based on render type
		-------------------------------------------------------------------------------------------------
		
		if(isPreviewMode) then
		(
			rendOutputFilename=LPM_Fun.getPreviewFile thePass
			LPM_Render.setVray rendOutputFilename
			makeDir ((getDir #preview)+"\\"+maxFileName+"_"+"\\") all:true
			deleteFile rendOutputFilename

			rendTimeType=1
			rendUseNet=false
			
			if(renderType==#previewHalf) then
			(
				renderHeight=(renderHeight * (LPM_Root.previewSize as float) /100.0) 
				renderWidth=(renderWidth * (LPM_Root.previewSize as float) / 100.0)
			)
		)

		if(renderType==#local) then
		(
			SetQuietMode LPM_Root.quietMode
		)
		
		--And go!!
		with defaultAction #logmsg
		(
			max quick render
		)
		
		SetQuietMode false
		
		LPM_Render.fnPostRenderAction thePass theShot
	
		if ( classOf getLocalTime == MAXScriptFunction ) then
		(
			endTime = getLocalTime()
			timeDifference = (getTimeDifference startTime endTime)
			hours = timeDifference[4]*24 + timeDifference[5]
			mins = timeDifference[6]
			secs = timeDifference[7]
		) else (
			endTime = timeStamp()
			secs=((endTime - startTime) / 1000.0)
			mins=(secs / 60) as integer
			hours = (secs / 3600) as integer
			secs=mod secs 60
		)
		
	if(isvalidnode theShot) then
	(
		if (hours > 0) then
			format "RenderTime: % Hours % Mins Shot:% Pass:% type:% \n"  hours mins (LPM_Fun.getName theShot.name) (LPM_Fun.getName thePass.name) (renderType as string)
		else
			format "RenderTime: % Mins % Secs Shot:% Pass:% type:% \n"  mins secs (LPM_Fun.getName theShot.name) (LPM_Fun.getName thePass.name) (renderType as string)
	) else (
		if (hours > 0) then
			format "RenderTime: % Hours % Mins Pass:% type:%\n" hours mins (LPM_Fun.getName thePass.name)(renderType as string)
		else
			format "RenderTime: % Mins % Secs Pass:% type:%\n" mins secs (LPM_Fun.getName thePass.name)(renderType as string)
	)
	
	try(destroyDialog LPM_renderProgress_Ro)catch()
	
		--update the compositor and the last 10 renders
		if(renderType==#preview or renderType==#previewHalf) then
		(	if(LPM_Compositor!=undefined) then
				if(LPM_Compositor.open) then
					LPM_Compositor.refresh()
			makedir ((getDir #preview)+"\\"+maxFileName+"_"+"\\Revisions\\")
			
			y=copy localtime
			for i=1 to y.count where y[i]=="/" or y[i]==":" or y[i]==" " do y[i]="_"
			renderFile=LPM_Fun.getPreviewFile thePass;
			newFile=(getfilenamepath renderFile+"Revisions\\")+(getfilenameFile renderFile )+y+(getfilenametype renderFile)
			try(copyfile renderFile newFile)catch();
		)			
	)
)

