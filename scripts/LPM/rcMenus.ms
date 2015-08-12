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

--RC MENU
--Contains menus and menu functions

global LPM_oldRenderSettings
global LPM_renderer_closed


--renderer closed callback
fn LPM_renderer_closed = 
( 
	callbacks.RemoveScripts #tabbedDialogDeleted id:#myscript_update
	LPM_treeview_rollout.tv.selectedNode.tag.value.props=LPM_Fun.saveRenderPreset()
	LPM_treeview_rollout.tv.selectedNode.tag.value.initialized=true
	LPM_treeview_rollout.tv.enabled=true	
	theRenderer=(classof renderers.current) as string
	theNode=LPM_treeview_rollout.tv.selectedNode
	if(theNode.text=="Render Override") or (theNode.text=="Scanline") or (theNode.text=="Mental Ray") or (theNode.text=="VRay") then
	(
		if(findstring theRenderer "Scanline"!=undefined) then
		(	
			theNode.text="Scanline"
			theNode.tag.value.name="LPM_"+"Scanline"
		
		)	
		else if (findstring theRenderer "Mental"!=undefined) then
		(
			theNode.text="Mental Ray"
			theNode.tag.value.name="LPM_"+"Mental Ray"
		)
		else if (findString theRenderer "V_Ray" !=undefined) then
		(
			theNode.text="VRay"
			theNode.tag.value.name="LPM_"+"Vray"
		)
	)
	
	
	LPM_Fun.loadRenderPreset LPM_oldRenderSettings
)

--about menu
rollout AboutRO "About LPM" width:265 height:178
(
	button bmp1 "" pos:[6,8] width:250 height:100 images:#(::LPM_DIR+"icons\\LPM\\lpm.jpg", undefined, 1, 1, 1, 1, 1)
	HyperLink lbl1 "www.Lukashi.com" address:"http://www.lukashi.com" pos:[73,145] width:113 height:15 
	label lbl2 "Lukashi@Gmail.com" pos:[74,161] width:113 height:15
	label lbl3 "L Pass Manager by Lukas Lepicovsky" pos:[37,112] width:186 height:15
	label lbl4 "Copyright 2008, All rights reserved." pos:[46,129] width:186 height:16
	on bmp1 pressed do
	(
		shellLaunch "http://www.lukashi.com/LPM.php" ""
	)
)






