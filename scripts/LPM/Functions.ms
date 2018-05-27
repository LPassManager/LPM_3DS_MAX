/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com


Copyright (C) 2018 Lukas Lepicovsky LPM, 3DS Max Pass Manager

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

Struct LPM_Fun_Struct
(
fn destroyAllDialogs=
(
	
	if(LPM_LoadingPreset!=true) and (callbacks.notificationParam()!=2) then
	(
		print "Close LPM Callback"
		--try destroying all dialogs

		try(destroyDialog LPM_renderRo)catch()
		try(destroyDialog LPM_netRenderRo) catch()
		try(destroyDialog LPM_progressRO)catch()
		try(destroyDialog wildCardRO) catch()
		try(destroyDialog atmRollout) catch()
		try(destroyDialog commonRollout) catch()
		try(destroyDialog AboutRo) catch()
		try(destroyDialog savePresetRo) catch()
		try(destroyDialog pickPasses_RO) catch()
		try(destroyDialog objectSetProps)catch()
		try(destroyDialog lightSetProps) catch()
		try(destroyDialog LPM_treeview_rollout)catch()
		callbacks.removeScripts id:#closeLPM
	)
),
fn cleanSet theSet=
(
	theSet.nodes=for it in theSet.nodes where (isvalidnode it) collect it
),

fn firstChildByType theParent type=
(
	for kids in theParent.children where kids.type==type do return kids
	undefined	
),

fn setImageIndex theNode nodeActive iconIndex disabledIndex =
(
	if(nodeActive) then
	(
		theNode.imageIndex=iconIndex
		theNode.selectedImageIndex=iconIndex
	)
	else
	(
		theNode.imageIndex=disabledIndex 
		theNode.selectedImageIndex=disabledIndex 	
	)
),

fn setIcon theNode=
(
	try(
		case theNode.tag.value.type of
		(
			"pass":LPM_Fun.setImageIndex theNode theNode.tag.value.active 1 11
			"objectSet":(
								case (theNode.tag.value.intP[1]) of
								(
									1: LPM_Fun.setImageIndex theNode true 2 2
									2: LPM_Fun.setImageIndex theNode true 12 12	
									3: LPM_Fun.setImageIndex theNode true 13 13	
								)
								
							)
			"lightSet":(
								case theNode.tag.value.pEnable of
								(
									1: LPM_Fun.setImageIndex theNode true 3 3
									2: LPM_Fun.setImageIndex theNode true 14 14	
									3: LPM_Fun.setImageIndex theNode true 15 15	
								)
								
							)
			"wildCard": LPM_Fun.setImageIndex theNode true 6 6
			"namedSet": LPM_Fun.setImageIndex theNode true 5 5
			"layer": LPM_Fun.setImageIndex theNode true 4 4
			"object": LPM_Fun.setImageIndex theNode true 7 7
			"light": LPM_Fun.setImageIndex theNode true 7 7
			"commonProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 10 22
			"renderProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 8 24
			"envProps": LPM_Fun.setImageIndex theNode theNode.tag.value.active 9 23
			"root": LPM_Fun.setImageIndex theNode true 0 0
			"shotRoot":LPM_Fun.setImageIndex theNode true 18 18
			"shot":LPM_Fun.setImageIndex theNode theNode.tag.value.active 16 17
			"ShotPass":LPM_Fun.setImageIndex theNode theNode.tag.value.active 1 11
			"xrefScene":LPM_Fun.setImageIndex theNode true 19 19
			"xrefLeaf":(
								case theNode.tag.value.leaf[2] of
								(
									true: LPM_Fun.setImageIndex theNode true 20 20
									false: LPM_Fun.setImageIndex theNode true 21 21	
								)
							)
			"script":LPM_Fun.setImageIndex theNode theNode.tag.value.active 25 26
			"passGroup":LPM_Fun.setImageIndex theNode theNode.tag.value.active 27 28
		)
	)catch(messagebox "Error setting icon see listener (F11) for details\nThis is often due to a memory allocation in 3ds max")
),

--returns the pass by node
fn passByNode theNode =
(
	if(theNode!=undefined) then
		case theNode.tag.value.type of
		(
			"pass":theNode.tag.value
			"renderProps":theNode.tag.value.parent
			"objectSet":theNode.tag.value.parent
			"lightSet":theNode.tag.value.parent
			"envProps":theNode.tag.value.parent
			"commonProps":theNode.tag.value.parent
			"object":theNode.parent.parent.tag.value
			"light":theNode.parent.parent.tag.value
			"layer":theNode.parent.parent.tag.value
			"wildCard":theNode.parent.parent.tag.value
			"namedSet":theNode.parent.parent.tag.value
			"xrefScene":theNode.parent.tag.value
			"xrefLeaf":theNode.parent.parent.tag.value
			"script":theNode.parent.tag.value
			default:undefined
		)
	else
		undefined
),

--returns the root index of the pass
fn getIndexOfPass thePass =
(
	theRoot=thePass.parent
	j=undefined
	for i=1 to theRoot.children.count do
	(
		if theRoot.children[i]==thePass then
			j=i
	)
	j	
),

fn getAllChildren node=
(
	out=#(node)
	for i=1 to node.children.count do
	(
		join out (LPM_Fun.getAllChildren node.children[i])
	)
	out
),

fn getObjectSetArrays thePass type &objNodes &objSetArray=
(
	
	i=0
	objNodes=#()
	objSetArray=#()	
	
	--collect object nodes array
	
	for objSet in thePass.children where objSet.type==type do
	(
		i+=1
		tmpCollection=#()
		objSetArray[i]=objSet
	--named sets
		for it in objSet.namedSet do
		(
			join tmpCollection (for item in selectionSets[it] collect item)
		)
	--wildcard
		for j=1 to objSet.wildCard.count do
		(
			try(
					if(objSet.wildCard[j]!="") then
						join tmpCollection (execute ("$"+objSet.wildCard[j]))
					)
					catch (messageBox ("wildCard Error"+getcurrentException()))
		)

-- Mats
		for matName in objSet.mats do
		(
			for sceneMat in scenematerials where (matName==sceneMat.name) do 
				for it in objects where it.material==sceneMat do append tmpCollection it
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
		--remove invalid nodes
		LPM_Fun.cleanSet objSet
		--object sets
		join tmpCollection objSet.nodes


		
		for theGroup in objSet.nodes where (isGroupHead theGroup) do
		(	
			join tmpCollection (for it in (LPM_Fun.getAllChildren theGroup) where isgroupmember it collect it)
			
		)
		
		if(type=="objectSet") then
			objNodes[i]=for it in tmpCollection where ((((superClassof it) ==geometryClass) or ((superClassof it) ==shape) or ((classof it) ==Container)) and (not (iskindof it particleGroup))) collect it
		else
			objNodes[i]=for it in tmpCollection where (((superClassof it) ==light) and(not(iskindof it target)))collect it
	)
),

fn pruneArray theArray theItem=
(
	index=1
	
	while index <= theArray.count do
	(
		if(theArray[index]==theItem) then
			deleteItem theArray index
		else
			index+=1	
	)
	theArray
),

fn getShotName theShot=
(
	base=LPM_Fun.getName theShot.name
	if(isvalidnode theshot.displayPass) then
		base+="[["+(LPM_Fun.getName theshot.displayPass.name) +"]]"
	base
),

fn saveRenderPreset =
(
	LPM_LoadingPreset=true
	case (classof renderers.current) of
	(
		Default_Scanline_Renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		mental_ray_renderer: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32,33,34}
		Default: renderpresets.Save 0 ((getdir #temp) +"\\temp.rps") #{32}
	)
	
	
	aa=fopen ((getdir #temp) +"\\temp.rps") "r"
	theSize= getFileSize ((getdir #temp) +"\\temp.rps")
	theArray=#()
	for i=1 to theSize do
	(
		theArray[i]=(ReadByte aa #unsigned)
	)
	
	fclose aa
	LPM_LoadingPreset=false
	theArray
	
),

fn loadRenderPreset theArray =
(
	LPM_LoadingPreset=true
	bb=fopen ((getdir #temp)+"\\temp2.rps")  "wb"
	for i=1 to theArray.count do
	(
		WriteByte bb theArray[i] #unsigned
	
	)
	fflush bb
	fclose bb
	
	renderpresets.LoadAll 0 ((getdir #temp)+"\\temp2.rps")
	LPM_LoadingPreset=false
),

fn addToLPMLayer theNode=
(
	theLayer=LayerManager.getLayerFromName "zz-LPM"
	if(theLayer==undefined) then
	(	
		theLayer=LayerManager.newLayer()
		theLayer.setName "zz-LPM"
		theLayer.ishidden = true
		theLayer.isfrozen =true
	)
	theLayer.addNode theNode
),

fn createNode pName type=
(
	theNode=dummy()
	theNode.pos=[0,0,-1000]
	LPM_Fun.addToLPMLayer theNode

	case type of
	(
		"root":custAttributes.add theNode rootCA
		"pass":custAttributes.add theNode passCA
		"renderProps":custAttributes.add theNode renderPropsCA
		"envProps":custAttributes.add theNode envEffectCA
		"commonProps":custAttributes.add theNode commonPropsCA
		"objectSet":custAttributes.add theNode objectSetCA
		"lightSet":custAttributes.add theNode lightSetCA
		"shotRoot":custAttributes.add theNode LPM_shotRootCA
		"shot":custAttributes.add theNode LPM_shotCA
		"xrefScene":custAttributes.add theNode LPM_XrefSceneCA
		"script":custAttributes.add theNode LPM_ScriptCA
		"passGroup":custAttributes.add theNode LPM_passGroupCA
		"empty":custAttributes.add theNode LPM_emptyCA
	)
	
	pName="LPM_"+pName
	theNode.type=type
	
	if(type=="pass") or (type=="shot") or (type=="passGroup") then
		theNode.Name=uniqueName pName
	else
		theNode.name=pName

	theNode
),

fn createPass LPM_Root=
(
	pass=LPM_Fun.createNode "Pass" "pass"
	pass.active=true
	pass.parent=LPM_Root
	pass.rootdir=(getdir #renderoutput)+"\\"
	pass.hideMode=(LPM_Fun.getIni "Settings" "objectSetDefaultHideMode" integer 1)
	pass
	
),

fn createObjectSet theName=
(
		objectSet=LPM_Fun.createNode theName "objectSet"
		objectSet.pColor=Color (random 0 200) (random 0 200) (random 0 200)
		objectSet.intP=#((LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 2), 1, 1, 1, 1, 1, 1, 1, 1, 1)
		objectSet
),

fn createLightSet theName=
(
		lightSet=LPM_Fun.createNode theName "lightSet"
		lightSet.pEnable=(LPM_Fun.getIni "Settings" "objectSetDefaultValue" integer 2)
		lightSet.pCastShadows=1
		lightSet.pColorEnable=false
		lightSet.pColor=white
		lightSet
),

fn createShot LPM_Root=
(
		shotRoot=LPM_Fun.firstChildByType LPM_Root "shotRoot"
		
		shot=LPM_Fun.createNode "Shot" "shot"
		shot.active=true
		shot.parent=shotRoot
		
		theProps=LPM_Fun.createCommonProps "common props"
		theProps.parent=shot
		theProps.autoUpdateName=true
		theProps.name=LPM_Fun.generateCommonPropName theProps
		
		shot
	
),

fn createScript theName=
(
	script=LPM_Fun.createNode theName "script"
	script.active=true
	script.script=""
	script
	
),

fn createPassGroup theName=
(
	passGroup=LPM_Fun.createNode theName "passGroup"
	passGroup.active=true
	passGroup
),

fn createCommonProps theName=
(
	cp=LPM_Fun.createNode theName "commonProps"	
	cp._rendTimeType=rendTimeType
	cp._rendNThFrame=rendNThFrame
	cp._rendStart=rendStart
	cp._rendEnd=rendEnd
	cp._rendFileNumberBase=rendFileNumberBase
	cp._renderHeight=renderHeight
	cp._renderWidth=renderWidth
	cp._RendApertureWidth=getRendApertureWidth()
	cp._renderPixelAspect=renderPixelAspect
	cp._rendPickupFrames=rendPickupFrames
	cp._rendAtmosphere=rendAtmosphere
	cp._renderEffects=renderEffects 
	cp._renderDisplacements=renderDisplacements
	cp._rendColorCheck=rendColorCheck
	cp._rendFieldRender=rendFieldRender
	cp._rendHidden=rendHidden
	cp._rendSimplifyAreaLights=rendSimplifyAreaLights
	cp._rendForce2Side=rendForce2Side
	cp._rendSuperBlack=rendSuperBlack
	cp._useAdvancedLighting=RadiosityPreferences.useAdvancedLighting
	cp._computeAdvancedLighting=RadiosityPreferences.computeAdvancedLighting
	cp.initialized=true
	cp._fileType=""
	cp.preScript=""
	cp.postScript=""
	cp
),

fn editLabelByNode target tvRoot=
(
	for i=0 to (tvRoot.nodes.count-1) do
	(
		newNode=tvRoot.nodes.item[i]
		if(newNode.tag.value==target) then
			LPM_Treeview_Rollout.renameNode newNode
		
		for j=0 to (newNode.nodes.count-1) do
		if(newNode.nodes.item[j].tag.value==target) then
			LPM_Treeview_Rollout.renameNode newNode.nodes.item[j]
	)
),

--converts "1-4,5" to #(#(1,4), #(5)) undefined if invalid
fn stringToFrames theString=
(
	if not(iskindof theString string) then
		return undefined
	theArray=filterString theString ","
	flag=false
	for i in theArray collect
	(	
		it=filterString i "-"
		newItem=for j in it collect
			j as integer
		for j in newItem where j==undefined do
			return undefined
		newItem
	)
),

--gets the active time type and converts it to a string
fn convertRendTimeTypeToString=
(
	theString="0"
	case rendTimeType of
	(
		1: theString=(currenttime as integer/ticksperframe) as string
		2: theString=((animationrange.start as integer/ticksperframe) as string) + "-" +((animationrange.end as integer/ticksperframe) as string)
		3: theString=((rendstart as integer /ticksperframe) as string) + "-" +((rendend as integer/ticksperframe) as string)
		4: theString=rendPickupFrames
	)
	theString
),

fn removeBadChars theString illegalChars:undefined=
(
	if(illegalChars==undefined) then
		illegalChars="\/:?*\"|<>"
	newString=""
	for i=1 to theString.count do 
		if(findstring illegalChars theString[i])==undefined then newString+=theString[i]
	newString
	
),

fn getPassPath theRoot thePass theShot:undefined previewMode:false elementName:""=
(

	fn replaceByString original findStr replaceStr=
	(
		theString= copy original
		x=findString theString findStr
		safety=0
		while(x!=undefined) and (safety<1000)do
		(
			theString=replace theString x findStr.count replaceStr  		
			safety+=1
			x=findString theString findStr
		)
		theString
	)
	--Cameras----------------------------------------
	cameraString="Active_Cam"
	if(isValidNode LPM_Root.renderCamera) then
		cameraString=LPM_Root.renderCamera.name
	
	cp=LPM_Fun.firstChildByType thePass "commonProps"
	if(cp!=undefined) and (cp.cameraTgl) and (isValidNode cp._Camera) then
		cameraString=cp._Camera.name
	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.cameraTgl) and (isValidNode cp._Camera) then
			cameraString=cp._Camera.name
	)
	
	thePath=""
	pathString=copy theRoot.pathString
	pathString=replaceByString pathString "$Cam" cameraString
	
	if(maxFileName=="") then
		pathString=replaceByString pathString "$Max" "Unsaved_Maxfile"
	else
		pathString=replaceByString pathString "$Max" (substring maxFileName 1 (maxFileName.count - 4))
	if(theShot==undefined) then
		pathString=replaceByString pathString "$Shot" ""
	else
		pathString=replaceByString pathString "$Shot" (LPM_Fun.getName theShot.name)
	
	pathString=replaceByString pathString "$Pass" (LPM_Fun.getname thePass.name)
	if((matchpattern pathString pattern:"*$Element*") ==false) then
	(
		pathString+=ElementName
	)
	pathString=replaceByString pathString "$Element" elementName
	if(previewMode) then
		pathString="(Root)\\"+pathString
	else
	(	
		if(thePass.useRootDir) then
			pathString=thePass.rootDir+pathString
		else
			pathString=theRoot.rootdir+pathString
		
	)
	--gets rid of extraneous blackslashes
	
	isUNC=false
	if(pathString[1]=="\\" and pathString[2]=="\\") then
		isUNC=true
	
	theArray=filterString pathString "\\"
	pathString=""
	for i=1 to (theArray.count - 1) do
		pathString+=theArray[i]+"\\"
	
	pathString+=theArray[theArray.count]
	if(isUNC) then pathString="\\\\"+pathString
	

	--filetype----------------------------------------------------	
	if(LPM_Root.fileType==undefined) then LPM_Root.fileType="tga"
	theFileType=LPM_Root.fileType
	cp=LPM_Fun.firstChildByType thePass "commonProps"
		if(cp!=undefined) and (cp.fileTypeTgl) then
			theFileType=cp._fileType
	
	if(theShot!=undefined) then
	(
		cp=LPM_Fun.firstChildByType theShot "commonProps"
		if(cp!=undefined) and (cp.fileTypeTgl) then
			theFileType=cp._fileType
	)
	
	if(previewMode) then
		pathString+="####."+theFileType
	else
		pathString+="."+theFileType
	if not(previewMode) then
		makeDir (getFilenamePath pathString) all:true
	
	pathString
),

fn uppercase instring = -- beginning of function definition
( 
	local upper, lower, outstring -- declare variables as local
	upper="ABCDEFGHIJKLMNOPQRSTUVWXYZ" -- set variables to literals
	lower="abcdefghijklmnopqrstuvwxyz"
	outstring=copy instring
	for i=1 to outstring.count do
	( j=findString lower outstring[i]
	if (j != undefined) do outstring[i]=upper[j]
	)
	outstring -- value will be returned as function result
), 

fn convertTimeToString frame baseNumber =
(
	intFrame= (frame as integer)/ticksperframe
	intFrame+=baseNumber
	stringFrame=intFrame as string
	numZeros=(4- stringFrame.count)
	if(intFrame>=0) then
		case numZeros of
		(
			1: stringFrame="0"+stringFrame
			2: stringFrame="00"+stringFrame
			3: stringFrame="000"+stringFrame
		)
			
	else
	(		
		case numZeros of
		(	
			1:( 
				stringFrame=subString stringFrame 2 -1
				stringFrame="-0"+stringFrame
				)
			2: (
				stringFrame=subString stringFrame 2 -1
				stringFrame="-00"+stringFrame
				)
		)
	)
	stringFrame
),

fn getIni category theKey defaultType defaultValue=
(
	val=getINISetting ( getdir #plugcfg + "\\LPM.ini" ) category theKey
	if(val=="" )then
		defaultValue
	else
		val as defaultType
),

fn setIni category theKey theValue=
(
	setINISetting ( getdir #plugcfg + "\\LPM.ini" ) category theKey (theValue as string)
),

fn getProp theNode theKey defaultType defaultValue=
(
	val = getUserProp theNode theKey
	if (val=="") or (val==undefined) then
		defaultValue
	else
		val as defaultType	
),

fn setProp theNode theKey theValue=
(
	setUserProp theNode theKey (theValue as string)
),

fn getName theString=
(
	substring theString 5 -1
),

fn generateCommonPropName cp=
(
	theName=""
	if(cp.autoUpdateName==false) then
		theName=(LPM_Fun.getName cp.name)
	else
	(
		if(cp.	cameraTgl) then
			if(isvalidNode cp._camera) then
				theName+=cp._camera.name+" "
			else
				theName+="Invalid Camera "			
		if(cp.timeOutputTgl) then
			case cp._rendTimeType of
			(
				1: theName+="Single "
				2: theName+="Active Segment "
				3: theName+="["+(((cp._rendStart as integer)/ticksperframe) as string)+","+(((cp._rendEnd as integer)/ticksperframe) as string)+"] "
				4: theName+="{"+cp._rendPickupFrames+"} "
			)
		if(		cp.outputSizeTgl ) then
			theName+="("+(cp._renderWidth as string )+"x"+(cp._renderHeight as string)+")"
		if(cp.usePreScript) then
			theName+=" |Pre|"
		if(cp.usePostScript) then
			theName+=" |Post|"
	)
	if(theName=="") then
		theName="Common (Auto-Name)"
	theName
),

renderBarProgress,

fn init_LPM_renderProgress_Ro thePass theShot =
(
	global  LPM_renderProgress_Ro
	rollout LPM_renderProgress_Ro  "LPM Render Progress" width:200 height:95
	(
		label shotLabel "Shot: --" align:#left
		label passLabel "Pass:" align:#left
		label escLabel "Hold Esc to cancel all Passes/Shots." align:#left
		progressBar theBar
		hyperlink warning "No Warnings/Errors" color:(color 6 135 6)
	)
	
	createDialog LPM_renderProgress_Ro pos:(LPM_FUN.getROPos LPM_renderProgress_Ro.width)
	
	if(isvalidnode theShot) then
		LPM_renderProgress_Ro.shotLabel.text="Shot:"+(LPM_Fun.getname theShot.name)
	
	LPM_renderProgress_Ro.passLabel.text="Pass:"+(LPM_Fun.getname thePass.name)
	
	if(renderBarProgress!=undefined) then
		LPM_renderProgress_Ro.theBar.value=renderBarProgress
),

fn getROPos dialogWidth=
(
	
	left=LPM_Fun.getIni "Settings" "dialogAlignLeft" booleanClass true

	thePos=(point2 0 0)
	if(LPM_Treeview_rollout!=undefined) and (LPM_Treeview_rollout.open) then
	(
		thePos=(GetDialogPos LPM_Treeview_rollout)
	)

	if(thePos.x<dialogWidth) then
		left=false
	
	if(left) then
		thePos=thePos-[dialogWidth,0]
	else
		thePos=thePos+[LPM_Treeview_Rollout.width,0]
	thePos

),

fn launchNetworkRender=
(
	if(maxfilepath=="") then
	(
		messagebox "Please save the max file before a net render"
		return false
	)
	
	theNetworkType=LPM_Fun.getIni "Settings" "Network Type" string "Backburner"
	plug=0
	for it in LPM_NetworkPlugins where it.type==theNetworkType do
		plug=it
	if(plug==0) then
	(
		messagebox ("Could not find network submission plugin:"+theNetworkType)
		return false
	)
	
	result=plug.submit()
	if(result!=#SUCCESS) then
	(
		messagebox result
	)
	
),

/*
mode:#preview, #previewHalf, #local, #backburner, #maxfile, #hwPreview
renderCollect:(#(pass), #(pass,shot))
*/
whoToRender=#(),

fn renderSubmit mode netRenderSettings:undefined=
(
	renderCollect=whoToRender
	
	flag=true
	for i=1 to renderCollect.count where flag do
	(
		LPM_Fun.renderBarProgress=(100*(i-1))/renderCollect.count
		LPM_renderPass renderCollect[i][1] mode theShot:renderCollect[i][2] netRenderSettings:netRenderSettings
		if(keyboard.escPressed) then flag=false
	)
),

fn collectPasses activeOnly:true theShot:undefined=
(
	o=not activeOnly
	renderCollect=#()
	
	for pg in LPM_Root.children where (pg.type=="passGroup" and (pg.active or o)) do
		for thePass in pg.children where  (isvalidnode thePass) and (thePass.type=="pass") and (thePass.active or o)  do append renderCollect #(thePass, theShot)
	for thePass in LPM_Root.children where (thePass.type=="pass") and (thePass.active or o)  do append renderCollect #(thePass, theShot)
	renderCollect
),

fn setWhoToRenderByRenderType=
(
	
	renderCollect=#()
	shotRoot=(LPM_Fun.firstChildByType LPM_Root "shotRoot")
	
	if(LPM_Root.renderType <=2) then
	(
		renderCollect=collectPasses()
	)
	else
	(
		for theShot in shotRoot.children  where (theShot.type=="shot") and (theShot.active) do
			(

				if(theShot.allpasses) then
				(
					join renderCollect (collectPasses activeOnly:false theShot:theShot)
				)
				else
					for i=1 to theShot.passes.count  where  (isvalidnode theShot.passes[i])  and (theShot.passesOn[i]==true) do append renderCollect #(theShot.passes[i], theShot)
			)
	)
	LPM_Fun.whoToRender=renderCollect
),

fn getWhoToRender=
(
	return LPM_Fun.whoToRender
),


fn localRenderSubmit=
(
	if(LPM_Root.renderType==2) or (LPM_Root.renderType==4) then
		renderFlag=#hwPreview
	else
		renderFlag=#local
	
	renderSubmit renderFlag
	
	LPM_Fun.renderBarProgress=undefined
),

fn getPreviewFile thePass=
(

	(getDir #preview)+"\\"+maxFileName+"_"+"\\"+(LPM_Fun.getname thePass.name)+"_."+(LPM_Fun.getIni "Settings" "Default Format" string "tga")
	
),


fn viewRamPlayer thePath=
(
	try(

		if(thePath!=undefined) then
		(
			fileList= getfiles ((getFilenamePath thePath) + (getFileNameFile thePath) + "*" + (getFileNametype thePath))
			if(fileList.count!= 0) then
			(
				out=createFile ((getdir #preview) + "\\LPM_IFL.ifl")
				if(out!=undefined) then
				(
					for it in fileList do format "%\n" it to:out
					close out
					ramplayer ((getdir #preview) + "\\LPM_IFL.ifl") ""
				)
			)
			else
			(
				throw "Files not found."
			)
		)
	) catch (messagebox (getcurrentexception()) title:"RamPlayer Load")
),

fn quickScripts=
(
	global LPM_QuickScripts
	pathString=::LPM_DIR+"quickscripts\\";
	
	--right click menu for passes-
	RC="rcMenu LPM_QuickScripts (\n"
	count=0;
	theDirs=getdirectories (pathString+"*")
	--load all the subfolders
	appendLater=""
	for fit in theDirs do
	(
		subName=(substring fit (pathString.count+1) (fit.count-pathstring.count-1))
		RC+="subMenu \""+subName +"\"\n"
		RC+="(\n"
		theFiles=getFiles (fit+"*.ms")
		for it in theFiles do
		(
			RC+="menuItem "+("a"+count as string)  +" \"" +(getFileNameFile it) +"\";\n"
			appendLater+="on "+("a"+count as string)  + " picked do try(filein @\""+ it +"\")catch(Messagebox \"Error Loading Script\");\n"
			count+=1;
		)
		RC+=")\n"
	)
	
	RC+=appendLater
	theFiles=getFiles (pathString+"*.ms")
	for it in theFiles do
	(
		RC+="menuItem "+("a"+count as string)  +" \"" +(getFileNameFile it) +"\";\n"
		RC+="on "+("a"+count as string)  + " picked do try(filein @\""+ it +"\")catch(Messagebox \"Error Loading Script\");\n"
		count+=1;
	)
	
	RC+="Seperator s1\n"
	RC+="menuItem AddNewScriptsHere \"Add New Scripts here...\";\n"
	RC+="on AddNewScriptsHere picked do shellLaunch @\"" + pathString + "\" \"\";\n"
	RC+=")\n"
	execute RC
	popUpMenu LPM_QuickScripts
)

)

LPM_Fun=(LPM_Fun_Struct())
