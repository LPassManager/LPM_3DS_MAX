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

clearListener();
callbacks.removeScripts id:#closeLPM

LPM_Callback="LPM_Fun.destroyAllDialogs()"

callbacks.addScript #filePostOpen LPM_Callback id:#closeLPM
callbacks.addScript #systemPostNew LPM_Callback id:#closeLPM
callbacks.addScript #systemPostReset LPM_Callback id:#closeLPM
try(destroyDialog LPM_treeview_rollout)catch()

LPM_Root = $LPM_Root



ilTv = dotNetObject "System.Windows.Forms.ImageList"
ilTv.imageSize = dotNetObject "System.Drawing.Size" 16 15

rollout LPM_treeview_rollout "LPM v1.20"
(

local copyNode
local colorBackup
local displayColorWire
local displayColorShaded
local tvRoot
local shotRoot
local shotRootTV
local prevSelection
local iconPath=::LPM_DIR+"icons\\LPM\\"
local proMode=false

struct leafType (type, leaf, index, active)


edittext passDDL pos:[0,2] width:80 height:20 readonly:true

fn getIconFromBitmap iconFileName =
(

	theFileName = iconPath + iconFileName +".bmp"

	img = dotNetClass "System.Drawing.Image" --create an image
	ilTv.images.add (img.fromFile theFileName) --add to the list

)
fn initTreeView tv=
(
	
	--drawmode=dotnetobject "System.Windows.Forms.TreeViewDrawMode" ""
--	tv.drawMode=tv.drawmode.ownerDrawAll
	--tv.LabelEdit =true	
	--Drag and Drop
	-- In the tv init function
	tv.AllowDrop = true -- allow DragandDrop for the Treeview
	--tv.ShowNodeToolTips=true
	getIconFromBitmap "Root" 
	getIconFromBitmap "Pass"
	getIconFromBitmap "objectSet"
	getIconFromBitmap "lightSet"
	getIconFromBitmap "Layers"
	getIconFromBitmap "NamedSet"
	getIconFromBitmap "Wildcard"
	getIconFromBitmap "Node"
	getIconFromBitmap "Render"
	getIconFromBitmap "Enviroment"
	getIconFromBitmap "Common"
	getIconFromBitmap "Disabled"
	getIconFromBitmap "objectSetOn"
	getIconFromBitmap "objectSetOff"
	getIconFromBitmap "lightSetOn"
	getIconFromBitmap "lightSetOff"
	getIconFromBitmap "Shot"
	getIconFromBitmap "ShotOff"
	getIconFromBitmap "ShotRoot"
	getIconFromBitmap "xrefProps"
	getIconFromBitmap "xrefOn"
	getIconFromBitmap "xrefOff"
	getIconFromBitmap "CommonOff"
	getIconFromBitmap "EnviromentOff"
	getIconFromBitmap "RenderOff"
	getIconFromBitmap "passGroupOn"
	getIconFromBitmap "passGroupOff"
	getIconFromBitmap "scriptOn"
	getIconFromBitmap "scriptOff"
		
	tv.imageList = ilTv 
)

fn updatePassDDL =
(
	if isvalidnode(LPM_ActivePass) then
		passDDL.text=LPM_Fun.getname LPM_ActivePass.name
	else
		passDDL.text="No Pass Active"
)

fn deleteSelectedPass tv =
(
	theNode=tv.selectedNode
	for jt in (LPM_Fun.getAllChildren theNode.tag.value) do delete jt
	theNode.Remove()
)

fn makeItalic theNode=
(
	obj=theNode.tag.value
	if(isValidNode obj) then
	(
		if(InstanceMgr.GetInstances obj #() >1) then
		(
			theNode.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").italic
		)
	)
)

fn createTVnode nodeRoot theNode nodeType:"LPM_node" = 
(
	nodeName = ""
	case nodeType of
	(
		"leaf": nodeName = theNode.leaf
		"leafObject": nodeName = theNode.leaf.name
		"leafXref": nodeName = ((getFilenameFile theNode.leaf[1])+(getFilenameType theNode.leaf[1]))
		"commonProps": nodeName = (LPM_Fun.generateCommonPropName theNode)
		"passRoot": nodeName = (	if(proMode==false) then "Passes (Maximum of 3)" else "Passes" )
		"shotRoot": nodeName = (	if(proMode==false) then "Shots (Maximum of 2)" else "Shots" )
		default: nodeName = (LPM_Fun.getName theNode.name)
	)
	newNode = nodeRoot.Nodes.Add nodeName
	newNode.tag=dotNetMXSValue theNode
	newNode.BackColor = (dotNetClass "System.Drawing.Color").White
	LPM_Fun.setIcon newNode
	newNode
)

fn createPassTv objPass nodeParent =
(
	newPass = createTVnode nodeParent objPass
	newPass.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold 
	newPass
)

fn createPassGroupTv pg=
(
	createTVnode tvRoot pg
)

fn addPassTv newPass=
(
	newPass.nodes.clear()
	pmPass=newPass.tag.value
	
	allObjSet=for obj in pmPass.children where obj.type=="objectSet" collect obj
	
	for i=1 to allObjSet.count do
	(
		obj=allObjSet[1+allObjSet.count-i]
		newObj = createTVnode newPass obj
		makeItalic newObj
		newObj.ForeColor=(dotNetClass "System.Drawing.Color").fromARGB  obj.pColor.r obj.pColor.g obj.pColor.b 
		for i=1 to obj.wildCard.count do
		(
			newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"
		)
		for i=1 to obj.namedSet.count do
		(
			newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"
		)
		for i in obj.layers do
		(
			newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"
		)
		for i in obj.mats do
		(
			newNode = createTVnode newObj (leafType "mat" i) nodeType:"leaf"
		)
		
		for i in obj.nodes do
		(
			if(isvalidnode i) then
			(
				newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"
			)
		)
		if(obj.expanded) then	
			newObj.expand()
	)
	
	allLightSets=for obj in pmPass.children where obj.type=="lightSet" collect obj
	
	for i=1 to allLightSets.count do
	(
		obj=allLightSets[1+allLightSets.count-i]
		newObj = createTVnode newPass obj
		makeItalic newObj
		
		for i=1 to obj.wildCard.count do
		(
			newNode = createTVnode newObj (leafType "wildCard" obj.wildCard[i] i) nodeType:"leaf"
		)
		for i=1 to obj.namedSet.count do
		(
			newNode = createTVnode newObj (leafType "namedSet" obj.namedSet[i] i) nodeType:"leaf"
		)
		for i in obj.layers do
		(
			newNode = createTVnode newObj (leafType "layer" i) nodeType:"leaf"
		)
		for i in obj.nodes do
		(
			if(isvalidnode i) then
			(
				newNode = createTVnode newObj (leafType "object" i) nodeType:"leafObject"
			)
		)
		if(obj.expanded) then	
			newObj.expand()
	)	
	
	commonProps=LPM_Fun.firstChildByType pmPass "commonProps"
	if(commonProps!=undefined) then
	(	
		newCP = createTVnode newPass commonProps nodeType:"commonProps"
		makeItalic newCP
	)

	allRenderProps=for obj in pmPass.children where obj.type=="renderProps" collect obj
	--if(renderProps!=undefined) then
	for renderProps in allRenderProps do
	(	
		newRP = createTVnode newPass renderProps
		makeItalic newRP
	)
	envProps=LPM_Fun.firstChildByType pmPass "envProps"
	if(envProps!=undefined) then
	(	
		newEnv = createTVnode newPass envProps
		makeItalic newEnv
	)
	
	xrefSceneProps=LPM_Fun.firstChildByType pmPass "xrefScene"
	if(xrefSceneProps!=undefined) then
	(
		newXR = createTVnode newPass xrefSceneProps

		xrefFileCount = xrefs.getXrefFileCount()
		for i=1 to xrefFileCount do
		(
			theFile=(xrefs.getXrefFile i).fileName
			found=false
			if(finditem xrefSceneProps.fileNames theFile!=0) then found=true
			newNode = createTVnode newXR (leafType "xrefLeaf"  #(theFile, found)) nodeType:"leafXref"
		)
		if(xrefSceneProps.expanded) then
			newXR.Expand()
	)
	
	for script in pmPass.children where script.type=="script" do
	(
		nScript = createTVnode newPass script
		makeItalic nScript
	)
	for op in pmPass.children where op.type=="generic" do
	(
		opTVNode=createTVnode newPass op
	)
	
	if(pmPass.expanded) then	
	(	
		newPass.Expand()
	)
)

fn createShotTv shotNode=
(
	newShot = createTVnode shotRootTV shotNode
	newShot.nodefont = dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold 
	newShot
)

fn addShotTv newShot=
(
	newShot.nodes.clear()
	pmShot=newShot.tag.value
	
	commonProps=LPM_Fun.firstChildByType pmShot "commonProps"
	if(commonProps!=undefined) then
	(	
		newCP = createTVnode newShot commonProps nodeType:"commonProps"
		makeItalic newCP
	)
	
	if(pmShot.allPasses==false) then
	(
		--get rid of invalid passes
		np=#()
		ni=#()
		for i=1 to pmShot.passes.count where isvalidNode pmShot.passes[i] do
		(
			append np pmShot.passes[i]
			if(pmShot.passesOn[i]==true) then
				append ni true
			else
				append ni false
			newNode = createTVnode newShot (leafType "ShotPass" (pmShot.passes[i]) i ni[i]) nodeType:"leafObject"
			
		)
		pmShot.passes=np
		pmShot.passesOn=ni
	)
	else
	(
		createTVnode newShot (leafType "ShotPassAll" "All Passes") nodeType:"leaf"
	)

	if(pmShot.expanded) then	
	(	newShot.Expand()
	)
)

fn fillInTreeView tv =
(
	--Add the Root
	tv.beginUpdate()
	
	tvRoot = createTVnode tv LPM_Root nodeType:"passRoot"
	
	--add the passes
	count=0
	for pg in LPM_Root.children where pg.type=="passGroup" do
	(
		newPG = createPassGroupTv pg
		
		for pmPass in pg.children where pmPass.type=="pass" do
		(
			count+=1
			if(count < 4) or (proMode) then
			(	
				newPass=createPassTv pmPass newPG
				addPassTv newPass
			)
		)
		if(pg.expanded) then
			newPG.expand()
	)
	
	
	for pmPass in LPM_Root.children where pmPass.type=="pass" do
	(
		count+=1
		if(count < 4) or (proMode) then
		(	
			newPass = createPassTv pmPass tvRoot
			addPassTv newPass
		)
	)
	
	shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
	
	shotRootTV = createTVnode tv (LPM_Fun.firstChildByType LPM_Root "shotRoot") nodeType:"shotRoot"
	
	--add the shots
	
	count=0
	for pmShot in shotRoot.children where pmShot.type=="shot" do
	(
		
		count+=1
		if(count < 3) or (proMode) then
		(	
			newShot=createShotTv pmShot
			addShotTv newShot
		)
	)
	
	tvRoot.Expand()
	if(shotRoot.expanded) then
		shotRootTv.expand()
	updatePassDDL()

	tv.endUpdate()
)

button renderPassButton "$" pos:[80,2] images:#(iconPath+"refresh.bmp",undefined,1,1,1,1,1) tooltip:"Renders active the pass, shift click for half resolution, (Hotkey-able)"
button colorButton "tgl" pos:[100,2] images:#(iconPath+"colorOn.bmp",undefined,1,1,1,1,1) tooltip:"Click to color pass, shift click to restore"
checkbutton hideButton "rdr" pos:[180,2] images:#(iconPath+"eyeOpen.bmp",undefined,1,1,1,1,1) tooltip:"Hide by category floater."
checkbutton playButton "time" pos:[120,2] images:#(iconPath+"play.bmp",undefined,1,1,1,1,1) tooltip:"Plays shots in order, skips inactive shots"
button quickScriptsButton "QS" pos:[180,25] tooltip:"Quick Scripts" width:25
dropDownList previewSizeDDL "" pos:[140,2] items:#("10","25","50","75","100","150","200") width:40
dropDownList previewTypeDDL pos:[0,25] width:80 items:#("View", "Selected", "Region", "Crop", "BlowUp")
dropDownList cameraDDL "" pos:[80,25] width:100 items:#("-----------------------")

dropDownList renderTypeDDL "" items:#("Passes", "Passes Hardware Preview", "Shots", "Shots Hardware Preview") pos:[0,200] width:100 height:19 tooltip:"Render Mode"
button localRenderButton "Local" pos:[100,200] height:19 width:35 tooltip:"Submits all passes/shots to this computer.  Depends on 'Only Active Passes / Shots' in the render dialog and on the Render Mode."
button networkRenderButton "Network" pos:[145,200] height:19 width:50 tooltip:"Submits all passes/shots to the network.  Depends on 'Only Active Passes / Shots' in the render dialog and on the Render Mode."
button openRenderDirButton "..." pos:[202,200] height:19 width:17 tooltip:"Opens the render directory"
hyperLink supportLPM "If you enjoy using LPM, please donate!" address:"http://www.lukashi.com/LPM_Purchase.php" color:(color 88 199 225) hoverColor:(color 255 114 0) visitedColor:(color 255 114 0)

on quickScriptsButton pressed do
(
	LPM_Fun.QuickScripts();
)

on localRenderButton pressed do
(
	LPM_Fun.setWhoToRenderByRenderType()
	LPM_Fun.localRenderSubmit()
)

on openRenderDirButton pressed do
(
	shellLaunch LPM_Root.rootDir ""
)

on networkRenderButton pressed do
(
	LPM_Fun.setWhoToRenderByRenderType()
	LPM_Fun.launchNetworkRender()
)

fn updateRenderButtonsState=
(
	
	case LPM_Root.renderType of
	(
		1: networkRenderButton.enabled=true
		2: networkRenderButton.enabled=false
		3: networkRenderButton.enabled=true
		4: networkRenderButton.enabled=false
	)
)

on previewTypeDDL selected item do
(
	setRenderType (previewTypeDDL.selected as name)
	type=previewTypeDDL.selected
	if( type== "Region")or(type=="Crop") or(type=="BlowUp") then
		(
			try(EditRenderRegion.EditRegion())catch()
		)
)
on renderTypeDDL selected item do
(
	LPM_Root.renderType=renderTypeDDL.selection
	updateRenderButtonsState()
)

fn updateCameraDDL=
(
	--camera
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


on previewSizeDDL selected item do
(
	LPM_Root.previewSize=PreviewSizeDDL.selected as integer
)


on renderPassButton pressed do
(
	
	if(isvalidnode LPM_activePass) then
	(
		if(keyboard.shiftPressed) then
			LPM_renderPass LPM_activePass #previewHalf	
		else
			LPM_renderPass LPM_activePass #preview
	)
)


--hides and colors the nodes
on colorButton pressed do
(		
	--restore
	if (keyboard.shiftPressed) then
	(
		if(colorBackup!=undefined) then
		(
			for item in colorBackup do try(item[1].wirecolor=item[2])catch()
			displayColor.wireframe=displayColorWire
			displayColor.shaded=displayColorShaded
		)
	)
	else
	(

		if(isvalidnode LPM_activePass) then
		(
			if (colorBackup==undefined) then
			(	colorBackup=(for it in $objects collect #(it, it.wireColor))
				displayColorWire=displayColor.wireframe
				displayColorShaded=displayColor.shaded
			)
			displayColor.wireframe=#object
			displayColor.shaded=#object
			
			
			for it in objects where ((superclassof it)==geometryClass) do it.wireColor=white
					
			--collect object nodes array
			objNodes=#()
			objSetArray=#()	
			LPM_Fun.getObjectSetArrays LPM_activePass "objectSet" &objNodes &objSetArray
			
			for i=1 to objNodes.count do
			(
			
				theColor=objSetArray[i].pColor
		
				for theNode in objNodes[i] do
				( 
					theNode.wireColor=theColor
				)
			)
		)
	)
)

fn hideByPass thePass=
(
	with redraw off 
	(
		
	if(isvalidnode thePass) then
		(
			lMan=layerManager
			for i=0 to (lMan.count-1) do
			(
				theLayer=lMan.getLayer i
				if(theLayer.name!="zz-LPM")then
				(
					theLayer.isHidden=false					
				)
			
			)
			
		
			--collect object nodes array
			objNodes=#()
			objSetArray=#()	
			LPM_Fun.getObjectSetArrays thePass "objectSet" &objNodes &objSetArray
			
			for k=1 to objNodes.count do
			(
				for theNode in objNodes[k] where  (classof theNode != Targetobject ) and (superclassof thenode !=camera) do
				( 
						
						if(objSetArray[k].visible==2) then
							unHide theNode
						else if (objSetArray[k].visible==3) then
							hide theNode
						else if(objSetArray[k].intp[1]==3) then
								hide theNode
						else if(objSetArray[k].intp[1]==2) then
								unhide theNode
						
						if(objSetArray[k].selectable==2) then
							unfreeze theNode
						else if(objSetArray[k].selectable==3) then
							freeze theNode
					
				)
				
			)
			
			unhide lights
			--collect the light nodes
			lightNodes=#()
			lightSetArray=#()	
			LPM_Fun.getObjectSetArrays thePass "lightSet" &lightNodes &lightSetArray

			for k=1 to lightNodes.count do
			(
		
				for theNode in lightNodes[k] do
				( 
						if(lightSetArray[k].pEnable==3)  then
								hide theNode
						if(lightSetArray[k].pEnable==2)  then
								unhide theNode
				)
			)
						xrefBackArray=#()
			
			xrefSceneProps=LPM_Fun.firstChildByType thePass "xrefScene"
			if(isvalidnode xrefSceneProps) then
			(
				--set the scenes
				for i=1 to xrefs.getXRefFileCount() do
				(
					theXref=(xrefs.getXRefFile i)
					if((findItem xrefSceneProps.fileNames theXref.fileName)!=0) then
						theXref.hidden=false
					else
						theXref.hidden=true
					
				)
				
			)
			else
			(
				for i=1 to xrefs.getXRefFileCount() do
					(xrefs.getXRefFile i).hidden=false
				
				
			)
		)
	)
	
)


fn hideByActivePass=
(
	hideByPass  LPM_activePass
	
)

on hideButton changed state do
(		
	rollout displayRollout "Display"
	(
		group "Hide by Category"
		(
			checkbox GeometryChk "Geometry" align:#left
			checkbox ShapesChk "Shapes" align:#left
			checkbox LightsChk "Lights" align:#left
			checkbox CamerasChk "Cameras" align:#left
			checkbox HelpersChk "Helpers" align:#left
			checkbox spacewarpsChk "Space Warps" align:#left
			checkbox particlesChk "Particle Systems" align:#left
			checkbox bonesChk "Bone Objects" align:#left
			button allBut "Hide All" align:#left
			button noneBut "Hide None" align:#left
			button invertBut "Invert" align:#left

		)
		
		on GeometryChk changed state do
			hideByCategory.geometry=state
		on shapesChk changed state do
			hideByCategory.shapes=state
		on lightsChk changed state do
			hideByCategory.lights=state
		on camerasChk changed state do
			hideByCategory.cameras=state
		on helpersChk changed state do
			hideByCategory.helpers=state
		on spacewarpsChk changed state do
			hideByCategory.spacewarps=state
		on particlesChk changed state do
			hideByCategory.particles=state
		on bonesChk changed state do
			hideByCategory.bones=state
		on allBut pressed do
		(	
			hideByCategory.all()
			GeometryChk.state=true
			ShapesChk.state=true
			LightsChk.state=true
			CamerasChk.state=true 
			HelpersChk.state=true
			spacewarpsChk.state=true
			particlesChk.state=true
			bonesChk.state=true
		)
		on noneBut pressed do
		(
			hideByCategory.none()
			GeometryChk.state=false
			ShapesChk.state=false
			LightsChk.state=false
			CamerasChk.state=false
			HelpersChk.state=false
			spacewarpsChk.state=false
			particlesChk.state=false
			bonesChk.state=false
		)
		on invertBut pressed do
		(
			
			GeometryChk.state=hideByCategory.geometry=not GeometryChk.state
			ShapesChk.state=hideByCategory.Shapes=not ShapesChk.state
			LightsChk.state=hideByCategory.Lights=not LightsChk.state
			CamerasChk.state=hideByCategory.Cameras=not CamerasChk.state
			HelpersChk.state=hideByCategory.Helpers=not HelpersChk.state
			spacewarpsChk.state=hideByCategory.spacewarps=not spacewarpsChk.state
			particlesChk.state=hideByCategory.particles=not particlesChk.state
			bonesChk.state=hideByCategory.bones=not bonesChk.state
		)
		on displayRollout open do
		(
			GeometryChk.state=hideByCategory.geometry
			ShapesChk.state=hideByCategory.Shapes
			LightsChk.state=hideByCategory.Lights
			CamerasChk.state=hideByCategory.Cameras
			HelpersChk.state=hideByCategory.Helpers
			spacewarpsChk.state=hideByCategory.spacewarps
			particlesChk.state=hideByCategory.particles
			bonesChk.state=hideByCategory.bones
		)
		on displayRollout close do
		(
			hideButton.checked=false
		)
		
	)
	
	if(state) then
		createDialog displayRollout pos:(LPM_Fun.getRoPos displayRollout.width)
	else 
		try (destroyDialog displayRollout)catch()
)

dotNetControl tv "TreeView"  pos:[0,48] align:#left

local stopper
on playButton changed state do
(
	rollout LPM_progressRO "Shot"
	(
		label shotName text:"Shot"
		checkButton loopButton "Loop"
		on LPM_progressRO open do
			loopButton.checked=timeConfiguration.playbackLoop
		on loopButton changed state do
			timeConfiguration.playbackLoop=state
	)
	if(state==false) then
	(	
		stopAnimation()
		stopper=false
	)
	else	
	(
		
		if(keyboard.shiftpressed) then
			timeConfiguration.playbackLoop=true
		else
			timeConfiguration.playbackLoop=false
		
		it=(GetDialogPos LPM_Treeview_rollout)
		it.y-=45
		createDialog LPM_progressRO pos:it width:LPM_Treeview_rollout.width


		stopper=true
		theNode=tv.selectedNode
		start=1
		if(tv.selectedNode!=undefined)and (tv.selectedNode.tag.value.type=="shot") then
			for i=1 to shotRoot.children.count where shotRoot.children[i]==theNode.tag.value do
				start=i
		
		for i=start to shotRoot.children.count where (shotRoot.children[i].active and stopper) do
		(
			LPM_progressRo.shotName.text="Playing: "+shotRoot.children[i].name
			cp=LPM_Fun.firstChildByType (shotRoot.children[i]) "commonProps"
			
			if(isvalidnode shotRoot.children[i].displayPass) then 
			(
				LPM_ActivePass=shotRoot.children[i].displayPass
				updatePassDDL()
				hideByActivePass()
			)
			if(cp!=undefined) then
			(
				if(cp.cameraTgl==true) then
				(
					try(
							hide cameras
							
							theViewport=viewport.activeViewport
							case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
							(
								"Viewport 1": theViewport=1
								"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
								"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
								"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
							)
							viewport.activeViewport=theViewport
							viewport.setCamera cp._Camera
							unhide cp._Camera
							if(isvalidnode cp._Camera.target) then
								unhide cp._Camera.target
						
						)catch()
				)
				
				if(cp.timeOutputTgl) then
				case cp._rendTimeType of
				(
					3:(
							if(cp._rendStart < cp._rendEnd ) then
								(
									animationRange = interval cp._rendStart cp._rendEnd
									sliderTime=cp._rendStart
									playAnimation()
								)
						)

				)
				
			)
		)
		playButton.checked=false
		try(destroyDialog LPM_progressRo)catch()
	)
)

fn updateTV=
(
	tv.nodes.clear()
	fillInTreeView tv
)


fn addSelectedObjects=
(
		
	theObjectSet=tv.selectedNode.tag.value	
	for i=1 to selection.count do
	(
	    if not isGroupHead(selection[i]) then
			theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
	)
	thePassNode=tv.selectedNode.parent
	addPassTv thePassNode
)

fn addSelectedGroups=
(
		
	theObjectSet=tv.selectedNode.tag.value	
	for i=1 to selection.count do
	(
	    if isGroupHead(selection[i]) then
			theObjectSet.Nodes[theObjectSet.Nodes.count+1]=selection[i]
	)
	thePassNode=tv.selectedNode.parent
	addPassTv thePassNode
)

fn addWildcard=
(
	theObjectSet=tv.selectedNode.tag.value	
	theObjectSet.wildCard[theObjectSet.wildCard.count+1]="*"
	thePassNode=tv.selectedNode.parent
	addPassTv thePassNode
)

rollout setPicker "Pick the Set"
(
	dropDownList theSets

	on setPicker open do
	(
		
		tv.enabled=false
		if(getNumNamedSelSets()==0) then
			theSets.items=#("")
		theSets.items=(for i=1 to getNumNamedSelSets() collect getNamedSelSetName i)
	)
	on setPicker close do
	(
		theObjectSet=tv.selectedNode.tag.value	
		theObjectSet.namedSet[theObjectSet.namedSet.count+1]=theSets.selected
		tv.enabled=true
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode
	)
)

rollout matPicker "Pick the Material"
(
	dropDownList theSets

	on matPicker open do
	(
		tv.enabled=false
		theSets.items=(for it in scenematerials collect it.name)
	)
	on matPicker close do
	(
		if(theSets.selection>0) then
		(
			theObjectSet=tv.selectedNode.tag.value	
			append theObjectSet.mats theSets.selected
		)
		tv.enabled=true
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode
	)
)


rollout layerPicker "Pick Pass Layers" height:260 width:185
(
	Label HintLabel "[Ctrl-Click] To pick multiple layers"
	multiListBox theLayers height:55 width:180 pos:[0,20]

	on layerPicker open do
	(
		theObjectSet=tv.selectedNode.tag.value	
		tv.enabled=false
		fn compareFN v1 v2 = if((LPM_Fun.uppercase v1) < (LPM_Fun.uppercase v2)) then return -1 else return 1

		items=#()
		for i=1 to LayerManager.count do
		(
			layerName = ((LayerManager.getLayer (i-1)).name)
			if (layerName != "zz-LPM") do append items layerName
		)
		qsort items compareFN
		theLayers.items=items
			--now select
		theLayers.selection=(for i=1 to theLayers.items.count where (findItem theObjectSet.layers theLayers.items[i])!=0  collect i)
		
		x=LPM_Fun.getIni "Layer Picker" "X_Size" integer 185
		y=LPM_Fun.getIni "Layer Picker" "Y_Size" integer 260
		
		layerPicker.height=y
		layerPicker.width=x
		theLayers.width=x
	)
	
	on layerPicker close do
	(
		LPM_Fun.setIni "Layer Picker" "X_Size" (layerPicker.width as string)
		LPM_Fun.setIni "Layer Picker" "Y_Size" (layerPicker.height as string)
		
		theObjectSet=tv.selectedNode.tag.value	
		theObjectSet.layers=(for i=1 to theLayers.items.count where theLayers.selection[i] collect theLayers.items[i])
		tv.enabled=true
		thePassNode=tv.selectedNode.parent
		addPassTv thePassNode
	)
	on layerPicker resized theSize do
	(
		theLayers.width=theSize.x
	)
	
)

fn addVisibleLayers=
(
	createDialog layerPicker lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox) pos:(LPM_Fun.getRoPos  layerPicker.width)
)

fn addNamedSet=
(
	createDialog setPicker pos:(LPM_Fun.getRoPos setPicker.width)
)
fn addMats=
(
	createDialog matPicker pos:(LPM_Fun.getRoPos matPicker.width)
)


on tv drawNode arg do
(
	img = dotNetClass "System.Drawing.Image"--create an image
	img2=img.fromFile (GetDir #ui_ln + "icons\\LPM\\Root.Bmp") 
	
	--show arg.Bounds
	theColor=(dotNetClass "System.Drawing.Brushes").Blue
--	arg.Graphics.FillRectangle theColor arg.Bounds
	theFont=dotnetobject "system.drawing.font" (dotnetobject "system.drawing.fontfamily" "tahoma") 8.5  (dotNetClass "system.drawing.fontStyle").bold 
	arg.Graphics.DrawString Arg.Node.text theFont theColor Arg.bounds.Left Arg.bounds.top
	arg.Graphics.drawImage img2 Arg.bounds.Left Arg.bounds.top
)
on tv textChanged arg do
(
	print "changed"
)

dotNetControl editBox "TextBox"  pos:[0,48] height:20 width:120
local doubleClick=false
local rNode=undefined

fn hideEditBox= 
(
	editBox.visible = false
	tv.enabled = true
	tv.refresh()
	tv.focus()
)
fn showEditBox=
(
	if(rNode==undefined) then
		return false
	tv.enabled = false
	editBox.pos = [tv.pos.x+rNode.bounds.x,tv.pos.y+rNode.bounds.y]
	editBox.text = rNode.text
	editBox.visible = true
	editBox.focus()
)
fn renameNode iNode=
(
	rNode=iNode
	showEditBox()
)
on editBox lostFocus e do
(
	hideEditBox()
)

on editBox MouseWheel e do
(
	hideEditBox()
)
on editBox keyUp e do
(
	case e.keycode.tostring() of
	(
		"Return":
		(
			theNode=rNode
			type = theNode.tag.value.type
			word=editBox.text
			if(type=="shot" or type=="pass") then word=LPM_Fun.removeBadChars word

			theNode.text = word
			case type of
			(
				"wildcard": (	theNode.Parent.tag.value.wildCard[theNode.tag.value.index]=word)
				"shot": 
				(
					pos=findstring word "[[" 
					if(pos!=undefined) then
						theNode.tag.value.name="LPM_"+(substring word 1 pos)
					else
						theNode.tag.value.name="LPM_"+word
					theNode.text=LPM_Fun.getShotName theNode.tag.value
				)
				"pass":
				(
					theNode.tag.value.name="LPM_"+word
					updatePassDDL()
				)
				default:	(try(theNode.tag.value.name="LPM_"+word)catch())
				
			)
			hideEditBox()
			--print "editBox: Return Pressed"
		)
		"Escape":
		(
			hideEditBox()
			--print "editBox: Esc Pressed"
		)
	)
)

on tv keyUp e do
(
	theNode=tv.selectedNode

	case e.keycode.tostring() of
	(
		"F2":
		(
			if theNode.level >0 then renameNode (tv.selectedNode)
		)
		"Return":
		(
			if theNode.level >0 then renameNode (tv.selectedNode)
		)
	)
)

on tv BeforeExpand Arg do
(
	if doubleClick then
		arg.Cancel = true
	else
		arg.node.tag.value.expanded=true
	
	doubleClick = false
)

on tv BeforeCollapse Arg do
(
	if doubleClick then
		arg.Cancel = true
	else
		arg.node.tag.value.expanded=false

	doubleClick = false
)

fn hideBySet theSet=
(
	with redraw off
	(
		--collect object nodes array
		objNodes=#()
		objSetArray=#()	
	
		LPM_Fun.getObjectSetArrays LPM_activePass theSet.type &objNodes &objSetArray
		
		if(not keyboard.controlpressed) then
			for theNode in objects where  (classof theNode != Targetobject ) and (superclassof thenode !=camera)  do
				hide theNode
		
		for k=1 to objNodes.count do
		(
			if(objSetArray[k]==theSet) then
			for theNode in objNodes[k] do
			( 
				unhide theNode
			)
			
		)
	)
)

local sTime=timeStamp()
local oldHitNode=undefined

on tv MouseUp arg do 
(
	nTime=timestamp()
	delta=nTime - sTime
	sTime=0 --Assume its an invalid click, if its valid we will the timestamp later
	local button = arg.button.ToString()
	
	--print "Mouse Up"
	hitNode = tv.GetNodeAt arg.location
	--set the pass
	newActive=LPM_Fun.passByNode hitNode
	if(isvalidnode newActive) then
	LPM_activePass=newActive
	updatePassDDL()
	
	if hitNode==undefined then
	(
		if(button=="Middle") then
		(
			max unhide all
		)

	)
	
	if hitNode != undefined then
	(	
		if(button=="Left" or button=="Middle") then
		(
			local level = hitNode.level
			if(arg.x>(38+level*20) and (button=="Left") and (doubleClick==false)) then
			(
				sTime=nTime
				if (delta > 400) and (delta < 1100) and (oldHitNode==hitNode)  then
				(
					print delta
					renameNode hitNode
				)
			)
			
			if((15+level*20) < (arg.x)) and ((arg.x) < (37+level*20)) then
			case hitNode.tag.value.type of
			(
				"pass":
				(
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"objectSet":
				(	
					hitNode.tag.value.intp[1]= (mod (hitNode.tag.value.intp[1])  3) + 1
					LPM_Fun.setIcon hitNode
				)
				"lightSet":
				(	
					hitNode.tag.value.pEnable= (mod (hitNode.tag.value.pEnable)  3) + 1
					LPM_Fun.setIcon hitNode
				)
				"shot":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"renderProps":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"envProps":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"commonProps":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"script":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"passGroup":
				(	
					hitNode.tag.value.active= not hitNode.tag.value.active 
					LPM_Fun.setIcon hitNode
				)
				"ShotPass":
				(
					hitNode.parent.tag.value.passesOn[hitNode.tag.value.index]=hitNode.tag.value.active= not hitNode.tag.value.active
					LPM_Fun.setIcon hitNode	
				)
				
				"xrefLeaf":
				(	
					theFile= hitNode.tag.value.leaf[1]
					it=not hitNode.tag.value.leaf[2]
					hitNode.tag.value.leaf[2]= it
					LPM_Fun.setIcon hitNode
					xrefSceneProps=hitNode.parent.tag.value

					if(it==false) then
						LPM_Fun.pruneArray xrefSceneProps.fileNames theFile
					else
						append xrefSceneProps.fileNames theFile
				)
			)
			
			if(button=="Middle") then
			(
				theMode=getCommandPanelTaskMode()

				if(theMode==#display) then
					setCommandPanelTaskMode #create
				
				case hitNode.tag.value.type of
				(
					"pass":
					(
						hideByActivePass()
						for child in hitNode.tag.value.children where child.type=="generic" do
						(
							op=LPM_Operators.fngetByNode child
							if(op!=0) then
								op.fnPerformAction #middleClick
						)
					)
					"shot":
					(
						if(isvalidnode hitNode.tag.value.displayPass) then
						(	
							LPM_ActivePass=hitNode.tag.value.displayPass
							updatePassDDL()
							hideByActivePass() 
						)	
						cp=LPM_Fun.firstChildByType (hitNode.tag.value) "commonProps"
						if(cp!=undefined) then
						(
							if(cp.cameraTgl==true) then
							(
								try(
										hide cameras
										
										theViewport=viewport.activeViewport
										case LPM_Fun.getIni "Settings" "shotViewport" string "Active Viewport" of
										(
											"Viewport 1": theViewport=1
											"Viewport 2":if(viewport.numviews >= 2) then theViewport=2
											"Viewport 3":if(viewport.numviews >= 3) then theViewport=3
											"Viewport 4":if(viewport.numviews >= 4) then theViewport=4
										)
										viewport.activeViewport=theViewport
										viewport.setCamera cp._Camera
										select cp._Camera
										unhide cp._Camera
										if(isvalidnode cp._Camera.target) then
											unhide cp._Camera.target
									
									)catch()
								
							)
							
							format "before node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
							if(cp.timeOutputTgl) then
							(
								
								case cp._rendTimeType of
								(
									3:(
											if(cp._rendStart < cp._rendEnd ) then
												(
														animationRange = interval cp._rendStart cp._rendEnd
												--	sliderTime=cp._rendStart
												)
										)
								)
								
							)
							format "after node:% start:% end:%\n" cp.name cp._rendStart cp._rendEnd
							
						)
					)
					"layer":
					(
						theLayerName=hitNode.tag.value.leaf
						ctrl= not (keyboard.controlpressed)
						if(ctrl) then
							hide objects
						
						theLayer=layermanager.getlayerfromname theLayerName
						if(theLayer!=undefined) then
						(
							theArray=#()
							theLayer.nodes &theArray
							theLayer.ishidden=false
							unhide theArray
							
						)

						
					)
					"objectSet":
					(
						hideBySet hitNode.tag.value
					)
					"lightSet":
					(
						hideBySet hitNode.tag.value
					)
					"object":
					(
						ctrl= not (keyboard.controlpressed)
						(
							if(ctrl) then
								hide objects
							theNode=hitNode.tag.value.leaf
							
							if(isGroupHead theNode) then
								(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
							unhide hitNode.tag.value.leaf
						)
					)
					"light":
					(
						ctrl= not (keyboard.controlpressed)
						(
							if(ctrl) then
								hide lights
							theNode=hitNode.tag.value.leaf
							
							if(isGroupHead theNode) then
								(for it in (LPM_Fun.getAllChildren theNode) where isgroupmember it do unhide it)
							unhide hitNode.tag.value.leaf
						)
					)
					"wildCard":
					(

						ctrl= not (keyboard.controlpressed)
						if(ctrl) then 
							hide objects
						try(
							unhide (execute ("$"+hitNode.tag.value.leaf))
						)
						catch (messageBox ("wildCard Error"+getcurrentException()))
						
					)
					"namedSet":
					(
						ctrl= not (keyboard.controlpressed)
						if(ctrl) then 
							hide objects
						
						(for item in selectionSets[hitnode.tag.value.leaf] do unhide item)
						
					)
					"mat":
					(
						ctrl= not (keyboard.controlpressed)
						if(ctrl) then 
							hide objects
						local foundMat
						for mat in scenematerials do if(mat.name==hitNode.tag.value.leaf) then foundMat=mat
						if(foundMat!=undefined) then
							for it in objects where it.material==foundMat do unhide it
					)
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #middleClick
					)
				)
				if(theMode==#display) then
					setCommandPanelTaskMode theMode

			)				
		
		)
		
		if(button=="Right") then
		(
				case hitNode.tag.value.type of
				(
					"root":popUpMenu rc_RootMenu
					"pass":popUpMenu rc_PassMenu
					"renderProps":popUpMenu  rc_RenderPropsMenu
					"objectSet":popUpMenu rc_objectSetMenu
					"lightSet":popUpMenu rc_objectSetMenu
					"object":popUpMenu rc_objectMenu
					"light":popUpMenu rc_objectMenu	
					"layer":popUpMenu rc_layerMenu	
					"envProps":popUpMenu rc_atmPropsMenu
					"commonProps":popUpMenu rc_CommonPropsMenu
					"wildCard":popUpMenu rc_wildCardMenu
					"namedSet":popUpMenu rc_namedSetMenu
					"shotRoot":popUpMenu rc_shotRootMenu
					"shot":popUpMenu rc_shotMenu
					"xrefScene":popUpMenu rc_xrefScene
					"ShotPass":popUpMenu rc_shotPassMenu
					"script":popUpMenu rc_scriptMenu
					"passGroup":popUpMenu rc_PassGroup
					"mat":popUpMenu rc_matMenu
					"generic":
					(
						op=LPM_Operators.fngetByNode hitNode.tag.value
						if(op!=0) then
							op.fnPerformAction #rightClick
					)
				)
		)
		tv.selectedNode=hitNode
	)
	else if (button=="Right")  then
		popUpMenu rc_RootMenu
	
	oldHitNode = hitNode
)

on tv MouseDoubleClick arg do
(
	--print "Mouse Double Click"
	doubleClick = true
	hitNode = tv.GetNodeAt arg.Location
	if (hitNode != undefined) then
	(
		if((37 + hitNode.level*20) < arg.x) then
		(
			case hitNode.tag.value.type of
			(
				"root":popUpMenu rc_RootMenu
				"pass":popUpMenu rc_PassMenu
				"renderProps":popUpMenu  rc_RenderPropsMenu
				"objectSet": (	
					createDialog objectSetProps 194 383 pos:(LPM_Fun.getRoPos 194)
				)
				"lightSet": (
					createDialog lightSetProps 194 89 pos:(LPM_Fun.getRoPos 194)
				)
				"object":popUpMenu rc_objectMenu
				"light":popUpMenu rc_objectMenu	
				"layer":popUpMenu rc_layerMenu	
				"envProps": createdialog atmRollout pos:(LPM_Fun.getRoPos  atmRollout.width)
				"commonProps": createDialog commonRollout pos:(LPM_Fun.getRoPos  commonRollout.width)
				"wildCard":popUpMenu rc_wildCardMenu
				"namedSet":popUpMenu rc_namedSetMenu
				"shotRoot":popUpMenu rc_shotRootMenu
				"shot":popUpMenu rc_shotMenu
				"xrefScene":popUpMenu rc_xrefScene
				"ShotPass":popUpMenu rc_shotPassMenu
				"script":popUpMenu rc_scriptMenu
				"passGroup":popUpMenu rc_PassGroup
				"mat":popUpMenu rc_matMenu
				"generic":
				(
					op=LPM_Operators.fngetByNode hitNode.tag.value
					if(op!=0) then
						op.fnPerformAction #edit
				)
			)
		)
	)
)

---DRAG AND DROP----------------

  -- local viariables in the rollout
 local DragNode, DropNode
 local m=dotNetClass "System.Windows.Forms.DragDropEffects" -- Drag and drop effects
 

 -- DRAG AND DROP HANDLERS --
 
 -- START Drag and Drop
 on tv ItemDrag arg do
 (
	 dragnode=arg.item
	 
	 it=arg.item.tag.value.type
	 if(it=="pass") or (it=="shot") or (it=="objectSet") or (it=="lightSet") or (it=="renderProps") or (it=="envProps") or (it=="commonProps") or (it=="xrefScene") or (it=="passGroup") then
		tv.doDragDrop arg.item m.Move -- this actually starts the drag and drop process

 )

 
 -- INSIDE Drag and Drop
 on tv DragOver arg do
 (
	 pos=tv.PointToClient tv.MousePosition -- this gave me a hard time to find out !
	 TestNode= tv.GetNodeAt pos
	 

	 okToDrop=false

	if (testNode != undefined) and (dragNode!=undefined) then -- OK to Drop
	(
		testType=testNode.tag.value.type
		dragType=dragNode.tag.value.type
		if(testType==dragType) and \
		((testType=="objectSet") or (testType=="lightSet") or (testType=="pass") or (testType=="shot") or (testType=="renderProps")or (testType=="passGroup"))	then
			okToDrop=true
		else if(testType=="pass") and (dragType!="shot") and (dragType!="passGroup") then
			okToDrop=true
		else if((testType=="passGroup") or (testType=="root"))and (dragType=="pass") then
			okToDrop=true
		else if(testType=="shot") and (dragType =="commonProps") then
			okToDrop=true
		else if(testType=="shot") and (dragType =="pass") then
			okToDrop=true
	)
	
	 if(okToDrop) then
		 arg.Effect=arg.AllowedEffect
	 else
	 	 arg.Effect=m.none
	 
 )
 
 --reparents the nodes of the selected type
 fn tvReparent tvParent nodeType=
 (
	 nodes=tvParent.nodes
	 for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=undefined
	 
	 if(nodeType=="objectSet") or (nodeType =="lightSet") then--backward for objectSets and lightSets
		for i=0 to (nodes.count-1) where nodes.item[(nodes.count-1)-i].tag.value.type==nodeType do nodes.item[(nodes.count-1)-i].tag.value.parent=tvParent.tag.value
	 else
		for i=0 to (nodes.count-1) where nodes.item[i].tag.value.type==nodeType do nodes.item[i].tag.value.parent=tvParent.tag.value
)
 
 -- END Drag and Drop (drop the item)
 on tv DragDrop arg do
 (
	 pos=tv.PointToClient tv.MousePosition
	 DropNode=tv.GetNodeAt pos
	 if(dragNode!= dropNode) then 
	 (
		if(dragNode.tag.value.type==dropNode.tag.value.type) then--drag pass to pass or set to set\ --drag pass to pass or set to set or shot to a shot
		(
			dragTvParent=dragNode.Parent
			dropTvParent=dropNode.Parent
			if(dragNode.index>dropNode.index) then
			 (
				dragNode.remove() -- need to remove the node from the tree
				dropNode.parent.Nodes.insert dropNode.index dragNode  -- add it to the dropNode children
			)
			 else
			 (
				dragNode.remove() -- need to remove the node from the tree
				dropNode.parent.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children 
			 )
			 dragNode.text=dragNode.text--fix for annoying text cutoff
			 
			 --LPM Data
			tvReparent dragTvParent dragNode.tag.value.type
			 if(dragTvParent!=dropTvParent) then
			 (
				 tvReparent dropTvParent dragNode.tag.value.type
			 )
		)
		else if(dropNode.tag.value.type=="shot") and (dragNode.tag.value.type=="pass") then --dragging pass into a shot
		(
			theShot=dropNode.tag.value
			thePass=dragNode.tag.value
			theShot.allPasses=false
			if(findItem theShot.passes thePass ==0) then
			(	
				append theShot.passes thePass
			)
			addShotTv dropNode
			
		)
		else if(dropNode.tag.value.type=="passGroup" or dropNode.tag.value.type=="root") then--drop a pass onto passGroup
		(
			
			dragNode.remove() -- need to remove the node from the tree
			dragNode.tag.value.parent=dropNode.tag.value
			dropNode.Nodes.insert (dropNode.index+1) dragNode  -- add it to the dropNode children 
			
		)
		
		else if(dropNode.tag.value.type=="pass") or (dropNode.tag.value.type=="shot") then--drop onto a pass or shot
		(
			if(dragNode.tag.value.parent != dropNode.tag.value) then -- dont need to do anything if its just dropping onto itself
			(	
				thePass=dropNode.tag.value
				theNode=dragNode.tag.value
				theType=dragNode.tag.value.type
				
				if (theType=="envProps") or (theType=="commonProps") or (theType=="xrefScene") then
				(
					for it in thePass.children where it.type==theType do --delete the previous nodes of the above types
						delete it					
				)
				if(keyboard.controlpressed) then --copying
				(
					newNode=copy theNode
					newNode.name = theNode.name
					LPM_Fun.addToLPMLayer newNode
					newNode.parent=thePass
				)
				else if (keyboard.shiftpressed) then--instancing
				(
					newNode=instance theNode
					newNode.name=theNode.name
					LPM_Fun.addToLPMLayer newNode
					newNode.parent=thePass
				)
				else --moving
				(
					theNode.parent=thePass
				)

				updateTv()			
			)
		)
	) 
)
on cameraDDL selected it do
(
	if(selected==1) then
		LPM_Root.renderCamera=undefined
	else
		LPM_Root.renderCamera=getNodeByName cameraDDL.items[it]
	updateCameraDDL()
)
 ----------------------------------


fn LPM_Resize theSize=
(
	ySize=((theSize.y - 90) as integer)
	if(ySize<0) then
		ysize=0
	dotNetSize=dotNetObject "System.Drawing.Size" theSize.x ySize
	

	tv.size=dotNetSize
	
	yPos=((theSize.y - 40) as integer)
	renderTypeDDL.pos= [0,yPos]
	localRenderButton.pos=[100,yPos]
	networkRenderButton.pos=[136,yPos]
	openRenderDirButton.pos=[187,yPos]
	supportLPM.pos=[5, yPos+23]

	xSize=((theSize.x))
--row1
	passDDL.width=xSize-128
	hideButton.pos=[xSize-22, hideButton.pos[2]]
	previewSizeDDL.pos=[xSize-62, previewSizeDDL.pos[2]]
	playButton.pos=[xSize-82, playButton.pos[2]]
	colorButton.pos=[xSize-102, colorButton.pos[2]]
	renderPassButton.pos=[xSize-122, renderPassButton.pos[2]]
--row2
	cameraDDL.width=amax #(20, (xSize-103))
	quickScriptsButton.pos=[amax #(20, (xSize-25)),25];
			
)
on LPM_treeview_rollout resized theSize do
(
	LPM_Resize theSize
)

fn LPM_ReadLicense=
(
	true
)
	
on LPM_treeview_rollout open do 
(
	editBox.visible = false
	editBox.borderStyle = (dotNetClass "BorderStyle").FixedSingle

	proMode=LPM_ReadLicense()
	
	if(proMode) then LPM_Treeview_Rollout.title+=" Pro"
	else 
	(
		LPM_Treeview_Rollout.title+=" DEMO"
		if(LPM_AdPopUp==undefined) then
		(	
			purchase()
			global LPM_AdPopUp=false
		)
	)
	
	initTreeView tv
	fillInTreeView tv
	--preview size
	for i=1 to previewSizeDDL.items.count do
		if((LPM_root.previewSize as string)==previewSizeDDL.items[i]) do
			previewSizeDDL.selection=i 
	
	updateCameraDDL()
	renderTypeDDL.selection=LPM_Root.renderType
	--Update the render type
	renderType=getRenderType()
	for i=1 to previewTypeDDL.items.count do
		if(renderType==(previewTypeDDL.items[i] as name)) then previewTypeDDL.selection=i
		
		
	 updateRenderButtonsState()
	LPM_Resize (getDialogSize LPM_Treeview_Rollout)

)
on LPM_treeview_rollout close do
(
	if(colorBackup!=undefined) then
	(
		for item in colorBackup do try(item[1].wirecolor=item[2])catch()
		displayColor.wireframe=displayColorWire
		displayColor.shaded=displayColorShaded
	)
	
	--Store the position/size
	LPM_Fun.setIni "LPM Window" "X_Position" ((GetDialogPos LPM_treeview_rollout)[1] as string)
	LPM_Fun.setIni  "LPM Window" "Y_Position" ((GetDialogPos LPM_treeview_rollout)[2] as string)
	LPM_Fun.setIni "LPM Window" "X_Size" (LPM_treeview_rollout.width as string)
	LPM_Fun.setIni "LPM Window" "Y_Size" (LPM_treeview_rollout.height as string)

	LPM_Fun.destroyAllDialogs()
)

)

if(not (isvalidNode LPM_Root)) then
(
	--create an initialize the root
	
	LPM_Root=LPM_Fun.createNode "Root" "root"
	if(maxfilePath!="") then
		LPM_Root.rootdir=maxfilePath
	else
		LPM_Root.rootdir=(getDir #renderoutput )+"\\"
	LPM_Root.fileType=LPM_Fun.getIni "Settings" "Default Format" string "tga"
	
	pass1=LPM_Fun.createNode "Pass" "pass"
	pass1.active=true
	pass1.parent=LPM_Root
	objectSet=LPM_Fun.createObjectSet "All Objects"
	objectSet.wildcard[1]="*"
	objectSet.parent=pass1
	
	lightSet=LPM_Fun.createLightSet "All Lights"
	lightSet.wildcard[1]="*"
	lightSet.parent=pass1
)

--Initialize pathString
if(LPM_Root.pathString==undefined) then
	LPM_Root.pathString=LPM_Fun.getIni "LPM Render" "Path" string "$Shot\\$Pass\\$Pass_"    


if(	(LPM_Fun.FirstChildByType LPM_Root "shotRoot")==undefined) then
(
	shotRoot=LPM_Fun.createNode "shotRoot" "shotRoot"
	shotRoot.parent=LPM_Root
)

if ((getProperty LPM_Root #version)<2) then
(
	x=queryBox "Unfortunately versions below 0.86 Beta and below are not compatible with versions 0.90 Beta and above.  Fortunately such code breaks such code breaks should not occur in the future.  Delete old LPM Data Yes/No?"
	if(x)==true then
	(
		delete $LPM_Root...*
		messageBox "Old Data Cleared, please relaunch LPM, thank you!"
	)
)
else
(	
	--check/set the name format of all the nodes
	if( not LPM_Root.namesUpdated) then
	(
		theNodes=LPM_Fun.getAllChildren LPM_Root
		for it in theNodes do 
		(	
			if((substring it.name 1 4)!="LPM_") then
				it.name="LPM_"+it.name
		)
		LPM_Root.namesUpdated=true
	)
	--update user props from version 0099
	if(LPM_Root.id <= 0099) then
	(
		theNodes=LPM_Fun.getAllChildren LPM_Root
		for it in theNodes where it.type=="objectSet" do 
		(	
			if(it.userProp=="") then it.userProp=getUserPropBuffer it
		)
	)
	
	xPos=LPM_Fun.getIni "LPM Window" "X_Position" integer 0
	yPos=LPM_Fun.getIni "LPM Window" "Y_Position" integer 0
	sizeX=LPM_Fun.getIni "LPM Window" "X_Size"  integer 200
	sizeY=LPM_Fun.getIni "LPM Window" "Y_Size"  integer 430
	

	if(sizeX==0) then sizeX=200
	if(sizeY==0) then sizeY=430
	createDialog LPM_treeview_rollout pos:[xPos,yPos] height:SizeY width:sizeX menu:rc_MainMenu lockHeight:false lockWidth:false style:#(#style_titlebar,#style_border, #style_sysmenu,#style_resizing,#style_minimizebox)	
)