--Main drop down menu
rcMenu rc_MainMenu
(
	local scenePath=(getdir #maxroot)+"Scenes\\"
	
	subMenu		"Render"
	(
		menuItem	renderDialog	"Render Dialog"
		seperator Sep1
		menuItem	openRenderDir	"Open Render Dir"
		menuItem	openMaxDir	"Open Max File Dir" enabled:(maxfilepath!="")
		menuItem	openPreviewDir	"Open Preview Dir"
		seperator Sep32
		menuItem previewAllActivePasses "Preview All Passes"
	)
	subMenu		"Tools"
	(
		menuItem quickScripts "Quick Scripts >"
		seperator adfsafds		
		menuItem compositorMenu "Compositor" enabled:((maxVersion())[1] >= 11000)
		seperator asd

		menuItem	mergePreset	"Merge Preset"
		menuItem	savePreset	"Save Preset"
		seperator sep3
		menuItem    passPerLight "Pass Per Light"
		menuItem    passPerLayer "Pass Per Layer"
		menuItem    shotPerCamera "Shot Per Camera"
		seperator sep5
		menuItem newLayerFromSelection "New Layer From Selection"
	)
	subMenu "Settings"
	(
		menuItem settingsMenu "Settings"
		
	)
	subMenu		"?"
	(
		menuItem	helpMenu	"Help..."
		menuItem hotkeyMenu "Hotkeys..."
		menuItem bugReport "Report a Problem..."
		menuItem featureRequest "Request a Feature..."
		
		menuItem	AboutMenu	"About"
	)
	
	on quickScripts picked do
	(
		LPM_Fun.quickScripts()
		
	)
	on hotkeyMenu picked do
	(
		rollout helpRollout "Hotkeys" width:249 height:416
		(

			groupBox grp1 "Hotkeys" pos:[4,7] width:240 height:403
			label lbl6 "MMB +" pos:[15,29] width:59 height:18
			label lbl7 "Pass    Object Set    LightSet  Node          Layer       Group           Wildcard     Named Set" pos:[82,31] width:59 height:107
			label lbl8 "= Hide all except         picked item." pos:[140,29] width:92 height:41
			label lbl9 "Ctrl + MMB +" pos:[15,148] width:66 height:18
			label lbl10 "Object Set    LightSet  Node          Layer       Group           Wildcard     Named Set" pos:[84,148] width:59 height:107
			label lbl11 "= Unhide picked        item." pos:[141,148] width:92 height:41
			groupBox grp3 "" pos:[11,20] width:224 height:120
			groupBox grp4 "" pos:[11,138] width:225 height:105
			groupBox grp5 "" pos:[11,240] width:226 height:102
			label lbl12 "MMB +            Shot" pos:[15,250] width:128 height:18
			label lbl13 "- Set viewport to shot camera.           - Set time range to shot time range.     - Select  shot camera." pos:[143,247] width:92 height:89
			label lbl14 "=" pos:[129,250] width:9 height:14
			groupBox grp6 "" pos:[10,343] width:226 height:30
			label lbl15 "MMB +            Empty Space     =    Unhide All" pos:[14,353] width:217 height:18
			groupBox grp8 "" pos:[9,375] width:226 height:30
			label lbl16 "F2 =   Rename Picked Item" pos:[13,385] width:217 height:18
		)
		createDialog helpRollout pos:(LPM_Fun.getROPos helpRollout.width)
	)
	
	on bugReport picked do
	(
		shellLaunch "http://www.lukashi.com/ForumInstall/viewforum.php?f=4" ""
	)
	on featureRequest picked do
	(
		shellLaunch "http://www.lukashi.com/ForumInstall/viewforum.php?f=6" ""
	)
	on openRenderDir picked do
	(
		shellLaunch LPM_Root.rootDir ""
	)
	on openPreviewDir picked do
	(
		shellLaunch ((getDir #preview)+"\\"+maxfilename+"_\\") ""
	)
	on openMaxDir picked do
	(
		shellLaunch (getFileNamePath maxFilePath) ""
	)
	
	
	on previewAllActivePasses picked do
	(
		LPM_Fun.whoToRender=LPM_Fun.collectPasses()
		LPM_Fun.renderSubmit #preview
	)
	on donateMenu picked do
	(
		shellLaunch "http://www.lukashi.com/LPM.php" ""
	)
	
	on helpMenu picked do
	(
		shellLaunch "http://www.lukashi.com/LPM.php" ""
	)
	--open compositor texture
	on compositorMenu picked do
	(
			if LPM_Root.compositorTexture==undefined then
				(	
					LPM_Root.compositorTexture=CompositeTextureMap()
				)
				
				try(destroyDialog LPM_Compositor) catch()
				global LPM_compositor 
				
				rollout LPM_Compositor "Quick Compositor" width:(193+renderwidth) height:(renderheight)
				(
					
					dotNetControl layerLV "System.Windows.Forms.ListView" pos:[5,64]  width:190 height:190
					dropdownList blendModeDDL "" pos:[68,289] width:119 height:21 items:#("Normal", "Average", "Addition", "Subtract", "Darken", "Multiply", "Color Burn", "Linear Burn", "Lighten", "Screen", "Color Dodge", "Linear Dodge", "Spotlight", "Spotlight Blend", "Overlay", "Soft Light", "Hard Light", "Pin Light", "Hard Mix", "Difference", "Exclusion", "Hue", "Saturation", "Color", "Value")

					colorPicker tintColorPkr "" pos:[64,330] width:43 height:15 color:[1,1,1,1] modal:false
					spinner multiplierSpn "" pos:[9,328] width:54 height:16
					spinner opacitySpn "" pos:[10,290] width:53 height:16
					label lbl1 "Opacity       Blendmode" pos:[11,275] width:175 height:12
					label lbl2 "Multiplier     Color" pos:[12,311] width:173 height:14
					GroupBox grp2 "Editing" pos:[3,261] width:188 height:93
					button addButton "Add" pos:[10,18] width:33 height:18
					dropdownList imagesDDL "" pos:[7,39] width:116 height:21 
					spinner qualitySpr "" pos:[79,18] width:43 height:16 range:[1,100,100]
					button remButton "Rem" pos:[46,18] width:33 height:18
					button saveButton "Save" pos:[126,18] width:33 height:18
					GroupBox grp4 "Passes" pos:[4,2] width:187 height:257
					button viewImageWin "View" pos:[124,38] width:61 height:21
					button bmp1 "Press to Refresh" pos:[193,0] width:renderwidth height:renderHeight 
					
					local map
					local activeIndex
					local loaded=false
					local rendMap
					local files
					

					fn getSubs it = 
					(
						subs=#()
						for i=1 to it.numSubs do 
						(
							subs[subs.count+1]=it[i]
							join subs (getSubs it[i])
						)
						subs
					)
					
					fn reloadImages=
					(
						--check for new images
						files = getFiles ((getdir #preview)+"\\" + maxfilename+"_\\"+"*")
						imagesDDL.items=for it in files collect (getFilenameFile it)+(getFilenameType it)
						if(imagesDDL.items.count==0) then
						(
							viewImageWin.enabled=false
						)
						else
						(
							viewImageWin.enabled=true
							imagesDDL.selection=1
						)	
						--reload the bitmaps
						comp=LPM_Root.compositorTexture
						bmText=getSubs comp
						for it in bmText where iskindof it.value bitmapTexture do it.reload()
						
						
					)
					
					fn initListView lv =
					(
						local iconPath=::LPM_DIR + "icons\\LPM\\serversStatus.bmp"

						lv.hideSelection = false
						lv.fullRowSelect = true
						lv.ownerDraw = false
						lv.multiselect=false
						lv.Columns.add "+" 20
						lv.Columns.add "Layer" 160
						lv.AllowDrop = true -- allow DragandDrop
						lv.View = (dotNetClass "System.Windows.Forms.View").Details

						lv.checkboxes = true

					)
					fn redrawLayers=
					(
						loaded=false
						layerLV.items.clear()
						for i=1 to map.mapList.count do
						(
							li = layerLV.Items.add "-" 
							li.subitems.add map.layerName[map.mapList.count - i+1]
							li.checked=map.mapEnabled[map.mapList.count - i+1]
						)
						loaded=true
					)
					fn setItemState state=
					(
						blendmodeDDl.enabled=state
						opacitySpn.enabled=state
						tintColorPkr.enabled=state
						multiplierSpn.enabled=state
						lbl1.enabled=state
						lbl2.enabled=state
						grp2.enabled=state
					)
					
					
					fn setEditting index=
					(
						setItemState true
						
						activeIndex=index
						grp2.text="Editing: "+map.layerName[index]
						blendmodeDDl.selection= map.blendmode[index]+1
						opacitySpn.value=map.opacity[index]
						if(iskindof map.mapList[index] rgbMult) then
						(
							it=map.mapList[index]
						try(tintColorPkr.color=it.color2
							multiplierSpn.value=it.map1.output.rgb_level)catch()
						)
						else
						(
							lbl2.enabled=false
							tintColorPkr.enabled=false
							multiplierSpn.enabled=false				
						)
					)
					fn refresh=
					(			
						rendMap=bitmap (renderWidth*qualitySpr.value/100.0 as integer) (renderHeight*qualitySpr.value/100.0 as integer) gamma:displayGamma
						
						(rendermap LPM_Root.compositorTexture size:[renderwidth,renderheight] into:rendMap)
						
						bmp1.images=#(rendMap, undefined, 1, 1, 1, 1, 1)
						gc()
						
					)
					on LPM_Compositor open do
					(
						map=LPM_Root.compositorTexture
						initListView  layerLV
						redrawLayers()
						setItemState false
						loaded=true
						reloadImages()
						refresh()
					)
					on saveButton pressed do
					(
						fileName=getBitmapSaveFileName ()
						
						if(fileName!=undefined) then
						(
							rendMap.fileName=fileName
							save rendMap
						)
						
					)
					on layerLV mouseUp lvArg Arg do
					(
				
						if(layerLV.selectedItems.count > 0) then
							setEditting (map.mapList.count - layerLV.SelectedItems.Item[0].index)
						else
						(
							setItemState false
						)
					)
					on layerLV ItemCheck theItem do
					(
						theValue=theItem.NewValue.value__==1
						
						map.mapEnabled[map.mapList.count - theItem.index]=theValue
						if(loaded) then
						refresh()
					)
					on blendModeDDL selected item do
					(
						map.blendmode[activeIndex]=item-1
						refresh()
					)
					
					on viewImageWin pressed do
					(
						shellLaunch files[imagesDDL.selection] ""
					)
					
					on tintColorPkr changed value do
					(
						
						it=map.mapList[activeIndex]
						try(
							it.color2=value
					
						)
						catch(messageBox "Map is rgb mult")
						refresh()
					)
					on multiplierSpn changed value do
					(
						it=map.mapList[activeIndex]
						try(it.map1.output.rgb_level=value)catch(messageBox "Map1 is not a rgbMult")
						refresh()
					)
					on opacitySpn changed value do
					(
						map.opacity[activeIndex]=value
						refresh()
					)
					on addButton pressed do
					(
						theBM=(selectBitMap())
						if(theBM!=undefined) then
						(	it=map.mapList[map.mapList.count+1]=rgbmult map1:(bitmapTexture bitmap:theBM)
							map.layerName[map.mapList.count]=getfilenamefile (it.map1.filename)
							redrawLayers()
							refresh()
						)
					)
					on imagesDDL selected item do
					(
							it=map.mapList[map.mapList.count+1]=rgbmult map1:(bitmapTexture filename:files[item])
							map.layerName[map.mapList.count]=getfilenamefile (it.map1.filename)
							redrawLayers()
							refresh()
					)
					on remButton pressed do
					(
						if(layerLV.selectedItems.count > 0) then
						(	
							if(map.mapList.count==1) then
								messagebox "Cannot delete the last layer"
							else
							(
								theIndex=(map.mapList.count - layerLV.SelectedItems.Item[0].index)
								map.delete theIndex
								redrawLayers()
								refresh()
							)
						)
					)
					on bmp1 pressed do
						refresh()
					
					---DRAG AND DROP----------------

					  -- local viariables in the rollout
					 local DragNode, DropNode
					 local m=dotNetClass "System.Windows.Forms.DragDropEffects" -- Drag and drop effects
					 

					 -- DRAG AND DROP HANDLERS --
					 
					 -- START Drag and Drop
					 on layerLV ItemDrag arg do
					 (
						 dragnode=arg.item
						layerLV.doDragDrop arg.item m.Move -- this actually starts the drag and drop process

					 )

					 
					 -- INSIDE Drag and Drop
					 on layerLV DragOver arg do
					 (
						 pos=layerLV.PointToClient layerLV.MousePosition -- this gave me a hard time to find out !
			
						 TestNode= layerLV.GetItemAt pos.x pos.y
						 okToDrop=false

						if (testNode != undefined) and (dragNode!=undefined) then -- OK to Drop
						(
							okToDrop=true
							
						)
						
						 if(okToDrop) then
							 arg.Effect=arg.AllowedEffect
						 else
							 arg.Effect=m.none
						 
					 )
					 
					 
					 -- END Drag and Drop (drop the item)
					 on  layerLV DragDrop arg do
					 (
						 pos=layerLV.PointToClient layerLV.MousePosition
						 DropNode=layerLV.GetItemAt pos.x pos.y
						 if(dragNode!= dropNode) then 
						 (
							index1=map.maplist.count - dragNode.Index
							index2=map.maplist.count - dropNode.Index
							
							temp=map.mapList[index1]
							map.mapList[index1]=map.mapList[index2]
							map.mapList[index2]=temp
							
							temp=map.layerName[index1]
							map.layerName[index1]=map.layerName[index2]
							map.layerName[index2]=temp
							
							temp=map.opacity[index1]
							map.opacity[index1]=map.opacity[index2]
							map.opacity[index2]=temp
							
							temp=map.blendmode[index1]
							map.blendmode[index1]=map.blendmode[index2]
							map.blendmode[index2]=temp
							
							temp=map.mapenabled[index1]
							map.mapenabled[index1]=map.mapenabled[index2]
							map.mapenabled[index2]=temp
							redrawlayers()
						 ) 
					)
					
					
				)
				createDialog LPM_Compositor pos:(LPM_Fun.getROPos LPM_compositor.width)


	)
	--create a pass per light
	on passPerLight picked do
	(
		rollout lightPicker "Pick The Lights" height:260 width:185
		(
			button okButton "Go!" pos:[2,0] width:100
			multiListBox LightsMLB height:55 width:180 pos:[0,22]
			local theLights
			
			
			on lightPicker open do
			(
				theLights=for it in $lights where (superclassof it==light) collect it
				LightsMLB.items=for it in theLights collect it.name
			)
			
			on lightPicker resized theSize do
			(
				lightsMLB.width=theSize.x
			)
			
			on okButton pressed do
			(
				for i=1 to theLights.count where LightsMLB.selection[i] do
				(
					it=theLights[i]
					if(isvalidnode it) then
					(
						--create the pass
						thePass=LPM_Fun.createPass LPM_Root
						thePass.name="LPM_"+it.name

						
						--create the off lightSet
						theSet=LPM_Fun.createLightSet "All Off"
						theSet.parent=thePass
						theSet.pEnable=3
						theSet.wildCard[1]="*"
						
						--create the on lightSet
						theSet=LPM_Fun.createLightSet it.name
						theSet.parent=thePass
						theSet.pEnable=2
						theSet.nodes[1]=it
						
						--create the objectSet
						theSet=LPM_Fun.createObjectSet "All Objects"
						theSet.parent=thePass	
						theSet.wildCard[1]="*"
						theSet.intP[1]=1
					)
				)
				LPM_treeview_rollout.updateTV()
				destroyDialog lightPicker
			)
			
		)

		createDialog lightPicker lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos  lightPicker.width)

	)
	--create a pass per layer
	on passPerLayer picked do
	(
		
		
		lMan=layerManager
		
		for i=0 to (lMan.count-1) do
		(
			theLayer=lMan.getLayer i
			if(theLayer.name!="zz-LPM") then
			(
				--create the pass
				thePass=LPM_Fun.createPass LPM_Root
				thePass.name="LPM_"+theLayer.name
				
				--create the off lightSet
				theSet=LPM_Fun.createLightSet "All Lights"
				theSet.parent=thePass
				theSet.wildCard[1]="*"
				
				--create the objectSet
				theSet=LPM_Fun.createObjectSet "All Off"
				theSet.parent=thePass
				theSet.wildCard[1]="*"
				theSet.intp[1]=3
				
				--create the objectSet
				theSet=LPM_Fun.createObjectSet theLayer.name
				theSet.parent=thePass
				theSet.layers[1]=theLayer.name
				theSet.intp[1]=2
			)
			
		)
		LPM_treeview_rollout.updateTV()	

	)
	
	on shotPerCamera picked do
	(
		rollout cameraPicker "Pick The Cameras" height:260 width:185
		(
			button okButton "Go!" pos:[2,0] width:100
			multiListBox cameraMLB height:55 width:180 pos:[0,22]
			local theCameras
			
			
			on cameraPicker open do
			(
				theCameras=for cam in $cameras where superclassof cam==camera collect cam
				CameraMLB.items=for it in theCameras collect it.name
			)
			
			on CameraPicker resized theSize do
			(
				CameraMLB.width=theSize.x
			)
			
			on okButton pressed do
			(
				for i=1 to theCameras.count where cameraMLB.selection[i] do
				(
					cam=theCameras[i]
					if(isvalidnode cam) then
					(
						theShot=LPM_Fun.createShot LPM_Root
						theShot.name="LPM_"+cam.name
						theCp=LPM_Fun.firstChildByType theShot "commonProps"
						theCp.cameraTgl=true
						theCp._camera=cam
						theCp.timeOutputTgl=true
						theCp._rendTimeType=3

					)

				)
				LPM_treeview_rollout.updateTV()
				destroyDialog cameraPicker
			
			)
		)
		createDialog cameraPicker lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos  cameraPicker.width)

	)

	on aboutMenu picked do
	(
		createDialog AboutRo pos:(LPM_Fun.getRoPos AboutRo.width)
	)
	
	on renderDialog picked do
	(

		rollout LPM_RenderRo "Render Dialog" width:351 height:500
		(
			GroupBox grp4 "Naming Parameters" pos:[2,5] width:342 height:133
			edittext rootText "" pos:[22,25] width:270 height:17
			button pickRootBtn "..." pos:[294,26] width:20 height:19
			button openRootBtn "open" pos:[315,26] width:27 height:19
			GroupBox grp5 "Render" pos:[3,225] width:341 height:66
			button localBtn "Local" pos:[182,242] width:77 height:21
			button netBtn "Network" pos:[262,241] width:77 height:22
			edittext typeText "" pos:[48,46] width:48 height:20 enabled:true readOnly:true	
			button pickFileTypeButton "Pick" pos:[98,47] width:40 height:20
			button openCommonDialog "Open Render Dialog" pos:[14,164] width:132 height:24
			label lbl1 "Dir" pos:[7,27] width:16 height:22
			label lbl2 "Filetype" pos:[9,48] width:40 height:20
			label lbl3 "Path" pos:[10,71] width:40 height:20
			checkbox quietChk "Suppress Warnings" pos:[183,266] width:114 height:20
			dropdownList cameraDDL "" pos:[65,196] width:160 height:21
			label lbl11 "Camera" pos:[18,198] width:43 height:19
			GroupBox grp7 "Default Render Settings" pos:[2,146] width:342 height:77
			dropdownList renderType "" pos:[9,242] width:170 height:21 items:#("Passes", "Pass Hardware Preview", "Shots", "Shots Hardware Preview")
			label lbl10 "####.ext" pos:[287,74] width:50 height:16
			edittext customPath "" pos:[48,69] width:235 height:17
			dropdownList previewDDL "" pos:[52,113] width:290 height:21 items:#("File Path Preview")
			dropdownList symbolDDL "" pos:[52,89] width:118 height:21 items:#("Symbols", "\ = Directory", "$Cam = Camera", "$Max = Max Filename", "$Pass = Pass Name", "$Shot = Shot Name", "$Element=Element Name")
			button resetName "Reset" pos:[172,89] width:60 height:21
			button setAsDefault "Set as Default" pos:[250,89] width:80 height:21			


			fn initListView lv =

			(
				lv.gridLines = true --same as in ActiveX  
				lv.View = (dotNetClass "System.Windows.Forms.View").Details
				lv.fullRowSelect = true --same as in ActiveX 
				layout_def = #("Name", "Definition")
				for i in layout_def do
				lv.Columns.add i 96 --add column with name and optional width
			) 
			fn fillInSpreadSheet lv =
			(
				theRange = #() --array to collect the list items
				for o in selection do
				(

				)
				lv.Items.AddRange theRange --when done, we populate the ListView

			)

			dotNetControl lv_objects "System.Windows.Forms.ListView" width:330 height:190 pos:[10,300]


			fn updatePathPreview=
			(
				LPM_Root.pathString=customPath.text
				theNames=#("File Path Preview","======Pass Mode========")
				for thePass in LPM_Root.children where thePass.type=="pass" do
					append theNames (LPM_Fun.getPassPath LPM_Root thePass previewmode:true elementName:"ElementName")
				
				theNames[theNames.count+1]="======Shot Mode========"
				shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
				for theShot in shotRoot.children where theShot.type=="shot" do
					
					if(theShot.allPasses==true) then
						for thePass in LPM_Root.children where thePass.type=="pass" do
							append theNames (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot previewmode:true elementName:"ElementName") 
					else
						for thePass in theShot.passes where (isValidNode thePass) do
							append theNames (LPM_Fun.getPassPath LPM_Root thePass theShot:theShot previewmode:true elementName:"ElementName") 
				previewDDL.items=theNames
			)
			on customPath entered text do
			(
				updatePathPreview()
			)
			on openRootBtn pressed do
			(
				shellLaunch LPM_Root.rootDir ""
			)
			on renderType selected i do
			(
					LPM_Root.renderType=i
					if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
						netBtn.enabled=false
					else
						netBtn.enabled=true
			)

			on resetName pressed do
			(
				LPM_Root.pathString="$Shot\\$Pass\\$Pass_"
				customPath.text="$Shot\\$Pass\\$Pass_"	
				updatePathPreview()
			)
			
			on symbolDDL selected i do
			(
				case i of 
				(
					2: customPath.text+="\\"
					3: customPath.text+="$Cam"	
					4: customPath.text+="$Max"
					5: customPath.text+="$Pass"
					6: customPath.text+="$Shot"
					7: customPath.text+="$Element"
				)
				symbolDDL.selection=1
				updatePathPreview()
			)
			
			on LPM_RenderRo open do
			(
				rootText.text=LPM_Root.rootdir
				typeText.text=LPM_Root.fileType
				quietChk.checked=LPM_Root.quietMode
				customPath.text=LPM_Root.pathString
				updatePathPreview()
				renderType.selection=LPM_root.renderType
				
				if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
					netBtn.enabled=false
				else
					netBtn.enabled=true
				
				cameraList=#(("Active Viewport:"+(substring (viewport.getType() as string) 6 -1)))
				for i in $cameras where (classof i!=Targetobject) do append cameraList i.name
				cameraDDl.items=cameraList

					if(isvalidNode LPM_Root.renderCamera) then
					(
						x=(findItem  cameraDDl.items LPM_Root.renderCamera.name) 
						if (x!=0) then
						cameraDDl.selection=x
					)
			)


			on pickRootBtn pressed do
			(
				thePath=getSavePath caption:"Pick the pass root" initialDir:LPM_Root.rootDir
				if(thePath!=undefined) then
				(	
					LPM_Root.rootDir=thePath+"\\"
					rootText.text=LPM_Root.rootDir
				)
			)

			on rootText changed thePath do
			(
				thePath=substitutestring thePath "/" "\\"
				thePath=trimright thePath "\\"

				LPM_Root.rootDir=thePath+"\\"
				rootText.text=LPM_Root.rootDir		
			)

			on cameraDDL selected it do
			(
				if(selected==1) then
					LPM_Root.renderCamera=undefined
				else
					LPM_Root.renderCamera=getNodeByName cameraDDL.items[it]
				updatePathPreview()
			)
			
			on localBtn pressed do
			(
				LPM_Fun.setWhoToRenderByRenderType()
				LPM_Fun.localRenderSubmit()
			)
			
			on netBtn pressed do
			(
				LPM_Fun.setWhoToRenderByRenderType()
				LPM_Fun.launchNetworkRender()
			)
			

			on pickFileTypeButton pressed do
			(
				thePath=getBitmapSaveFileName caption:"Enter the File Type" filename:("XXX."+LPM_Root.fileType)
				if(thePath!=undefined) then
				(
					theType=getFilenameType thePath
					if(theType!="") then
					(
						theType=substring theType 2 -1
						LPM_Root.fileType=theType
						typeText.text=theType
					)
				)
			)
			on openCommonDialog pressed do
			(
				renderSceneDialog.open()
			)
			
			on setAsDefault pressed do
			(
				LPM_Fun.SetIni "LPM Render" "Path"  customPath.text
				messageBox ("Default Path String set to "+customPath.text)
				
			)

			on quietChk changed state do
			(
				LPM_Root.quietmode=state
			)

		)

		createDialog LPM_RenderRo pos:(LPM_Fun.getRoPos LPM_RenderRo.width)
	)
	
	on settingsMenu Picked do
	(
		rollout settingsRO "LPM Settings"
		(
			group "General"
			(
				dropDownList dialogsAlignLeft "Dialogs Pop Up" items:#("Left","Right")
			)
			
			group "Render Settings"
			(
				dropDownList  defaultFormat "Default File Format" items:#("tga", "avi", "bmp", "cin","eps","hdr","jpg","exr","png","rgb","rla","rpf","tga", "tif","dds")
				dropDownList networkType "Network Type" --items:#("Backburner", "Deadline","Max File")
			)
			group "Passes and Shots"
			(
			--Object Set Default
				dropDownList objectSetDefault "ObjectSet/LightSet Default:" items:#("--","On", "Off")
				dropDownList objectSetDefaultHideMode "ObjectSet/LightSet Default Hide Mode" items:#("Do Nothing", "Hide All Objects/Lights", "Unhide All Objects/Lights")
				dropdownlist shotViewport "Shot Preview Viewport:" items:#("Active Viewport","Viewport 1", "Viewport 2","Viewport 3","Viewport 4")
			)
				--load settings
			on settingsRo open do
			(
				networkType.items=for n in LPM_NetworkPlugins collect n.type
				--general
				dialogsAlign=LPM_Fun.getIni "Settings" "dialogAlignLeft" booleanClass true
				if(dialogsAlign==false) then
					dialogsAlignLeft.selection=2

				--Render settings
				theNetworkType=LPM_Fun.getIni "Settings" "Network Type" string "Backburner"
				for i=1 to networkType.items.count where networkType.items[i] ==theNetworkType do networkType.selection=i
				defaultFormat.items[1]=LPM_Fun.getIni "Settings" "Default Format" string "tga"
				defaultFormat.items=defaultFormat.items
				
				--Passes and shots
				objectSetDefault.selection=LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 1
				objectSetDefaultHideMode.selection=LPM_Fun.getIni "Settings" "objectSetDefaultHideMode" integer 1
				
				theViewport=LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport"
				for i=1 to shotViewport.items.count where shotViewport.items[i]==theViewport do shotViewport.selection=i
				
			)
			--save settings
			on settingsRo close do
			(
				--general
				if(dialogsAlignLeft.selection==1) then
					LPM_Fun.setIni "Settings" "dialogAlignLeft" true
				else
					LPM_Fun.setIni "Settings" "dialogAlignLeft" false
				--render settings
				LPM_Fun.setIni "Settings" "Default Format" defaultFormat.selected
				LPM_Fun.setIni "Settings" "Network Type" networkType.selected
				
				--Passes and shots
				LPM_Fun.setIni "Settings" "objectSetDefaultValue" objectSetDefault.selection
				LPM_Fun.setIni "Settings" "objectSetDefaultHideMode" objectSetDefaultHideMode.selection
				LPM_Fun.setIni "Settings" "shotViewport" shotViewport.selected
				
				
			)
		)
		createDialog settingsRO pos:(LPM_Fun.getRoPos  settingsRO.width)
	)
	
	
	on newLayerFromSelection picked do
	(
		rollout LayerCreator "Enter the Layer Name"
		(
			label l1 "Layer Name"  align:#left
			editText LayerName "" text:"Layer" align:#left
			button okButton "Create Layer"
			
			on okButton pressed do
			(
				if(LayerName.text=="") then
					messagebox "An empty layer name is not allowed."
				else if(LayerManager.getLayerFromName LayerName.text!=undefined) then messagebox "Layer Already Exists"
				else
				(
					theSelection=getCurrentSelection()
					newLayer=LayerManager.newLayerFromName LayerName.text
					for it in theSelection do
						newLayer.addNode it
					newLayer.current=true
					destroyDialog LayerCreator
				)
			)
		)
		createDialog LayerCreator pos:(LPM_Fun.getRoPos  LayerCreator.width)
	)
	
	--merge a preset from a max file
	on mergePreset picked do
	(
		oldCount=$objects.count
		filePath=getOpenFileName caption:"Pick the max file containing the preset" fileName:scenePath
		if(filePath!=undefined) then
		(
			newNodes=#()
			mergeMAXFile filePath #mergedups #useSceneMtlDups	
			for i=oldCount+1 to $objects.count do
			(
				append newNodes objects[i]
			)
			for it in newNodes do
			(
				if(isProperty it #type) then
				(
					if(it.type=="pass") then 
 						it.parent=LPM_Root
					else if(it.type=="root") then 
						delete it
				)
				else
					delete it
			)
		)
		filein (LPM_DIR+"CA.ms") --RELOAD THE CA!!
		LPM_treeview_rollout.updateTV()
	)
	
	--save preset 
	on savePreset picked do
	(
		rollout savePresetRo "Pick Preset Passes" width:162 height:267
		(
			multiListBox passLB "" pos:[5,8] width:154 height:17
			button ok "Save" pos:[6,238] width:153 height:21
			local thePasses=#()

			on savePresetRo open do
			(
				thePasses=for i in LPM_Root.children where i.type=="pass" collect i
				passLB.items=for it in thePasses collect LPM_Fun.getname(it.name)
			)
			on ok pressed do
			(
				nodes=#()
				for i=1 to thePasses.count where passLB.selection[i] do
					for it in thePasses[i] do append nodes it
			
				filePath=getSaveFileName caption:"Pick the max file" fileName:scenePath
				if(filePath!=undefined) then
					savenodes nodes filePath
				destroyDialog savePresetRo
			)
		)
		createDialog savePresetRo pos:(LPM_Fun.getRoPos  savePresetRo.width)
	
	)
	
)
--create a new pass
rcMenu rc_RootMenu
(
	menuItem   addPass "New Pass"
	menuItem passGroupAdd "New Group"
	seperator s1
	menuItem sortPasses "Sort Passes"
	menuItem deleteAllPasses "Delete All Passes"
	
	on passGroupAdd picked do
	(
		theProps=LPM_Fun.createPassGroup "Group"
		theProps.parent=LPM_Root
		newPg=LPM_treeview_rollout.createPassGroupTv theProps
	)
	
	on addPass picked do
	(
		pass=LPM_Fun.createPass LPM_Root
		
		objectSet=LPM_Fun.createObjectSet "All Objects"
		objectSet.wildCard[1]="*"
		objectSet.parent=pass
		
		lightSet=LPM_Fun.createLightSet "All Lights"
		lightSet.wildCard[1]="*"
		lightSet.parent=pass
		
		lightSet.parent=pass
		
		newPass=LPM_treeview_rollout.createPassTv pass LPM_treeview_rollout.tvRoot
		LPM_Treeview_Rollout.addPassTv newPass
		LPM_Treeview_Rollout.renameNode newPass
	)
	
	on sortPasses picked do
	(
		passArray=for it in LPM_Root.children where it.type=="pass" collect it
		qsort passArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
		for it in passArray do
		(	it.parent=undefined
			it.parent=LPM_Root
		)
		LPM_treeview_rollout.updateTV()
		
	)
	on deleteAllPasses picked do
	(
		ans=queryBox "Are you sure you want to delete all passes?"
		if(ans) then
		(	
			for it in LPM_Root.children where it.type=="pass" do
			(	
				for jt in (LPM_Fun.getAllChildren it) do delete jt
			)
			LPM_treeview_rollout.updateTV()
		)
	)
)
rcMenu rc_shotRootMenu
(
	menuItem    newShot "New Shot"
	seperator s1
	menuItem sortShots "Sort Shots"
	menuItem deleteAllShots "Delete All Shots"
	
	on newShot picked do
	(
		theShot=LPM_Fun.createShot LPM_Root
		shotNode=LPM_treeview_rollout.createShotTv theShot
		LPM_treeview_rollout.addShotTv shotNode
		LPM_Treeview_Rollout.renameNode shotNode
		--shotNode.beginEdit()
	)
	on sortShots picked do
	(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"
		shotArray=for it in shotRoot.children where it.type=="shot" collect it
		qsort shotArray (fn compare v1 v2= if(v1.name < v2.name) then 0 else 1)
		for it in shotArray do
		(	it.parent=undefined
			it.parent=shotRoot
		)
		LPM_treeview_rollout.updateTV()
	)
	on deleteAllShots picked do
	(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"
		ans=queryBox "Are you sure you want to delete all shots?"
		if(ans) then
		(	
			for it in shotRoot.children where it.type=="shot" do
			(	
				for jt in (LPM_Fun.getAllChildren it) do delete jt
			)
			LPM_treeview_rollout.updateTV()
		)
	)
)

rcMenu rc_PassGroup
(
	menuItem previewGroup "Render Preview Group 100%"
	menuItem previewGroupHalf "Render Preview Group 50%"
	seperator s2
	menuItem submitLocal "Submit Group Local"
	menuItem submitNetwork "Submit Group Network"
	seperator s1
	menuItem deleteGroup "Delete Group, Keep Passes"
	menuItem deleteGroupChildren "Delete Group, Delete Passes"
	
	on deleteGroup picked do
	(
		grp=LPM_treeview_rollout.tv.selectedNode.tag.value
		for child in grp.children do
		(
			child.parent=LPM_Root			
		)
		delete grp
		LPM_treeview_rollout.updateTV()
	)
	on deleteGroupChildren picked do
	(
		if(querybox "Are you sure you want to delete the group and all its passes?") then
		(
			grp=LPM_treeview_rollout.tv.selectedNode.tag.value
			chld=LPM_Fun.getAllChildren grp
			delete chld
			LPM_treeview_rollout.updateTV()
		)
	)
	fn submitPG RenderType=
	(
		pg=LPM_treeview_rollout.tv.selectedNode.tag.value
		whoToRender=#()

		whoToRender=for pass in pg.children where  (isvalidnode pass) and (pass.type=="pass") and (pass.active)  collect #(pass)
		LPM_Fun.whoToRender=whoToRender
		if(RenderType==#network) then
			LPM_Fun.launchNetworkRender()
		else
			LPM_Fun.renderSubmit RenderType
		
		
	)
	
	on submitLocal picked do
	(
		submitPG #local
	)
	on submitNetwork picked do
	(
		submitPG #network
	)
	on previewGroup picked do
	(
		submitPG #preview
	)
	on previewGroupHalf picked do
	(
		submitPG #previewHalf
	)
)


rcMenu rc_shotMenu
(
	menuItem SelectPasses "Select Passes"
	seperator s2

	menuItem    AddCommon "Add Common Properties"
	menuItem viewRamplayer "View Ram Player"	

	menuItem deleteShot "Delete Shot"
	seperator s4
	menuItem renderShot "Submit Local"
	menuItem renderShotNetwork "Submit Network"
	on AddCommon picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		if((LPM_Fun.firstChildByType thePass "commonProps")==undefined) then
		(
			theProps=LPM_Fun.createCommonProps "commonProps"
			theProps.parent=thePass
			LPM_treeview_rollout.addShotTv LPM_treeview_rollout.tv.selectedNode
		)
	)
	
	on viewRamPlayer picked do
	(
		rollout LPM_shotPicker "Ram Player"
		(
			local passArray=#()
			local theShot
			
			label shotLabel align:#left
			dropdownlist passDDL
			
			on LPM_shotPicker open do
			(
				theShot=LPM_treeview_rollout.tv.selectedNode.tag.value
				shotLabel.text="Shot: "+(LPM_Fun.getName theShot.name)
				passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
				passDDL.items=for it in passArray collect 
				(	
					
					thePath=LPM_Fun.getPassPath LPM_Root it theShot:theShot elementName:"Beauty"
					
					fileList= getfiles ((getFilenamePath thePath) + (getFileNameFile thePath) + "*" + (getFileNametype thePath))
					
					if(fileList.count==0) then
						(LPM_Fun.getname it.name) + " (Missing)"
					else
						(LPM_Fun.getname it.name)
					
				)	
				
			)
			on passDDL selected item do
			(
				thePath=LPM_Fun.getPassPath LPM_Root passArray[item] theShot:theShot elementName:"Beauty"
				LPM_Fun.viewRamplayer thePath
				
			)
		)
		createDialog LPM_shotPicker pos:(LPM_Fun.getRoPos LPM_shotPicker.width)

	)
	
	on selectPasses picked do 
	(
		
		rollout pickPasses_RO "Pick Passes" width:168 height:293
		(
			multiListBox passPickerLB "" pos:[5,43] width:155 height:16 enabled:false
			radiobuttons allPassesRB "" pos:[5,7] width:102 height:32 labels:#("All Passes", "Selected Passes") default:1 columns:1
			label playBut "Display Pass" pos:[6,256] width:95 height:13
			dropdownList playButtonDDL "" pos:[6,270] width:155 height:21 items:#("Pass01","Pass02")
			local theShot
			local theShotNode
			local passArray
			on pickPasses_RO open do
			(
				LPM_treeview_rollout.tv.enabled=false
				theShot=LPM_treeview_rollout.tv.selectedNode.tag.value
				theShotNode=LPM_treeview_rollout.tv.selectedNode
				passArray=for it in (LPM_FUn.getallchildren LPM_Root) where it.type=="pass" collect it
				namesArray=for it in passArray collect (LPM_Fun.getName it.name)
				passPickerLB.items=namesArray
				playButtonDDL.items=namesArray + #("Not Defined")
				playButtonDDL.selection=playButtonDDL.items.count
				
				
				if(theShot.allpasses==false) then
				(	
					allPassesRB.state=2
					passPickerLB.enabled=true
				)
				bitAr=#{}
				for i=1 to passArray.count do
				(	if((findItem theShot.passes passArray[i])>0) then
						append bitAr i
					if(theShot.displayPass==passArray[i]) then
						playButtonDDL.selection=i
				)	
				passPickerLB.selection=bitAr
			)
			on allPassesRB changed state do
			(
				if(state==2) then
					passPickerLB.enabled=true
				else
					passPickerLB.enabled=false
			)
			on pickPasses_Ro close do
			(
				if(allPassesRB.state==1) then
					theShot.allPasses=true
				else
					theShot.allPasses=false
				theShot.passes=#()
				theShot.passesOn=#()
				for i=1 to passArray.count where passPickerLB.selection[i] do
				(
					append theShot.passes passArray[i]
					append theShot.passesOn true
				
				)
				theShot.displayPass=passArray[playButtonDDL.selection]
				LPM_treeview_rollout.tv.enabled=true
				LPM_treeview_rollout.addShotTv theShotNode
			)
				
		)

		createDialog pickPasses_RO pos:(LPM_Fun.getRoPos  pickPasses_Ro.width)
	)
	
	on deleteShot picked do
	(
		LPM_treeview_rollout.deleteSelectedPass LPM_treeview_rollout.tv
	)
	
	on renderShot picked do
	(
		theShot=LPM_treeview_rollout.tv.selectedNode.tag.value
		
		whoToRender=#()
		if(theShot.allpasses) then
			whoToRender=LPM_Fun.collectPasses activeOnly:false theShot:theSHot
		else
			whoToRender=for i=1 to theShot.passes.count where  (isvalidnode theShot.passes[i]) and (theShot.passes[i].type=="pass") and (theShot.passesOn[i])  collect #(theShot.passes[i], theShot)
		LPM_Fun.whoToRender=whoToRender
		LPM_Fun.renderSubmit #local
	)
	on renderShotNetwork picked do
	(
		theShot=LPM_treeview_rollout.tv.selectedNode.tag.value
		
		whoToRender=#()
		if(theShot.allpasses) then
			whoToRender=LPM_Fun.collectPasses activeOnly:false theShot:theSHot
		else
			whoToRender=for i=1 to theShot.passes.count where  (isvalidnode theShot.passes[i]) and (theShot.passes[i].type=="pass") and (theShot.passesOn[i])  collect #(theShot.passes[i], theShot)
		LPM_Fun.whoToRender=whoToRender
		LPM_Fun.launchNetworkRender()
		
	)

)

rcmenu rc_shotPassMenu
(
	menuItem remove "Remove"
	on remove picked do
	(
		theShot=LPM_treeview_rollout.tv.selectedNode.parent.tag.value
		index=LPM_treeview_rollout.tv.selectedNode.tag.value.index
		deleteItem theShot.passes index
		deleteItem theSHot.passesOn index
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
		
		
)

--right click menu for passes
rcMenu rc_PassMenu
(
	menuItem    previewThisPass "Render Preview 100%"
	menuItem    preview50ThisPass "Render Preview"
	menuItem    renderThisPass "Submit Local"
	menuItem	renderThisPassNetwork "Submit Network"
	seperator set2
	menuItem editPassSettings "Edit"
	seperator set4
	subMenu "Add"
	(
		menuItem objectSetAdd "Object Set"
		menuItem lightSetAdd "Light Set"
		menuItem commonPropsAdd "Common Properties Override" 
		menuItem renderPropsAdd "Renderer Override" 
		menuItem effectsPropsAdd "Element, Environment and Effects Override"
		menuItem xrefSceneAdd "Xref Scene Override"
		menuItem scriptAdd "Script"
		menuItem newOperator "Custom Operator"
	)
	menuItem	viewPass "View Bitmap"
	menuItem viewPassRam "View Ram Player"
	menuItem    duplicatePass "Duplicate Pass"
	menuItem    deletePass "Delete Pass"
	seperator set1

	menuItem paste "Paste"
	menuItem pasteInstanced "Paste Instanced"


	
	on rc_PassMenu open do
		preview50ThisPass.text="Render Preview "+(LPM_root.previewSize as string) + "%"
	
	on editPassSettings picked do
	(
		
		rollout passSettingsRO "Pass Settings" width:264 height:131
		(
			local thePass
			groupBox grp1 "Default Object/Light Set Action" pos:[4,7] width:254 height:47
			dropdownList ddlDefaultAction "" pos:[13,26] width:155 height:21 items:#("Do Nothing", "Hide All Objects/Lights", "Unhide All Objects/Lights") 
			groupBox grp2 "Alternate RootDir" pos:[4,55] width:254 height:63
			checkbox chkUseRootDir "Override" pos:[13,74] width:64 height:15
			button btnPickRootDir "Pick" pos:[9,94] width:37 height:16
			edittext etRootDir "" pos:[50,93] width:191 height:17
			
			fn setEnabled=
			(
				btnPickRootDir.enabled=etRootDir.enabled=chkUseRootDir.checked
			)
			on chkUseRootDir changed value do
			(
				setEnabled()
			)
			

			on btnPickRootDir pressed do
			(
				theDir=getsavepath()
				if(theDir!=undefined) then
					etRootDir.text=theDir+"\\"
			)
			on passSettingsRO open do
			(
				thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
				ddlDefaultAction.selection=thePass.hideMode
				chkUseRootDir.checked=thePass.useRootDir
				etRootDir.text=thePass.rootDir
				setEnabled()
			)
			on passSettingsRO close do
			(	
				thePass.hideMode=ddlDefaultAction.selection
				thePass.useRootDir=chkUseRootDir.checked
				thePass.rootDir=etRootDir.text

			)
		)
		createDialog passSettingsRO pos:(LPM_Fun.getRoPos  passSettingsRO.width) 
	)	
	on deletePass picked do
	(
		LPM_treeview_rollout.deleteSelectedPass LPM_treeview_rollout.tv
	)
	on previewThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_renderPass thePass #preview
	)
	on preview50ThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_renderPass thePass #previewHalf
	)
	on renderThisPass picked do
	(
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		LPM_renderPass thePass #local
	)
	on renderThisPassNetwork picked do
	(
		LPM_Fun.whoToRender=#(#(LPM_treeview_rollout.tv.selectedNode.tag.value))
		LPM_Fun.launchNetworkRender()
	)
	on viewPass picked do
	(
		gc light:true delayed:false
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		fname= LPM_Fun.getPreviewFile thePass
		print fName
		theBM=undefined
		if((getfiles fname).count != 0) then
		(	
			theBM=(openBitMap fname)
			display theBM
		)
		
		theBM=undefined
	)
	on viewPassRam picked do
	(
		thePath=(LPM_Fun.getPassPath LPM_Root (LPM_treeview_rollout.tv.selectedNode.tag.value)  elementName:"Beauty")
		LPM_Fun.viewRamplayer thePath
	)
	
	on commonPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value	
		if((LPM_Fun.firstChildByType thePass "commonProps")==undefined) then
		(
			theProps=LPM_Fun.createCommonProps "Common Props"
			theProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
			--edit: Jake Jeziorski with auto-name option it's just annoying to rename
			--LPM_fun.editLabelByNode theProps LPM_treeview_rollout.tvroot
		)
	)
	on newOperator picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value	
		LPM_Operators.fnNewOperator thePass
		LPM_treeview_rollout.addPassTV thePassNode
	)
	on scriptAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value	
		theScript=LPM_Fun.createScript "Script"
		theScript.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theScript LPM_treeview_rollout.tvroot
		
	)
	
	on xrefSceneAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value		
		if((LPM_Fun.firstChildByType thePass "xrefScene")==undefined) then
		(
			theProps=LPM_Fun.createNode "Xref Scene" "xrefScene"
			theProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)

	on renderPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		--if((LPM_Fun.firstChildByType thePassNode.tag.value "renderProps")==undefined) then
		(
			theProps=LPM_Fun.createNode "Render Override" "renderProps"
			theProps.parent=thePassNode.tag.value
				
			LPM_treeview_rollout.addPassTV thePassNode
			tvRoot=LPM_Treeview_Rollout.tvRoot
			--Find and reselect the node
			for i=0 to (tvRoot.nodes.count-1) do
			(
				newNode=tvRoot.nodes.item[i]
	
				for j=0 to (newNode.nodes.count-1) do
				if(newNode.nodes.item[j].tag.value==theProps) then
				(	
					LPM_Treeview_Rollout.tv.selectedNode=newNode.nodes.item[j]
				)
			)

			
			
		    LPM_treeview_rollout.tv.enabled=false
			
			rollout LPM_rendererPicker "Pick a Render Type" width:200
			(
				dropdownlist renderPicker
				local renderTypes=#()
				on LPM_rendererPicker close do
				(
					renderSceneDialog.close()
					LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
					
					renderers.current=renderTypes[renderPicker.selection]()
					renderSceneDialog.open()
				
					if(classof renderers.current)==mental_ray_renderer then
						tabbedDialogs.setCurrentPage #render #(188154248, 1489465121)
					else
						tabbedDialogs.setCurrentPage #render #(1126448576, 479530250)

					
					callbacks.addScript #tabbedDialogDeleted "LPM_renderer_closed()" id:#myscript_update
				)
				
				on renderPicker selected item do
				(
					destroyDialog LPM_rendererPicker
					
				)
				on LPM_rendererPicker open do 
				(	
					renderTypes=for it in RendererClass.classes  where (it!= RLF_Network_Renderer) and (it!=Missing_Renderer) collect it
					renderPicker.items=for it in renderTypes collect (it as string)
				)
			)
			createDialog LPM_rendererPicker pos:(LPM_Fun.GetRoPos LPM_rendererPicker.width)
			

		)
	)
	on effectsPropsAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		if((LPM_Fun.firstChildByType thePass "envProps")==undefined) then
		(
			envProps=LPM_Fun.createNode "Enviroment Override" "envProps"
			envProps.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
			--LPM_fun.editLabelByNode envProps LPM_treeview_rollout.tvroot
		)
	)
	
	on objectSetAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createObjectSet "New Set"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theSet LPM_treeview_rollout.tvroot
	)
	on lightSetAdd picked do
	(
		thePassNode=LPM_treeview_rollout.tv.selectedNode
		thePass=thePassNode.tag.value
		theSet=LPM_Fun.createLightSet "New Set"
		theSet.parent=thePass
		LPM_treeview_rollout.addPassTV thePassNode
		LPM_fun.editLabelByNode theSet LPM_treeview_rollout.tvroot	
	)
	on duplicatePass picked do
	(
		oldNode=LPM_treeview_rollout.tv.selectedNode
		thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
		theCopy=copy thePass
		thePass.layer.addnode theCopy

		for it in thePass.children do 
		(
			newProp=copy it
			newProp.name=it.name
			newProp.parent=theCopy
			thePass.layer.addnode newProp
		)
		newNode=LPM_Treeview_rollout.createPassTv theCopy oldNode.parent
		LPM_treeview_rollout.addPassTV newNode
		--newNode.beginEdit()
	)

	on paste picked do
	(
		if(isvalidnode LPM_treeview_rollout.copyNode) then
		(
			newNode=copy LPM_treeview_rollout.copyNode
			newNode.name=LPM_treeview_rollout.copyNode.name
			newNode.parent=undefined
			LPM_Fun.addToLPMLayer newNode
			
			thePassNode=LPM_treeview_rollout.tv.selectedNode		
			thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
			case LPM_treeview_rollout.copyNode.type of
			(
				"commonProps":for it in thePass.children where it.type=="commonProps" do (delete it)
				"envProps":for it in thePass.children where it.type=="envProps" do (delete it)
			)
			
			newNode.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)
	on pasteInstanced picked do
	(
		if(isvalidnode LPM_treeview_rollout.copyNode) then
		(
			newNode=instance LPM_treeview_rollout.copyNode
			newNode.name=LPM_treeview_rollout.copyNode.name
			newNode.parent=undefined
			LPM_Fun.addToLPMLayer newNode
			
			thePassNode=LPM_treeview_rollout.tv.selectedNode
			thePass=LPM_treeview_rollout.tv.selectedNode.tag.value
			case LPM_treeview_rollout.copyNode.type of
			(
				"commonProps":for it in thePass.children where it.type=="commonProps" do (delete it)
				"envProps":for it in thePass.children where it.type=="envProps" do (delete it)
			)

			newNode.parent=thePass
			LPM_treeview_rollout.addPassTV thePassNode
		)
	)
)

		rollout lightSetProps  ("Editing: "+ (LPM_Fun.getname LPM_treeview_rollout.tv.selectedNode.tag.value.name))
		(
			GroupBox grp3 "Light Control" pos:[1,1] width:190 height:84
			label lbl12 "Cast Shadows" pos:[52,42] width:71 height:15
			label lbl119 "Enabled" pos:[52,21] width:71 height:15
			
			dropdownList pEnable "" pos:[4,17] width:45 height:21 items:#("--", "On", "Off")
			dropdownList pCastShadows "" pos:[4,38] width:45 height:21 items:#("--", "On", "Off")
			colorPicker pColor "Color " pos:[53,62] width:79 height:19
			checkbox pColorEnable "" pos:[9,64] width:17 height:13
			
			
			on lightSetProps open do
			(
				LPM_treeview_rollout.tv.enabled=false
				theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value

				pEnable.selection=theLightSet.pEnable
				pCastShadows.selection=theLightSet.pCastShadows
				pColor.color=theLightSet.pColor
				pColorEnable.checked=theLightSet.pColorEnable
			)
			on lightSetProps close do
			(
				theLightSet=LPM_treeview_rollout.tv.selectedNode.tag.value
				theLightSet.pEnable=pEnable.selection
				theLightSet.pCastShadows=pCastShadows.selection
				theLightSet.pColor=pColor.color
				theLightSet.pColorEnable=pColorEnable.checked
				LPM_Fun.setIcon LPM_treeview_rollout.tv.selectedNode
				LPM_treeview_rollout.tv.enabled=true
			)
		)

