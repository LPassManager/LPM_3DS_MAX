/*
Title     :  RenderPreset operator for LPM 1.09+*
			- Stores render's parameters.
			- Support all possible renderers. 

Copyright :  2010-2014 veda3d.com
Author    : Royal Ghost

Version   : 0.4.0
						- Added better support for for all possible renderers.
						- Added support for VFB+ (Color Correction, Stamper) parameters (http://www.monotoneminimal.com/vfb)
						- Added "Class" UI column 
Version   : 0.3.1
						- Support for 3dsmax 2014
						- Added missed function which caused operator error 
Version   : 0.3.0
						- Added support of Mental Ray String Options (3ds max 2011+ http://docs.autodesk.com/3DSMAX/15/ENU/MAXScript-Help/index.html?url=files/GUID-F64266AA-19D7-4F81-A3A7-90152F50F232.htm,topicNumber=d30e786007) 
						- Stored MR String Options params highlighted by different color
						- UI Columns width stored in INI
Version   : 0.2.0		
						- Restore original renderer params after render.
						- Store RenderPreset window position and size.
						
Version   : 0.1.3		
						- Fixed "Apply".
						- Sorting tables
Version   : 0.1.2
						- Added "Apply..." button. Allows to apply stored parameters to current render setup.
Version   : 0.1.1	
						- Fixed filenames parsing.
						- Found serious bug in LPM v1.096 Pro (CA.ms). For proper work of this plugin, patched CA.ms MUST be installed.
Version   : 0.1.0
						- First alpha release
						- Known limitations:
						- Tested only on 3dsmax 2011 Mental Ray
						- Shaders in Mental Ray setup are NOT SUPPORTED (camera shaders,material override,contours)
						- When pass render is finished applied parameters are not restored.
						
Usage	    : 			
						1. Add custom operator "RenderPreset" in LPM
						2. Right click on added "RenderPreset" -> Edit
						3. Press "Store..." button.
			
Homepage  : http://veda3d.com

* LPM - Lukas Lepicovsky's LPass Manager www.lukashi.com
*/