rollout objectSetProps ("Editing: "+(LPM_Fun.getname LPM_treeview_rollout.tv.selectedNode.tag.value.name))
(				

	label lbl3 "Renderable/Visible" pos:[59,21] width:120 height:22
	label lbl4 "Cast Shadows" pos:[57,43] width:80 height:22
	label lbl7 "Receive Shadows" pos:[58,64] width:95 height:29
	label lbl9 "Visible to Camera" pos:[59,87] width:109 height:18
	label lbl11 "Motion Blur" pos:[60,127] width:70 height:22
	label lbl13 "Visible to Reflectl/Refract" pos:[59,107] width:127 height:18
	label lbl14 "Apply Atmospherics" pos:[60,147] width:102 height:22
	label lbl15 "Render Occluded Objects" pos:[60,166] width:126 height:22
	
	colorPicker pColor "" pos:[5,218] width:47 height:19
	GroupBox grp5 "Render Control" pos:[3,3] width:190 height:305
	
						
	dropdownList pRenderable "" pos:[8,18] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pCastShadows "" pos:[8,40] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pReceiveShadows "" pos:[8,62] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pVisibleToCamera "" pos:[8,83] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pVisibleToReflect "" pos:[8,103] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pMotionBlur "" pos:[8,123] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pApplyAtmospherics "" pos:[8,143] width:45 height:21 items:#("--", "On", "Off")
	dropdownList pRenderOccluded "" pos:[8,162] width:45 height:21 items:#("--", "On", "Off")

	checkbox pMatEnable "" pos:[8,190] width:15 height:18
	checkbutton pMaterialButton "MaterialButton" pos:[25,184] width:165 height:31
	checkbox pOverrideUserProps "" pos:[12,257] width:15 height:15
	label wireLabel "Wirecolor" pos:[61,223] width:66 height:15
	label lbl10 "Override" pos:[31,257] width:125 height:18
	button editVray "Edit Vray" pos:[91,273] width:65 height:21
	button editMax "Edit Max" pos:[24,274] width:65 height:20
	groupBox grp2 "Custom User Properties" pos:[6,241] width:155 height:60
	
	groupBox grp7 "Viewport Control" pos:[3,313] width:190 height:64
	label lbl2 "Visible" pos:[60,331] width:126 height:22
	dropdownList pVisible "" pos:[8,327] width:45 height:21 items:#("--", "On", "Off")
	label lbl1 "Selectable" pos:[60,353] width:126 height:22
	dropdownList pSelectable "" pos:[8,349] width:45 height:21 items:#("--", "On", "Off")
	
	local pMaterial
	
	on pMaterialButton changed state do
	(
		if(state==true) then
		(
			MatEditor.Open()
			medit.setactivemtlslot 1 true
			 pMatEnable.checked=true
			if(pMaterial==undefined) then
				meditMaterials[1]=standardMaterial()
			else
				meditMaterials[1]=pMaterial
			pMaterialButton.text="Click When Done"	
			
		)
		else
		(
			MatEditor.close()
			if((superclassof meditMaterials[1]) == material) then
			(	
				pMaterial=meditMaterials[1]
				pMaterialButton.text=pMaterial.name + " ( " +((classof pMaterial) as string) +" )"
			)
			else
			(
				pMaterialButton.text="Only Materials!!"
			)
		)
		
	)

	on objectSetProps open do
	(	
		LPM_treeview_rollout.tv.enabled=false
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		pColor.Color=theObjectSet.pColor

		
		pRenderable.selection=theObjectSet.intP[1]
		pCastShadows.selection=theObjectSet.intP[2]
		pReceiveShadows.selection=theObjectSet.intP[3]
		pVisibleToCamera.selection=theObjectSet.intP[4]
		pVisibleToReflect.selection=theObjectSet.intP[5]
		pMotionBlur.selection=theObjectSet.intP[6]
		pApplyAtmospherics.selection=theObjectSet.intP[7]
		pRenderOccluded.selection=theObjectSet.intP[8]
		pMatEnable.checked=theObjectSet.pMatEnable
		pMaterial=theObjectSet.pMaterial
		if(pMaterial!=undefined) then
		pMaterialButton.text=pMaterial.name + " ( " +((classof pMaterial) as string) +" )"
		if(theObjectSet.intP[9]==2) then
			pOverrideUserProps.checked=true
		
		pVisible.selection=theObjectSet.visible
		pSelectable.selection=theObjectSet.selectable
	)
	on editMax pressed do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		setUserPropBuffer theObjectSet  theObjectSet.userProp
		select theObjectSet
		max properties
		theObjectSet.userProp=getUserPropBuffer theObjectSet
		setUserPropBuffer theObjectSet ""
	)
	on editVray pressed do
	(
		if(dovrayobjectproperties==undefined) then
			messagebox "Vray not installed"
		else
		(
			theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
			theBuffer=theObjectSet.userProp
			newBox=box()
			newBox.name=theObjectSet.name + " Properties Override"
			theBuffer=setUserPropBuffer newBox theBuffer
			select newBox
			y=dovrayobjectproperties()
			theObjectSet.userProp=getUserPropBuffer newBox
			delete newBox
		)
	)
	
	on objectSetProps close do
	(	
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.intP=#(pRenderable.selection,pCastShadows.selection,pReceiveShadows.selection,\
			pVisibleToCamera.selection, pVisibleToReflect.selection,pMotionBlur.selection,pApplyAtmospherics.selection,pRenderOccluded.selection)
		if(pOverrideUserProps.checked) then
			theObjectSet.intP[9]=2
		else
			theObjectSet.intP[9]=1
		theObjectSet.pMatEnable=pMatEnable.checked
		theObjectSet.pMaterial=pMaterial
		
		theObjectSet.pColor=pColor.Color
		LPM_treeview_rollout.tv.selectedNode.ForeColor=(dotNetClass "System.Drawing.Color").fromARGB  theObjectSet.pColor.r theObjectSet.pColor.g theObjectSet.pColor.b
		LPM_Fun.setIcon LPM_treeview_rollout.tv.selectedNode
		LPM_treeview_rollout.tv.enabled=true
		
		theObjectSet.visible=pVisible.selection
		theObjectSet.selectable=pSelectable.selection
			
	)
)
rcMenu rc_ObjectSetMenu
(

	menuItem   editSet "Edit"
	menuItem   deleteSet "Delete"
	menuItem	copySet	"Copy"
	submenu "Add"
	(

		menuItem	addLayers	"Add Layers"
		menuItem   addNamedSet "Add Named Selection Set"
		menuItem   addWildCard "Add by Wildcard"
		menuItem   addObjects "Add Selected Objects"
		menuItem   addGroups "Add Selected Groups"
		menuItem 	AddMats "Add by Material Name"
	)
	submenu "Clear"
	(
		menuItem clearAll "Clear All"
		menuItem clearLayers "Clear Layers"
		menuItem clearNamed "Clear Named Sets"
		menuItem clearWild "Clear Wildcards"
		menuitem clearObjects "Clear Objects"	
	)

	separator sep2
	menuItem selectObjects "Select Objects"
	on clearAll picked do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.namedSet=#()
		theObjectSet.layers=#()
		theObjectSet.wildcard=#()
		theObjectSet.nodes=#()
		theObjectSet.mats=#()
		
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode
		
	)
	on clearLayers picked do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.layers=#()
		
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode
	)
	on clearNamed picked do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.namedSet=#()
		
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode
	)
	on clearWild picked do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.wildcard=#()
		
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode
	)
	on clearObjects picked do
	(
		theObjectSet=LPM_treeview_rollout.tv.selectedNode.tag.value
		theObjectSet.nodes=#()
		
		thePassNode=LPM_treeview_rollout.tv.selectedNode.parent
		LPM_treeview_rollout.addPassTv thePassNode
	)
	on rc_ObjectSetMenu open do
	(
		addNamedSet.enabled=getNumNamedSelSets()>0
	)
	
	on addLayers picked do
	(
		LPM_treeview_rollout.addVisibleLayers()
	)
	on addMats picked do
	(
		LPM_treeview_rollout.addMats()
	)
	
	on addNamedSet picked do
	(
		LPM_treeview_rollout.addNamedSet()
	)
	on addWildCard picked do
	(
		LPM_treeview_rollout.addWildCard()
	)
	on addNamedSet picked do
	(
		LPM_treeview_rollout.addNamedSet()
	)
	
	on addObjects picked do
	(
		LPM_treeview_rollout.addSelectedObjects()
	)
	on copySet picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on addGroups picked do
	(
		LPM_treeview_rollout.addSelectedGroups()
	)
	
	on deleteSet picked do
	(
		theObjectSetNode=LPM_treeview_rollout.tv.selectedNode
		theObjectSet=theObjectSetNode.tag.value	
		delete theObjectSet
		theObjectSetNode.remove()
	)
	
	on selectObjects picked do
	(
		objSet=LPM_treeview_rollout.tv.selectedNode.tag.value	
		tmpCollection=#()
		--named sets
		for it in objSet.namedSet do
		(
			join tmpCollection (for item in selectionSets[it] collect item)
		)
		--wildcard
		for j=1 to objSet.wildCard.count do
		(
			if(objSet.wildCard[j]!="") then
				join tmpCollection (execute ("$"+objSet.wildCard[j]))
		)			
		--layers
		LMan=LayerManager
		for j=1 to objSet.layers.count do
		(	
			theLayerNodes=#()
			theLayer=LMan.getLayerfromName objSet.layers[j]
			if(theLayer != undefined) then
				theLayer.nodes &theLayerNodes
			join tmpCollection theLayerNodes
		)
		
		join tmpCollection objSet.nodes
		
		if(objSet.type=="objectSet") then
			theSelection=for it in tmpCollection where ((((superClassof it) ==geometryClass) or ((superClassof it) ==shape)) and (not (iskindof it particleGroup)))  collect it
		else
			theSelection=for it in tmpCollection where (((superClassof it) ==light) and(not(iskindof it target)))collect it
		
		
		try (select theSelection) catch()
	)
	
	on editSet picked do
	(
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.type=="objectSet")then
			createDialog objectSetProps 194 383 pos:(LPM_Fun.getRoPos  194)
		else
			createDialog lightSetProps 194 89 pos:(LPM_Fun.getRoPos  194)
		
	)
)
rcMenu rc_matMenu
(
	menuItem	removeObj	"Remove"
	menuItem	selectObj	"Select"
	on selectObj picked do
	(
		theMat=LPM_treeview_rollout.tv.selectedNode.tag.value.leaf
		max select none
			for sceneMat in scenematerials where (sceneMat.name==theMat) do 
				for it in objects where it.material==sceneMat do select it
	)	
	on removeObj picked do
	(
		
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value	
		
		LPM_Fun.pruneArray theParent.mats theObj.leaf
		
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
)

rcMenu rc_objectMenu
(
	menuItem	removeObj	"Remove"
	menuItem	selectObj	"Select"
	on selectObj picked do
	(
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		try(select theObj.leaf)catch()
	)
	
	on removeObj picked do
	(
		
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value	
		
		LPM_Fun.pruneArray theParent.nodes theObj.leaf

		LPM_treeview_rollout.tv.selectedNode.remove()
	)
)
rcMenu rc_layerMenu
(
	menuItem	removeLayer	"Remove"
	seperator sp1
	menuItem addSelectedToLayer "Add Selected Objects"
	menuItem selectObjectsOnLayer "Select Objects"
	menuItem makeActiveLayer "Make Active Layer"
	on removeLayer picked do
	(
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value	
		
		LPM_Fun.pruneArray theParent.layers theObj.leaf
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on addSelectedToLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName
		
		theSelection=getCurrentSelection()
		for it in theSelection do
		(
			theLayer.addNode it		
		)
	)
	on makeActiveLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName
		theLayer.current=true
	)
	
	on selectObjectsOnLayer picked do
	(
		theLayerName=(LPM_treeview_rollout.tv.selectedNode.tag.value).leaf
		theLayer=LayerManager.getLayerFromName theLayerName
		theLayer.select on
		--print (refs.dependents theLayer)
		--select 
		
		
		
	)
)
rollout wildCardRO "Wildcard" width:217 height:57
(
	edittext WildText "$" pos:[2,7] width:202 height:17
	button test "Try It!" pos:[12,29] width:46 height:21
	button help "Help!" pos:[171,30] width:33 height:21
	
	label lbl1 "" pos:[60,32] width:106 height:18 style_sunkenedge:true
	
	on wildCardRO open do
	(
		LPM_treeview_rollout.tv.enabled=false
		treenode=LPM_treeview_rollout.tv.selectedNode 
		WildText.text=treenode.Parent.tag.value.wildCard[treenode.tag.value.index]
	)
	on wildCardRO close do
	(
		treenode=LPM_treeview_rollout.tv.selectedNode 
		treenode.Parent.tag.value.wildCard[treenode.tag.value.index]=WildText.text
		LPM_treeview_rollout.tv.enabled=true
		LPM_treeview_rollout.tv.selectedNode.text=WildText.text
	)
	on test pressed do
	(
		sel=undefined
		try(sel=(execute ("$"+WildText.text)))catch(messagebox (getcurrentexception()))
		if(sel!=undefined) then
		(	select sel
			lbl1.text=sel.count as string + " Objects Selected"
		)
		else
			lbl1.text="0 Objects Selected"
	)
	on help pressed do
	(
		shellLaunch "http://www.kxcad.net/autodesk/Autodesk_MAXScript_Reference_9/pathname_literals.htm" ""
	)
)
rcMenu rc_wildCardMenu
(
	menuItem edit "Edit"
	menuItem	removeLayer	"Remove"
	on edit picked do
	(
		createDialog wildCardRO pos:(LPM_Fun.getRoPos  wildCardRO.width)
	)
	
	on removeLayer picked do
	(
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value	
		
		theParent.wildcard=(for i=1 to theParent.wildCard.count where i!=theObj.index collect theParent.wildCard[i])
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
)

rcMenu rc_namedSetMenu
(
	menuItem	removeLayer	"Remove"
	on removeLayer picked do
	(
		theObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		theParent=LPM_treeview_rollout.tv.selectedNode.parent.tag.value	
		
		theParent.namedSet=(for i=1 to theParent.namedSet.count where i!=theObj.index collect theParent.namedSet[i])
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
)

rcMenu rc_xrefScene
(
	menuItem refresh "Refresh Xref Scenes"
	menuItem openXrefDialog "Open Xref Scenes Dialog"
	seperator s1
	menuItem remove "Remove"
	on refresh picked do
		LPM_treeview_rollout.updateTV()
	on remove picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on openXrefDialog picked do
	(
		try(actionMan.executeAction 0 "40368")catch()  -- File: XRef Scenes
	)
	
)

rollout LPM_scriptRO "Script" width:500 height:434
(
	local scriptObj
	label tryLbl "Try( Execute" pos:[13,44] width:60 height:13
	edittext ScriptText "" pos:[13,62] width:474 height:320
	label catchLbl ")Catch(Messagebox (GetcurrentException() as string))" pos:[13,387] width:251 height:13
	button arrayFromSelection "Array From Selection" pos:[305,22] 
	button tryIt "Test the Script" pos:[16,405] width:468 height:25
	
	checkbox PreRender "Pre Render" pos:[14,9] width:114 height:17
	checkbox PostRender "Post Render" pos:[14,25] width:114 height:17
	checkbox PreLPM "Pre LPM Eval" pos:[180,10] width:114 height:17
	checkbox PostLPM "Post LPM Eval" pos:[179,28] width:114 height:17
	
	on arrayFromSelection pressed do
	(
		ScriptText.text+="\n arr=#("
		sel=getcurrentselection();
		for i=1 to (sel.count - 1) do
		(
			ScriptText.text+="$"+sel[i].name+",";
		)
		if(sel.count>0) then
		ScriptText.text+="$"+sel[sel.count].name;
		ScriptText.text+=");\n"

	)
	
	on tryIt pressed do
	(
		try(Execute ScriptText.text)Catch(Messagebox (GetcurrentException() as string))
	)
	on LPM_scriptRO open do
	(
		scriptObj=LPM_treeview_rollout.tv.selectedNode.tag.value
		scriptText.text=scriptObj.script
		PreRender.checked=scriptObj.preRender
		PostRender.checked=scriptObj.postRender
		PreLPM.checked=scriptObj.PreLPM
		PostLPM.checked=scriptObj.PostLPM
	)
	on LPM_ScriptRo close do
	(
		ScriptObj.script=ScriptText.text
		scriptObj.preRender=PreRender.checked
		scriptObj.postRender=PostRender.checked
		scriptObj.PreLPM=PreLPM.checked
		scriptObj.PostLPM=PostLPM.checked
	)

	
)

rcMenu rc_scriptMenu
(
	menuItem	editItem "Edit"
	menuItem    remove "Remove"
	menuItem    copyAtm "Copy"
	on copyAtm picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	on remove picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on editItem picked do
	(
		createDialog LPM_scriptRO pos: (LPM_Fun.getRoPos LPM_scriptRo.width)
	)
	
)

rollout atmRollout "Env, Effects, Elements, Atmosphere" width:235 height:720
(
	local elementArray=#()
	local atmArray=#()
	local effectArray=#()
	label lbl1 "Color:" pos:[7,40] width:47 height:12 enabled:false
	label lbl2 "Environment Map:" pos:[66,37] width:89 height:17 enabled:false
	label lbl3 "Tint:" pos:[6,107] width:49 height:17 enabled:false
	label lbl4 "Level:" pos:[61,110] width:53 height:15 enabled:false
	label lbl5 "Ambient:" pos:[164,110] width:49 height:15 enabled:false
	GroupBox grp1 "Background" pos:[2,17] width:227 height:68 enabled:false
	GroupBox grp2 "Global Lighting" pos:[2,87] width:227 height:69 enabled:false
	colorPicker bgcolor "" pos:[3,55] width:52 height:19 enabled:false default:(color 0 0 0)
	local envMap
	checkbutton envMapButton "None" pos:[71,55] width:151 height:19 enabled:false
	checkbox useEnvMap "Use Map" pos:[162,36] width:63 height:16 enabled:false
	colorPicker tint "" pos:[5,128] width:53 height:20 enabled:false default:(color 255 255 255)
	spinner level "" pos:[64,131] width:50 height:16 enabled:false range:[0,9999,1]
	colorPicker Ambient "" pos:[160,128] width:58 height:18 enabled:false default:(color 0 0 0)
			
	multiListBox atmList "" pos:[5,404] width:223 height:9 enabled:false
	multiListBox effectList "" pos:[5,578] width:224 height:9 enabled:false
	
		
	checkbox effectOverride "Override" pos:[2,547] width:71 height:17
	checkbox atmOverride "Override" pos:[2,372] width:60 height:15
	checkbox backgroundOverride "Override" pos:[3,3] width:72 height:13
	GroupBox grp5 "Select Atmospheres" pos:[3,389] width:227 height:156 enabled:false
	GroupBox grp7 "Select Effects" pos:[3,563] width:229 height:147 enabled:false
	GroupBox grp8 "Select Render Elements" pos:[1,233] width:230 height:136


	multiListBox elementList "" pos:[4,248] width:223 height:9 enabled:false
	checkbox elementOverride "Override" pos:[2,215] width:62 height:17
	button clearAtm "Clear" pos:[194,376] width:35 height:16 enabled:false
	button clearEffect "Clear" pos:[194,551] width:35 height:16 enabled:false
	button clearElement "Clear" pos:[194,222] width:35 height:16 enabled:false
	groupBox grp18 "Exposure Control" pos:[2,172] width:227 height:40
	checkbox exposureOverride "Override" pos:[2,158] width:94 height:14
	dropDownList exposureddl "" pos:[13,188] width:200 height:21 items:#("<No Exposure Control>", "Automatic Exposure Control", "Linear Exposure Control", "Logarithmic Exposure Control", "mr Photographic Exposure Control", "Pseudo Color Exposure Control") enabled:false
	
	local theNode
	
	on atmRollout open do
	(
		LPM_treeview_rollout.tv.enabled=false
		
		re = maxOps.GetCurRenderElementMgr()
		for i=1 to re.NumRenderElements() do
		(
			theEle=re.GetRenderElement (i-1)
			elementArray[i]=theEle.elementName
		)
		elementList.items= elementArray	
		
		for i=1 to numAtmospherics do
		(
			theAtm=getAtmospheric i
			atmArray[i]=theAtm.name
		)
		atmList.items=atmArray
		
		for i=1 to numEffects do
		(
			theEffect=getEffect i
			effectArray[i]=theEffect.name
		)
		effectList.items=effectArray
		
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(theNode.initialized==true) then
		(
			--elements load
			elementOverride.checked=theNode.elementOverride
			elementList.enabled=theNode.elementOverride
			grp8.enabled=theNode.elementOverride
			clearElement.enabled=theNode.elementOverride
			sel=#()					
			
			for i=1 to theNode.activeElement.count do
			(
				theItem=findItem elementArray theNode.activeElement[i]
				if  theItem!=0 then
					append sel theItem
			)
			elementList.selection=sel
			
			--atmosphere load
			atmOverride.checked=theNode.atmOverride
			atmList.enabled=theNode.atmOverride
			grp5.enabled=theNode.atmOverride
			clearAtm.enabled=theNode.atmOverride
			sel=#()
			
			for i=1 to theNode.activeAtm.count do
			(
				theItem=findItem atmArray theNode.activeAtm[i]
				if  theItem!=0 then
					append sel theItem
			)
			atmList.selection=sel
			
			
			--effects load
			effectOverride.checked=theNode.effectOverride
			effectList.enabled=theNode.effectOverride
			grp7.enabled=theNode.effectOverride
			clearEffect.enabled=theNode.effectOverride
			sel=#()
			
			
			
			for i=1 to theNode.activeEffect.count do
			(
				theItem=findItem effectArray theNode.activeEffect[i]
				if  theItem!=0 then
					append sel theItem
			)
			effectList.selection=sel
			
			--bg load
			backGroundOverride.checked=theNode.backGroundOverride
			bgColor.color=theNode.bgColor
			envMap=theNode.envMap
			if(envMap!=undefined) then
				envMapButton.text=envMap.name+"("+((classof envMap) as string)+")"
			else
				envMapButton.text ="none"						
			useEnvMap.checked=theNode.useEnvMap
			tint.color=theNode.tint
			level.value=theNode.level
			ambient.color=theNode.ambient
			grp1.enabled=theNode.backGroundOverride
			lbl1.enabled=theNode.backGroundOverride
			lbl2.enabled=theNode.backGroundOverride
			lbl3.enabled=theNode.backGroundOverride
			lbl4.enabled=theNode.backGroundOverride
			lbl5.enabled=theNode.backGroundOverride
			bgColor.enabled=theNode.backGroundOverride
			envMapButton.enabled=theNode.backGroundOverride
			useEnvMap.enabled=theNode.backGroundOverride
			grp2.enabled=theNode.backGroundOverride
			tint.enabled=theNode.backGroundOverride
			level.enabled=theNode.backGroundOverride
			ambient.enabled=theNode.backGroundOverride
			--exposure control
			exposureddl.enabled=theNode.exposureOverride
			exposureOverride.checked=theNode.exposureOverride
			if(theNode.exposureInt==0)then
				theNode.exposureInt=1
			exposureDDL.selection=theNode.exposureInt
		)
		else
		(
			bgColor.color=backgroundColor
			useEnvMap.checked=useEnvironmentMap
			envMap=undefined
			tint.color=lightTintColor
			level.value=lightLevel
			ambient.color=ambientColor
		)			
	)
	on envMapButton changed state do
	(

		if(state==true) then
		(
			MatEditor.Open()
			medit.setactivemtlslot 1 true
			if(envMap==undefined) then
				meditMaterials[1]=bitmaptexture()
			else
				meditMaterials[1]=envMap
			envMapButton.text="Click When Done"	
			
		)
		else
		(
			MatEditor.close()
			if((superclassof meditMaterials[1]) == textureMap) then
			(	
				envMap=meditMaterials[1]
				envMapButton.text=envMap.name + " ( " +((classof envMap) as string) +" )"
			)
			else
			(
				envMapButton.text="Only Maps!!"
			)
		)
	)
	on exposureOverride changed state do
	(
		exposureddl.enabled=state
	)
	on backGroundOverride changed state do
	(
		grp1.enabled=state
		lbl1.enabled=state
		lbl2.enabled=state
		lbl3.enabled=state
		lbl4.enabled=state
		lbl5.enabled=state
		bgColor.enabled=state
		envMapButton.enabled=state
		useEnvMap.enabled=state
		grp2.enabled=state
		tint.enabled=state
		level.enabled=state
		ambient.enabled=state
	) 
	on elementOverride changed state do
	(
		elementList.enabled=state
		grp8.enabled=state
		clearElement.enabled=state
	)
	on clearElement pressed do
	(
		elementList.selection=#{}
	)
	
	on effectOverride changed state do
	(
		effectList.enabled=state
		grp7.enabled=state
		clearEffect.enabled=state
	)
	on clearEffect pressed do
	(
		effectList.selection=#{}
	)
	
	on atmOverride changed state do
	(
		atmList.enabled=state
		grp5.enabled=state
		clearAtm.enabled=state
	)
	on clearAtm pressed do
	(
		atmList.selection=#{}
	)
	

	on atmRollout close do
	(
		--element
		theNode.elementOverride=elementOverride.checked
		theNode.activeElement=#()
		for i=1 to elementArray.count do
		(
			
			if(elementList.selection[i]) then
			(	
				append theNode.activeElement elementList.items[i]
			)
		)				
		--atm
		theNode.atmOverride=atmOverride.checked
		theNode.activeAtm=#()
		for i=1 to atmArray.count do
		(
			if(atmList.selection[i]) then
				append theNode.activeAtm atmList.items[i]
		)
		--effects
		theNode.effectOverride=effectOverride.checked
		theNode.activeEffect=#()
		for i=1 to effectArray.count do
		(
			if(effectList.selection[i]) then
				append theNode.activeEffect effectList.items[i]
		)
		--background
		theNode.backGroundOverride=backGroundOverride.checked
		theNode.bgColor=bgColor.color
		theNode.envMap=envMap
		theNode.useEnvMap=useEnvMap.checked
		theNode.tint=tint.color
		theNode.level=level.value
		theNode.ambient=ambient.color
		
		--exposure control
		theNode.exposureOverride=exposureOverride.checked
		theNode.exposureInt=exposureDDL.selection
		theNode.initialized=true
		LPM_treeview_rollout.tv.enabled=true	

	)
)

rcMenu rc_atmPropsMenu
(
	menuItem	addByName "Edit"
	menuItem    openEnvDialog "Open Enviroment Dialog"
	menuItem    remove "Remove"
	menuItem    copyAtm "Copy"
	
	on copyAtm picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	
	on remove picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	
	on addByName picked do
	(
		createdialog atmRollout pos:(LPM_Fun.getRoPos  atmRollout.width)
	)
	
	on openEnvDialog picked do
	(
		actionMan.executeAction 0 "40029"
	)
)

rcMenu rc_RenderPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem   removeProps "Remove"
	menuItem copyProps "Copy"
	seperator sp1
	menuItem loadDefault "Default Renderer -> Override"
	menuItem setAsDefault "Override -> Default Renderer"
	
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value	
	)
	
	on editProps picked do
	(
		
		renderSceneDialog.close()
		LPM_oldRenderSettings=LPM_Fun.saveRenderPreset() 
		
		
		if(LPM_treeview_rollout.tv.selectedNode.tag.value.initialized)then
		(	
			LPM_Fun.loadRenderPreset LPM_treeview_rollout.tv.selectedNode.tag.value.props
		)
		
		renderSceneDialog.open()
	
		if(classof renderers.current)==mental_ray_renderer then
			tabbedDialogs.setCurrentPage #render #(188154248, 1489465121)
		else
			tabbedDialogs.setCurrentPage #render #(1126448576, 479530250)
		LPM_treeview_rollout.tv.enabled=false
		
		callbacks.addScript #tabbedDialogDeleted "LPM_renderer_closed()" id:#myscript_update
		
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
		
	)
	on loadDefault picked do
	(
		theProp=LPM_treeview_rollout.tv.selectedNode.tag.value
		theProp.props=LPM_Fun.saveRenderPreset()
		theProp.initialized=true
	)
	on setAsDefault picked do
	(
		theProp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(theProp.initialized) then
		(
			LPM_Fun.loadRenderPreset theProp.props
		)
		else
		(
			messagebox "The selected prop has no render settings stored."
		)
		
	)
)



rollout commonRollout "Common Properties" width:370 height:640
(
	GroupBox grp1 "Time Output" pos:[24,4] width:335 height:111 enabled:false
	GroupBox grp2 "Output Size" pos:[24,112] width:336 height:88 enabled:false
	GroupBox grp3 "Options" pos:[24,241] width:335 height:105 enabled:false
	GroupBox grp4 "Advanced Lighting" pos:[24,347] width:335 height:54 enabled:false
	GroupBox grp5 "File Type" pos:[24,401] width:154 height:43 enabled:false
	GroupBox grp7 "Camera" pos:[23,452] width:336 height:42 enabled:false

	checkbox timeOutputTgl "" pos:[4,9] width:15 height:16
	checkbox outputSizeTgl "" pos:[4,120] width:15 height:16
	checkbox optionsTgl "" pos:[4,246] width:15 height:16
	checkbox advancedLightingTgl "" pos:[4,352] width:15 height:16
	checkbox fileTypeTgl "" pos:[4,406] width:15 height:16
	checkbox cameraTgl "" pos:[4,457] width:15 height:16
	
	radiobuttons _rendTimeType "" pos:[34,21] width:124 height:64 enabled:false labels:#("Single", "Active Time Segment", "Range", "Frames") columns:1
	spinner _rendNThFrame "Every Nth Frame" pos:[232,20] width:117 height:16 enabled:false range:[1,99999,1] type:#integer
	spinner _rendStart "" pos:[112,52] width:69 height:16 enabled:false range:[-1e+007,1e+007,0] type:#integer
	spinner _rendEnd "" pos:[212,52] width:69 height:16 enabled:false range:[-1e+007,1e+007,0] type:#integer
	spinner _rendFileNumberBase "File Number Base: " pos:[198,90] width:150 height:16 enabled:false range:[-99999,99999,0] type:#integer
	spinner _renderWidth "" pos:[70,131] width:62 height:16 enabled:false range:[1,32768,1] type:#integer
	spinner _renderHeight "" pos:[70,151] width:62 height:16 enabled:false range:[1,32768,1] type:#integer
	checkbutton lockAspect "L" pos:[135,130] width:14 height:38 enabled:false
	spinner aspect "" pos:[70,175] width:62 height:16 enabled:false
	label aspectLabel "Aspect:" pos:[31,176] width:35 height:14 enabled:false
	dropDownList presetDDL "" pos:[164,174] width:152 height:21 enabled:false tooltip:"Select a preset to load it"
	button addPreset "+" pos:[317,176] width:16 height:16 enabled:false tooltip:"Add a preset"
	button removePreset "-" pos:[336,176] width:16 height:16 enabled:false tooltip:"Remove the selected preset"
	
	spinner _RendApertureWidth "" pos:[251,133] width:64 height:16 enabled:false range:[0.001,1000,1]
	spinner _renderPixelAspect "" pos:[251,153] width:64 height:16 enabled:false range:[0.001,1000,1]
	edittext _rendPickupFrames "" pos:[109,70] width:240 height:17 enabled:false
	checkbox _rendAtmosphere "Atmospherics" pos:[31,254] width:95 height:19 enabled:false
	checkbox _renderEffects "Effects" pos:[31,271] width:95 height:19 enabled:false
	checkbox _renderDisplacements "Displacement" pos:[31,288] width:95 height:19 enabled:false
	checkbox _rendColorCheck "Video Color Check" pos:[31,304] width:145 height:19 enabled:false
	checkbox _rendFieldRender "Render To Fields" pos:[31,322] width:145 height:19 enabled:false
	checkbox _rendHidden "Render Hidden Geometry" pos:[173,253] width:145 height:19 enabled:false
	checkbox _rendSimplifyAreaLights "Area Lights/Shadows as Points" pos:[173,270] width:172 height:19 enabled:false
	checkbox _rendForce2Side "Force 2-Sided" pos:[173,287] width:106 height:19 enabled:false
	checkbox _rendSuperBlack "Super Black" pos:[173,304] width:96 height:19 enabled:false
	checkbox _useAdvancedLighting "Use Advanced Lighting" pos:[33,362] width:143 height:15 enabled:false
	checkbox _computeAdvancedLighting "Compute Advanced Lighting" pos:[33,377] width:143 height:15 enabled:false
	dropdownList _CameraDdl "" pos:[51,467] width:120 height:21 enabled:false items:#("--")
	edittext _fileType "" pos:[91,418] width:53 height:19 readOnly:true
	button pickTypeButton "Pick" pos:[39,419] width:47 height:16 enabled:false
	
	checkbox gammaTgl "" pos:[182,405] width:15 height:16 
	GroupBox grp13 "Gamma" pos:[201,402] width:157 height:43 enabled:false
	spinner _fileOutGamma "File Out Gamma" pos:[260,421] width:95 height:16 enabled:false range:[0.01,5,1]
	
	label lbl1 "To" pos:[187,52] width:19 height:18 enabled:false
	label lbl4 "Width:" pos:[33,132] width:35 height:14 enabled:false
	label lbl5 "Height:" pos:[33,151] width:35 height:14 enabled:false
	label lbl6 "Aperture Width(mm):" pos:[152,133] width:99 height:15 enabled:false
	label lbl7 "Pixel Aspect:" pos:[186,153] width:61 height:15 enabled:false range:[0.01,100,.01]
	

	GroupBox grp8 "Pre Render Script" pos:[24,496] width:336 height:57
	checkbox usePreScript "" pos:[5,505] width:18 height:15 
	button pickPreScript "Pick" pos:[37,510] width:47 height:17
	checkbox usePostScript "" pos:[5,561] width:14 height:15 
	button pickPostScript "Pick" pos:[33,570] width:47 height:17
	button EditPreScript "Edit" pos:[85,510] width:42 height:17
	button EditPostScript "Edit" pos:[82,570] width:42 height:17
	button newPreScript "New" pos:[183,510] width:42 height:17
	button newPostScript "New" pos:[181,570] width:42 height:17
	GroupBox grp16 "Post Render Script" pos:[24,554] width:336 height:60
	edittext preScript "" pos:[33,531] width:320 height:18
	edittext postScript "" pos:[27,590] width:326 height:18
	button execPreScript "Execute" pos:[129,510] width:55 height:17
	button execPostScript "Execute" pos:[126,570] width:55 height:17
	
	checkbox autoUpdateName "Auto Update Name" pos:[8,620] width:115 height:15
	checkbox disableFinalOutput "Disable Final Image Output" pos:[150, 620] width:170 height:15
	GroupBox RenderTypeGroup "Render Type" pos:[24,202] width:335 height:37
	checkbox renderTypeTgl "" pos:[4,209] width:15 height:16
	dropdownList renderTypeDDL "" pos:[34,216] width:116 height:21 items:#("view", "region", "crop", "blowup")
	
	local presetData=#()
	local presetNames=#()
	local cameraList=#()
	local theNode 
	
	fn toggleState=
	(
			state=timeOutputTgl.checked
			grp1.enabled=state
			_rendTimeType.enabled=state
			_rendNThFrame.enabled=state
			_rendStart.enabled=state
			_rendEnd.enabled=state
			_rendFileNumberBase.enabled=state
			_rendPickupFrames.enabled=state
			lbl1.enabled=state
			
			state=outputSizeTgl.checked
			grp2.enabled=state
			_renderHeight.enabled=state
			_renderWidth.enabled=state
			_RendApertureWidth.enabled=state
			_renderPixelAspect.enabled=state
			lockAspect.enabled=state
			aspect.enabled=state
			aspectLabel.enabled=state
			presetDDL.enabled=state
			addPreset.enabled=state
			removePreset.enabled=state
		
		
		
			lbl4.enabled=state
			lbl5.enabled=state
			lbl6.enabled=state
			lbl7.enabled=state
			
			state=optionsTgl.checked
			grp3.enabled=state
			_rendAtmosphere.enabled=state
			_renderEffects.enabled=state
			_renderDisplacements.enabled=state
			_rendColorCheck.enabled=state
			_rendFieldRender.enabled=state
			_rendHidden.enabled=state
			_rendSimplifyAreaLights.enabled=state
			_rendForce2Side.enabled=state
			_rendSuperBlack.enabled=state
	
			state=advancedLightingTgl.checked
			grp4.enabled=state
			_useAdvancedLighting.enabled=state
			_computeAdvancedLighting.enabled=state
	
			state=fileTypeTgl.checked
			grp5.enabled=state
			--_fileType.enabled=state
			pickTypeButton.enabled=state
			
			
			state=cameraTgl.checked
			grp7.enabled=state
			_CameraDDl.enabled=state
			
			state=renderTypeTgl.checked
			renderTypeDDL.enabled=state
			RenderTypeGroup.enabled=state
			
			state=gammaTgl.state
			grp13.enabled=state
			_fileOutGamma.enabled=state
	
	)
	on timeOutputTgl changed state do
	(
		toggleState()
		
	)
	on outputSizeTgl changed state do
	(
		toggleState()

	
	)
	on optionsTgl changed state do
	(
		toggleState()	
	)
	on advancedLightingTgl changed state do
	(
		toggleState()
	)
	on fileTypeTgl changed state do
	(
		toggleState()	
	)
	on filePathTgl changed state do
	(
		toggleState()

	)
	on cameraTgl changed state do
	(
		toggleState()

	)
	on renderTypeTgl changed state do
	(
		toggleState()
	)
	on gammaTgl changed state do
	(
		toggleState()
	)
	on editPreScript pressed do
	(
		try(edit preScript.text)catch()		
	)
	on editPostScript pressed do
	(
		try(edit postScript.text)catch()		
	)
	on pickPreScript pressed do
	(
		thePath=getOpenFileName()
		if(thePath!=undefined) then
		prescript.text=thePath
		usePreScript.checked=true
	)
	on pickPostScript pressed do
	(
		thePath=getOpenFileName()
		if(thePath!=undefined) then
		postscript.text=thePath
		usePostScript.checked=true
	)
	on newPreScript pressed do
	(
		thePath=getSaveFileName types:"maxscript(*.ms)|*.ms"
		if(thePath!=undefined) then
		(
			close (createFile thePath)
			edit thePath
			preScript.text=thePath
			usePreScript.checked=true
		)
	)
	
	on newPostScript pressed do
	(
		thePath=getSaveFileName types:"maxscript(*.ms)|*.ms"


		if(thePath!=undefined) then
		(
			close (createFile thePath)
			edit thePath
			postScript.text=thePath
			usePostScript.checked=true
		)
	)
	
	on execPreScript pressed do
	(
		try(fileIn preScript.text) catch (messagebox (getCurrentException()))
	)
	on execPostScript pressed do
	(
		try(fileIn postScript.text) catch (messagebox (getCurrentException()))
	)
	
	
	on pickTypeButton pressed do
	(
		if(LPM_Root.fileType==undefined) then
			LPM_Root.fileType="TGA"
		thePath=getBitmapSaveFileName caption:"Enter the File Type" filename:("XXX."+LPM_Root.fileType)
		if(thePath!=undefined) then
		(	
			theType=getFilenameType thePath
			if(theType!="") then
			(	
				theType=substring theType 2 -1
				_fileType.text=theType
			)
		)
	)
	on _rendStart changed val do
	(
		 _rendTimeType.state=3
		
	)
	on _rendEnd changed valt  do
	(
		_rendTimeType.state=3
		
	)

	
	fn updateAspect=
	(
		aspect.value=(_renderWidth.value) as float /(_renderHeight.value) as float
		
	)
	
	on _renderWidth changed val do
	(
		if(lockAspect.state) then
		(
			_renderHeight.value=(_renderWidth.value as float)/ (aspect.value as float)
			
		)
		else
			updateAspect()
	)
	on aspect changed val do
	(
		_renderWidth.value=(_renderHeight.value as float)* (aspect.value as float)
	)
	
	on _renderHeight changed val do
	(
		if(lockAspect.state) then
		(
			_renderWidth.value=(_renderHeight.value as float)* (aspect.value as float)
			
		)
		else
			updateAspect()
	)
	fn loadPresets=
	(
		--load preset data
		it=LPM_Fun.getIni "Presets" "CommonPresets" string "#(#(640,480,1.0,36.0),#(1024,768,1.0,36.0))" 
		presetData=execute it
		presetDDL.items=for it in presetData collect (it[1] as string)+"x"+(it[2] as string)+" "+(it[3] as string)+"px "+(it[4] as string)+"mm"
		
	)
	fn savePresets=
	(
		fn compareFN x y=
		(
			case of
			(
			(x[1]<y[1]): -1
			(x[1]>y[1]): 1
			default:0
			)
		)
		
		qsort presetData compareFN 
		theData=presetData as string
		LPM_Fun.setini "Presets" "CommonPresets" presetData
	)
	
	on addpreset pressed do
	(
		
		presetData+=#(#(_renderWidth.value,_renderHeight.value,_renderPixelAspect.value,_RendApertureWidth.value))
		savePresets()
		loadPresets()
		presetDDL.selection=presetDDL.items.count
		
	)
	on removepreset pressed do
	(
		theItem=presetDDL.selection
		if(theItem!=0) then
		(
			presetData=for i=1 to presetData.count where (i!= theItem )collect presetData[i]
		)
		savePresets()
		loadPresets()
		if(presetDDL.selection>presetDDL.items.count or presetDDL.selection==0) then
			presetDDL.selection=presetDDL.items.count
	)
	on presetDDL selected item do
	(
		if(item!=0) then
		(
			_renderWidth.value=presetData[item][1]
			_renderHeight.value=presetData[item][2]
			_renderPixelAspect.value=presetData[item][3]
			_RendApertureWidth.value=presetData[item][4]
			updateAspect()
		)
		
	)
	
	
	on commonRollout open do
	(
		LPM_treeview_rollout.tv.enabled=false
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		theNode=LPM_treeview_rollout.tv.selectedNode
		

		loadPresets()
		
		cameraList=for i in $cameras where (superclassof i==camera) collect i
		cameraNameList=for it in cameraList collect it.name
		_cameraDDl.items=cameraNameList
		
		_rendTimeType.state=cp._rendTimeType
		_rendNThFrame.value=cp._rendNThFrame
		_rendStart.value=cp._rendStart
		_rendEnd.value=cp._rendEnd
		_rendFileNumberBase.value=cp._rendFileNumberBase
		_renderHeight.value=cp._renderHeight
		_renderWidth.value=cp._renderWidth
		updateAspect()
		
		_RendApertureWidth.value=cp._RendApertureWidth
		_renderPixelAspect.value=cp._renderPixelAspect
		_rendPickupFrames.text=cp._rendPickupFrames
		_rendAtmosphere.checked=cp._rendAtmosphere
		_renderEffects.checked=cp._renderEffects
		_renderDisplacements.checked=cp._renderDisplacements
		_rendColorCheck.checked=cp._rendColorCheck
		_rendFieldRender.checked=cp._rendFieldRender
		_rendHidden.checked=cp._rendHidden
		_rendSimplifyAreaLights.checked=cp._rendSimplifyAreaLights
		_rendForce2Side.checked=cp._rendForce2Side
		_rendSuperBlack.checked=cp._rendSuperBlack
		_useAdvancedLighting.checked=cp._useAdvancedLighting
		_computeAdvancedLighting.checked=cp._computeAdvancedLighting
		timeOutputTgl.checked=cp.timeOutputTgl
		outputSizeTgl.checked=cp.outputSizeTgl
		optionsTgl.checked=cp.optionsTgl
		advancedLightingTgl.checked=cp.advancedLightingTgl
		fileTypeTgl.checked=cp.fileTypeTgl
		_fileType.text=cp._fileType
		gammaTgl.checked=cp.gammaTgl
		_fileOutGamma.value=cp._fileOutGamma
		renderTypeTgl.checked=cp.renderTypeTgl
		for i=1 to renderTypeDDL.items.count where renderTypeDDL.items[i]==cp.renderType do 
			renderTypeDDL.selection=i
		
		cameraTgl.checked=cp.cameraTgl
		if(isvalidNode cp._camera) then
		(
			x=(findItem  _cameraDDl.items cp._camera.name) 
			if (x!=0) then
				_cameraDDl.selection=x
		)		
		
		usePreScript.checked=cp.usePreScript
		preScript.text=cp.preScript
		usePostScript.checked=cp.usePostScript
		postScript.text=cp.postScript
		
		autoUpdateName.checked=cp.autoUpdateName
		disableFinalOutput.checked=cp.disableFinalOutput
		toggleState()
			
	)
	on commonRollout close do
	(
		try(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		
		cp.initialized=true
		cp._rendTimeType=_rendTimeType.state
		cp._rendNThFrame=_rendNThFrame.value
		cp._rendStart=_rendStart.value
		cp._rendEnd=_rendEnd.value
		cp._rendFileNumberBase=_rendFileNumberBase.value
		cp._renderHeight=_renderHeight.value
		cp._renderWidth=_renderWidth.value
		cp._RendApertureWidth=_RendApertureWidth.value
		cp._renderPixelAspect=_renderPixelAspect.value
		cp._rendPickupFrames=_rendPickupFrames.text
		cp._rendAtmosphere=_rendAtmosphere.checked
		cp._renderEffects=_renderEffects.checked
		cp._renderDisplacements=_renderDisplacements.checked
		cp._rendColorCheck=_rendColorCheck.checked
		cp._rendFieldRender=_rendFieldRender.checked
		cp._rendHidden=_rendHidden.checked
		cp._rendSimplifyAreaLights=_rendSimplifyAreaLights.checked
		cp._rendForce2Side=_rendForce2Side.checked
		cp._rendSuperBlack=_rendSuperBlack.checked
		cp._useAdvancedLighting=_useAdvancedLighting.checked
		cp._computeAdvancedLighting=_computeAdvancedLighting.checked
		cp.timeOutputTgl=timeOutputTgl.checked
		cp.outputSizeTgl=outputSizeTgl.checked
		cp.optionsTgl=optionsTgl.checked
		cp.advancedLightingTgl=advancedLightingTgl.checked
		cp.fileTypeTgl=fileTypeTgl.checked
		cp._fileType=_fileType.text
		cp.renderTypeTgl=renderTypeTgl.checked
		cp.renderType=renderTypeDDL.selected
		cp.gammaTgl=gammaTgl.state
		cp._fileOutGamma=_fileOutGamma.value
		cp.usePreScript=usePreScript.state
		cp.preScript=preScript.text
		cp.usePostScript=usePostScript.state
		cp.postScript=postScript.text
		cp.autoUpdateName=autoUpdateName.checked
		cp.disableFinalOutput=disableFinalOutput.checked
		cp.cameraTgl=cameraTgl.checked
		if(cameraTgl.checked) then
		(
				if(_cameraDDL.selection>0) then
				(
					theCam=cameraList[_cameraDDL.selection]
					if (isvalidnode theCam) then
						cp._Camera=theCam
				)
		)
		theNode.text=LPM_Fun.generateCommonPropName cp
		LPM_treeview_rollout.tv.enabled=true
	)
	catch( messagebox "LPM failed to save common properties" title:"LPM Error")
		
	)
)