/*OPERATORS*/
--All operators MUST implement the following:
--self (Pointer to the instance of the struct)
--INode (Pointer to the node holding the data)
--fnGetSubType (The type of the operator, alphaCharacters only, no spaces
--fnPerformAction (Function that takes as input a action type), return #NOT_IMPLEMENTED if I a function is not implemented


struct LPM_renderPresetsOperator
(
	
	self,
	INode=0,--Required
	fn fnGetSubType=--Required
	(
		return "RenderPreset"
	),
	-- Custom data for the operator
--	myObject=undefined,
	rendererPlugin_arry=#(),
	rendererPreset_arry=#(),
	rendererMRCustomPreset_arry=#(),
	rendererVFBPlusPreset_arry=(),
	rendererPluginCurrent_arry=#(),
	rendererCurrent_arry=#(),
	rendererMRCustomCurrent_arry=(),
	rendererVFBPlusPresetCurrent_arry=(),
	isLoaded=false,
	UI_MRCustomColor = color 0 136 183,
	UI_VFBPlusColor = color 0 78 150,
	--Save and store functions for the custom data
	fn fnload =
	(
		if(isLoaded==false) then
		(
			if(isvalidnode INode) then
			(
--				print "load"
--				myObject=INode.getValue "myObject" undefined
-- 				print "load"
-- 				print rendererPreset_arry.count
				rendererPlugin_arry=INode.getArray "rendererPlugin_arry" #()
				rendererPreset_arry=INode.getArray "rendererPreset_arry" #()
				rendererMRCustomPreset_arry = INode.getArray "rendererMRCustomPreset_arry" #()
				rendererVFBPlusPreset_arry = INode.getArray "rendererVFBPlusPreset_arry" #()
-- 				print rendererPreset_arry.count
-- 				print "end load"
			)
			isLoaded=true
		)
	),
	
	fn fnStore =
	(
		if(isvalidnode INode) then
		(
--			print "store"
--			print rendererPreset_arry
			
--			INode.setValue "myObject" myObject

-- 			print "store"
-- 			print rendererPreset_arry.count
			INode.setArray "rendererPlugin_arry" rendererPlugin_arry
			INode.setArray "rendererPreset_arry" rendererPreset_arry
			INode.setArray "rendererMRCustomPreset_arry" rendererMRCustomPreset_arry 
			INode.setArray "rendererVFBPlusPreset_arry" rendererVFBPlusPreset_arry 
-- 			print rendererPreset_arry.count
-- 			print "end store"

		)
	),
	--Actions
	fn fnRendererPreset=
	(
		--Make sure we at least loaded...
--		print "fnRendererPreset"
		self.rendererPluginCurrent_arry = self.fnCollect_RendererPlugin()
		self.fnApply_RendererPlugin self.rendererPlugin_arry
		
		self.rendererCurrent_arry = self.fnCollect_RendererParams()
		self.fnApply_RendererParams self.rendererPreset_arry
		
		self.rendererMRCustomCurrent_arry = self.fnCollect_RendererMRCustomParams()
		self.fnApply_MRCustomRendererParams self.rendererMRCustomPreset_arry
		
		self.rendererVFBPlusPresetCurrent_arry = self.fnCollect_RendererVFBPlusParams()
		self.fnApply_VFBPlusRendererParams self.rendererVFBPlusPreset_arry
	),
	--#postRender
	fn fnRendererPresetRestore =
	(
--	print "Function called after render. Restore stored params!"
		if renderscenedialog.isopen() == true then -- render scene dialog must be closed!
		(
		renderscenedialog.close()
		self.fnApply_RendererPlugin self.rendererPluginCurrent_arry
		
		self.fnApply_RendererParams self.rendererCurrent_arry
		self.fnApply_MRCustomRendererParams self.rendererMRCustomCurrent_arry
		--self.fnApply_VFBPlusRendererParams self.rendererVFBPlusPresetCurrent_arry -- not need to be restored
		renderscenedialog.open()
		)
		else
		(
		self.fnApply_RendererPlugin self.rendererPluginCurrent_arry
		self.fnApply_RendererParams self.rendererCurrent_arry
		self.fnApply_MRCustomRendererParams self.rendererMRCustomCurrent_arry
		--self.fnApply_VFBPlusRendererParams self.rendererVFBPlusPresetCurrent_arry  -- not need to be restored			
		)
	),
	
	fn fnApply_RendererPlugin params_arry =
	(
	if params_arry[1] != undefined and params_arry[1] != ((classof renderers.current) as string) then renderers.current = (execute (params_arry[1]+"()"))
	),
	
	fn fnApply_RendererParams params_arry =
	(
		if params_arry.count > 0 then
		(
			for i = 1 to params_arry.count do
			(
				try -- read-only properties
				(
				tmpProp = getProperty renderers.current params_arry[i][1]
				tmpPropVal = params_arry[i][2]

					case ((superclassof tmpProp) as string) of
					(
					"filter":(setProperty renderers.current params_arry[i][1] (execute(tmpPropVal+"()")))
					default:
							(
								case ((classof tmpProp) as string) of
								(
								"Integer":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								"Float":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								"BooleanClass":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								"String":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								"Color":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								"Name":(setProperty renderers.current params_arry[i][1] tmpPropVal)
								default:(
											--format "%; %; %; %\n" params_arry[i] tmpProp (classof tmpProp) (superclassof tmpProp)
											)
								)
							)
					)
				)catch()
			)
		)
	),

	fn fnApply_MRCustomRendererParams cust_params_arry =
	(
	maxv = maxVersion()
	
		if classof renderers.current == mental_ray_renderer and maxv[1] >= 13000 then
		(
		local m = mental_ray_string_options
			for i = m.numOptions to 1 by -1 do --format "% %\n" (m.GetOptionString i) (m.GetOptionValue i)
			(
			m.RemoveOption i
			)
			for i = 1 to cust_params_arry.count do
			(
			m.AddOption cust_params_arry[i][1] cust_params_arry[i][2]
			)
		)
	),
	fn fnApply_VFBPlusRendererParams cust_params_arry =
	(
		if VFBPlus2ColorCorrection != undefined and VFBPlus2Stamper != undefined then
		(
			for i = 1 to cust_params_arry.count do
			(
				case cust_params_arry[i][3] of
				(
				1: setProperty VFBPlus2ColorCorrection cust_params_arry[i][1] cust_params_arry[i][2]
				2: setProperty VFBPlus2Stamper cust_params_arry[i][1] cust_params_arry[i][2]
				)
			)
		)
		else
		(
		format "RenderPreset Operator: Preset contains VFBPlus parameters, VFBPlus plugin not found, VFB parameters not applied!\n"	
		)
	),
	
	fn fnCollect_RendererPlugin = 
	(
	local RendererPlugin_arry =#()
	append RendererPlugin_arry ((classof renderers.current) as string)
	return RendererPlugin_arry
	),
	fn fnCollect_RendererParams =
	(
	local rend_params_names_arry = #()
	local rend_params_arry	= #()
	rend_params_names_arry = getPropNames renderers.current
		
		for i = 1 to rend_params_names_arry.count do
		(
			tmpProp = getProperty renderers.current rend_params_names_arry[i]
			case rend_params_names_arry[i] of -- ignored parameters
			(
			#HardwareReport:() -- iray
			default:(
							case ((superclassof tmpProp) as string) of
							(
							"filter":(append rend_params_arry (#((rend_params_names_arry[i]), (classof (getProperty renderers.current rend_params_names_arry[i]))as string)))
							default:
									(
										case ((classof tmpProp) as string) of
										(
										"Integer": (append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										"Float":(append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										"BooleanClass":(append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										"String":(append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										"Color":(append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										"Name":(append rend_params_arry (#((rend_params_names_arry[i]), (getProperty renderers.current rend_params_names_arry[i]))))
										default:(
													--format "RenderPreset: not supported property - %; %; %; %\n" rend_params_names_arry[i] tmpProp (classof tmpProp) (superclassof tmpProp)
													)
										)
									)
							)
						)
			)
		)
	return rend_params_arry
	),
	fn fnCollect_RendererMRCustomParams =
	(
	maxv = maxVersion()
	local rend_MRCustom_params_arry =#()
		
		if classof renderers.current == mental_ray_renderer and maxv[1] >= 13000 then
		(
		local m = mental_ray_string_options
			if m.numOptions > 0 then 
			(
				for i = m.numOptions to 1 by -1 do --format "% %\n" (m.GetOptionString i) (m.GetOptionValue i)
				(
				append rend_MRCustom_params_arry #((m.GetOptionString i),(m.GetOptionValue i))
				)
			)
		)
	return rend_MRCustom_params_arry
	),
	fn fnCollect_RendererVFBPlusParams =
	(
		local propsArry = #()
		local rend_VFBPlus_params_arry =#()
		if VFBPlus2ColorCorrection != undefined then
		(
		propsArry = getPropNames VFBPlus2ColorCorrection
			
			for i = 1 to propsArry.count do
			(
			append rend_VFBPlus_params_arry #(propsArry[i],(getProperty VFBPlus2ColorCorrection propsArry[i]),1)
			)
			
		if VFBPlus2Stamper != undefined then
		(
		propsArry = getPropNames VFBPlus2Stamper
			
			for i = 1 to propsArry.count do
			(
			append rend_VFBPlus_params_arry #(propsArry[i],(getProperty VFBPlus2Stamper propsArry[i]),2)
			)			
		)
		)
		
	return rend_VFBPlus_params_arry
	),
	--#Edit
	fn fnEdit =
	(
		try(destroyDialog RenderPreset_rollout)catch()
		global lvstuff = ListViewOps()

		
		rollout RenderPreset_rollout "Render Preset" width:720 height:320
		(
			local self
			button btn_store "Store..." pos:[8,8] width:88 height:24
			button btn_apply "Apply..." pos:[104,8] width:88 height:24
			local flip = true
			dotNetControl lv "Listview" pos:[8,40] width:704 height:272 --pos:[5,5,0]
--			button btn_store "Store..." pos:[8,8] width:144 height:32
			
			fn fnSetINI category theKey theValue =
			(
			setINISetting ( getdir #plugcfg + "\\LPM_RenderPreset.ini" ) category theKey (theValue as string)	
			)
			fn fnGetINI category theKey defaultType defaultValue=
			(
				val=getINISetting ( getdir #plugcfg + "\\LPM_RenderPreset.ini" ) category theKey
				if(val=="" )then
					defaultValue
				else
					val as defaultType
				)
			
			fn initListView lv =
			(
			/*
			lv.gridLines = true --same as in ActiveX  
			lv.View = (dotNetClass "System.Windows.Forms.View").Details
			lv.fullRowSelect = true --same as in ActiveX 
			layout_def = #("Parameter", "Value")
			for i in layout_def do
			lv.Columns.add i 200 --add column with name and optional width
			*/
			--lvstuff.InitListView lv pInitColumns: #("Parameter", "Value") pInitColWidths:#((fnGetINI  "Columns" "Parameter_Width" integer 208),(fnGetINI  "Columns" "Value_Width" integer 476)) --pCheckBoxes: true
			lvstuff.InitListView lv pInitColumns: #("Parameter", "Value", "Class") pInitColWidths:#((fnGetINI  "Columns" "Parameter_Width" integer 208),(fnGetINI  "Columns" "Value_Width" integer 382),(fnGetINI  "Columns" "Class_Width" integer 92)) --pCheckBoxes: true
			) 


			fn fillInSpreadSheet lv =
			(
			--theRange = #() --array to collect the list items
			local custArry =#()
				
				for i = 1 to self.rendererPreset_arry.count do
				(
				if self.rendererPlugin_arry[1] == undefined then rendererPluginStr = "Renderer" else rendererPluginStr = self.rendererPlugin_arry[1]
				lvstuff.AddLvItem lv pTextItems:#((self.rendererPreset_arry[i][1] as string),(self.rendererPreset_arry[i][2] as string),rendererPluginStr)
				)
				
				for i = 1 to self.rendererMRCustomPreset_arry.count do
				(
				local itm = lvstuff.AddLvItem lv pTextItems:#((self.rendererMRCustomPreset_arry[i][1] as string),(self.rendererMRCustomPreset_arry[i][2] as string),"MRCustomString")
				lvstuff.SetLvItemRowColor lv itm.index self.UI_MRCustomColor
				)
				
				--format "%\n" self.rendererVFBPlusPreset_arry
				--format "%\n" self.rendererPreset_arry

				for i = 1 to self.rendererVFBPlusPreset_arry.count do
				(
				classString = "VFBPlus"
				classString = case self.rendererVFBPlusPreset_arry[i][3] of 
				(
				1:	classString+"CC"
				2: classString+"Stamper"
				)
				
				local itm = lvstuff.AddLvItem lv pTextItems:#((self.rendererVFBPlusPreset_arry[i][1] as string),(self.rendererVFBPlusPreset_arry[i][2] as string),classString)
				lvstuff.SetLvItemRowColor lv itm.index self.UI_VFBPlusColor
				)		
-- 				for i = 1 to self.rendererMRCustomPreset_arry.count do
-- 				(
-- 				lvstuff.SetLvItemRowColor lv a red	
-- 				)
			)

			fn fnUpdateUI=
			(
-- 			format "%\n" self.rendererPreset_arry
			/*
			lv_params.clear()
			initListView lv_params
			fillInSpreadSheet lv_params
			*/
			lv.clear()
			initListView lv
 			fillInSpreadSheet lv
			)
			on lv columnClick columnHeader do 
			(
				lv.ListViewItemSorter = dotnetobject "MXS_dotNet.ListViewItemComparer" columnHeader.column
				lv.ListViewItemSorter = undefined
			)

			on btn_apply pressed do
			(
				--start = timeStamp()
				if renderscenedialog.isopen() == true then -- render scene dialog must be closed!
				(
				renderscenedialog.close()
				--self.fnRendererPreset()
				self.fnApply_RendererPlugin self.rendererPlugin_arry
				self.fnApply_RendererParams self.rendererPreset_arry
				self.fnApply_MRCustomRendererParams self.rendererMRCustomPreset_arry
				self.fnApply_VFBPlusRendererParams self.rendererVFBPlusPreset_arry
				renderscenedialog.open()
				)
				else
				(
                --self.fnRendererPreset()
				self.fnApply_RendererPlugin self.rendererPlugin_arry
				self.fnApply_RendererParams self.rendererPreset_arry
				self.fnApply_MRCustomRendererParams self.rendererMRCustomPreset_arry
				self.fnApply_VFBPlusRendererParams self.rendererVFBPlusPreset_arry
				)
				--end = timeStamp()
				--format "Processing took % seconds\n" ((end - start) / 1000.0)
			)
			on btn_store pressed do
			(
			self.rendererPlugin_arry = self.fnCollect_RendererPlugin()
			self.rendererPreset_arry = self.fnCollect_RendererParams()
			self.rendererMRCustomPreset_arry = self.fnCollect_RendererMRCustomParams()
			self.rendererVFBPlusPreset_arry = self.fnCollect_RendererVFBPlusParams()
--			self.rendererPreset_arry = #("a","b")--#(#(#test1,"a"),#(#test2,"b"))
			self.fnStore()
			fnUpdateUI()
			)
			fn fnOpen =
			(
--				pbObject.object=self.myObject
				dialogPos = [(fnGetINI "Window" "X_Position" integer 180),(fnGetINI "Window" "Y_Position" integer 210)]
				SetDialogPos RenderPreset_rollout dialogPos
				RenderPreset_rollout.width = fnGetINI "Window" "X_Size" integer 720
				RenderPreset_rollout.height = fnGetINI "Window" "Y_Size" integer 320
				fnUpdateUI()
				
			)
			
			on RenderPreset_rollout close do
			(
--				self.myObject=pbObject.object
				--self.fnStore()
				fnSetINI "Window" "X_Position" (GetDialogPos RenderPreset_rollout)[1]
				fnSetINI "Window" "Y_Position" (GetDialogPos RenderPreset_rollout)[2]
				fnSetINI "Window" "X_Size" RenderPreset_rollout.width
				fnSetINI "Window" "Y_Size" RenderPreset_rollout.height
				fnSetINI "Columns" "Parameter_Width" lv.Columns.Item[0].Width
				fnSetINI "Columns" "Value_Width" lv.Columns.Item[1].Width
				fnSetINI "Columns" "Class_Width" lv.Columns.Item[2].Width
			)
			on RenderPreset_rollout resized size do
			(
				lv.width = size.x - 16
				lv.height = size.y - 50
			)
		)
		createdialog RenderPreset_rollout style:#(#style_titlebar, #style_sysmenu, #style_resizing, #style_minimizebox)
		RenderPreset_rollout.self=self	
		RenderPreset_rollout.fnOpen()
		return true
	),
	fn fnRightClick=
	(
		rcmenu rctest
		(
			local self
			menuItem editMe "Edit"
			menuItem DeleteMe "Delete"
			on editMe picked do
			(
				self.fnEdit()
			)
			on deleteMe picked do
			(
--				print self
				LPM_Operators.fnDeleteOperatorByNode self.INode
			)
		)
		popUpMenu rctest
		rcTest.self=self
	),
	
	fn fnPerformAction action param:#() =--Required
	(
		fnload()
		case action of
		(
			#Edit:(fnEdit())
			#preRender:(fnRendererPreset())
			#middleClick:(fnRendererPreset())
			#rightClick:(fnRightClick())
			#postRender:(fnRendererPresetRestore())
			default:(return #NOT_IMPLEMENTED)
		)
	)
	
)

if(((maxVersion())[1]) >= 13000) then
	LPM_operators.fnRegisterOperator LPM_renderPresetsOperator