rcMenu rc_commonPropsMenu
(
	menuItem	editProps	"Edit"
	menuItem copyProps "Copy"
	menuItem   removeProps "Remove"
	seperator sp1
	menuItem grabTime "Grab Active Time"
	menuItem grabCamera "Grab Active Camera"
	seperator sp2
	menuItem selectCamera "Select Camera"
	on copyProps picked do
	(
		LPM_treeview_rollout.copyNode=LPM_treeview_rollout.tv.selectedNode.tag.value
	)
	
	on removeProps picked do
	(
		theNode=LPM_treeview_rollout.tv.selectedNode.tag.value
		delete theNode
		LPM_treeview_rollout.tv.selectedNode.remove()
	)
	on editProps picked do
	(
		createDialog commonRollout pos:(LPM_Fun.getRoPos  commonRollout.width)
	)
	on grabtime picked do
	(
		
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		cp.timeOutputTgl=true
		cp._rendTimeType=3
		cp._rendStart=animationRange.start
		cp._rendEnd=animationRange.end
		LPM_treeview_rollout.tv.selectedNode.text=LPM_Fun.generateCommonPropName cp
	)
	on grabCamera picked do
	(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(getActiveCamera()!=undefined) then
		(
			cp.cameraTgl=true
			cp._Camera=getActiveCamera()
			LPM_treeview_rollout.tv.selectedNode.text=LPM_Fun.generateCommonPropName cp
		)
		else
			messagebox "The active node is not a camera"
	)
	on selectCamera picked do
	(
		cp=LPM_treeview_rollout.tv.selectedNode.tag.value
		if(isvalidnode cp._Camera) then
			select cp._Camera
	)
	
)

