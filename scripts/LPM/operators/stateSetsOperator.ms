/*
Title     :  StateSets operator for LPM 1.09+*
			- Plugin 3ds max's 2013 State Sets in LPM

Copyright : © 2012 veda3d.com
Author    : Royal Ghost

Version   : 0.1.0
						- First alpha release
						- Tested on 3dsmax 2013 (PU2)
			
Usage	    : 			
						1. Add custom operator "StateSets" in LPM
						2. Right click on added "StateSets" -> Edit
						3. In 3dsmax State Sets windows make any State current (enable)
						4. Press Pick button.
						Render pass in LPM.
			
Homepage  : http://veda3d.com

* LPM - Lukas Lepicovsky's LPass Manager www.lukashi.com
*/

/*OPERATORS*/
--All operators MUST implement the following:
--self (Pointer to the instance of the struct)
--INode (Pointer to the node holding the data)
--fnGetSubType (The type of the operator, alphaCharacters only, no spaces
--fnPerformAction (Function that takes as input a action type), return #NOT_IMPLEMENTED if I a function is not implemented


struct LPM_stateSetsOperator
(
	
	self,--Required
	INode=0,--Required
	fn fnGetSubType=--Required
	(
		return "StateSets"
	),
	-- Custom data for the operator
--	myObject=undefined,
	stateSets_arry =#(),
	restoreStateSets_arry =#(),
	isLoaded=false,

	stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin", --Get StateSets dotNet object. 
	stateSets = stateSetsDotNetObject.Instance, --Get the state sets instance from the dotNet object.  
	masterState = stateSets.EntityManager.RootEntity.MasterStateSet,
	
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
				stateSets_arry=INode.getArray "stateSets_arry" #()
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
--			INode.setValue "myObject" myObject

-- 			print "store"
-- 			print stateSets_arry.count
			INode.setArray "stateSets_arry" stateSets_arry
-- 			print stateSets_arry.count
-- 			print "end store"

		)
	),
	--Actions
		
	fn fnStateSets=
	(
		--Make sure we at least loaded...
--		self.rendererCurrent_arry = self.fnCollect_RendererParams()
--		self.fnApply_RendererParams self.rendererPreset_arry
	self.fnApply_StateSets self.stateSets_arry[1] -- apply by stored ID	
	),
	--#postRender
	fn fnStateSetsRestore =
	(
	--print "Function called after render. Restore stored params!"
		if self.restoreStateSets_arry.count > 0 then
		(
		try (self.masterState.CurrentState = #(self.restoreStateSets_arry[1]))catch(print "LPM State Sets error while resoring State Set")
		)
		else
		(
		self.masterState.Refresh() -- -- disable active State ?	
		)
	),
	
	fn fnApply_StateSets id =
	(
		local state = self.masterState.GetStateById id
		local curState = undefined
		
		self.restoreStateSets_arry = #()
		try (curState = self.fnPickCurrentState())catch()
		if curState != undefined then self.restoreStateSets_arry = #(curState)
		
		self.masterState.CurrentState = #(state)
		format "LPM State Set : % applied\n" state.name
	),
	
	fn fnPickCurrentState =
	(
	local curState = self.masterState.CurrentState
	return curState[1]
	),
	
	fn fnGetStateNameByID id =
	(
	local state = self.masterState.GetStateById id
	return state.name
	),
	--#Edit
	fn fnEdit =
	(
		try(destroyDialog StateSets_rollout)catch()

		
		rollout StateSets_rollout "LPM State Sets" width:241 height:320
		(
			local self
			local iconPathOperators=::LPM_DIR+"operators\\icons\\"
			
			button btn_pickCurrentState "P" width:24 height:24 align:#left across:3 offset:[-9,0] images:#(iconPathOperators+"op_statesets_pick.bmp",iconPathOperators+"op_statesets_pick_m.bmp",1,1,1,1,1) tooltip:"Pick enabled (current) State from State Sets"
			button btn_activateStoredState "C" width:24 height:24 align:#left offset:[144,0] images:#(iconPathOperators+"op_statesets_current.bmp",iconPathOperators+"op_statesets_current_m.bmp",1,1,1,1,1) tooltip:"Make self State current"
			dotNetControl dnLbl_stateset "System.Windows.Forms.Label" width:200 height:24 offset:[-140,0]--create a LABEL DotNetControl

			
			fn fnSetINI category theKey theValue =
			(
			setINISetting ( getdir #plugcfg + "\\LPM_StateSets.ini" ) category theKey (theValue as string)	
			)
			fn fnGetINI category theKey defaultType defaultValue=
			(
				val=getINISetting ( getdir #plugcfg + "\\LPM_StateSets.ini" ) category theKey
				if(val=="" )then
					defaultValue
				else
					val as defaultType
				)
			fn initLabel lbl =
			(
			dntheFont = dotnetobject "System.Drawing.Font" "Arial" 10 --myFontStyle
			--lbl.text = "None"
			if self.stateSets_arry.count > 0 then lbl.text = (self.fnGetStateNameByID self.stateSets_arry[1]) else lbl.text = "None"
			lbl.font = dntheFont 
			dnBorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").Fixed3D -- None,Fixed3D,FixedSingle
			lbl.BorderStyle = dnBorderStyle
			maxBackColor = colorMan.getColor #background
			lbl.BackColor =  (dotNetClass "System.Drawing.Color").fromARGB (maxBackColor[1] * 255.0f) (maxBackColor[2] * 255.0f) (maxBackColor[3] * 255.0f)
			)
			fn fnUpdateUI=
			(
			initLabel dnLbl_stateset
			--fnCollect_StateSets()
			)
			on btn_pickCurrentState pressed do
			(
			local curState = undefined
			self.stateSets_arry = #()
			
			try (curState = self.fnPickCurrentState())catch(print "LPM State Sets error while picking State, or no Active State ")
				
				if curState != undefined then
				(
				format "Picked State ID :% Name :%\n" curState.ID curState.name
				self.stateSets_arry[1] = curState.ID
				--dnLbl_stateset.text = curState.name
				fnUpdateUI()
				)
			)

			on btn_activateStoredState pressed do
			(
				if self.stateSets_arry.count > 0 then try (self.fnApply_StateSets self.stateSets_arry[1])catch()
			)
			
			fn fnOpen =
			(
--				pbObject.object=self.myObject
				dialogPos = [(fnGetINI "Window" "X_Position" integer 180),(fnGetINI "Window" "Y_Position" integer 210)]
				SetDialogPos StateSets_rollout dialogPos
				StateSets_rollout.width = fnGetINI "Window" "X_Size" integer 264
				StateSets_rollout.height = fnGetINI "Window" "Y_Size" integer 34
				
				format "stored IDs: %\n" self.stateSets_arry
				fnUpdateUI()
			)
			
			on StateSets_rollout close do
			(
--				self.myObject=pbObject.object
				self.fnStore()
				fnSetINI "Window" "X_Position" (GetDialogPos StateSets_rollout)[1]
				fnSetINI "Window" "Y_Position" (GetDialogPos StateSets_rollout)[2]
				fnSetINI "Window" "X_Size" StateSets_rollout.width
				fnSetINI "Window" "Y_Size" StateSets_rollout.height
			)
			on StateSets_rollout resized size do
			(
				btn_pickCurrentState.pos = [4,(size.y / 2 - 12)]
 				dnLbl_stateset.pos.x= 31
 				dnLbl_stateset.pos.y = (size.y/2)-12
				dnLbl_stateset.width = size.x - 64
 				btn_activateStoredState.pos = [(size.x-28),(size.y/2)-12]
			)
		)
		createdialog StateSets_rollout style:#(#style_titlebar, #style_sysmenu, #style_resizing, #style_minimizebox)
		StateSets_rollout.self=self	
		StateSets_rollout.fnOpen()
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
				try(destroyDialog StateSets_rollout)catch()
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
			#preRender:(fnStateSets())
			#middleClick:(fnStateSets())
			#rightClick:(fnRightClick())
			#postRender:(fnStateSetsRestore())
			default:(return #NOT_IMPLEMENTED)
		)
	)
	
)

if(((maxVersion())[1]) >= 15000) then
	LPM_operators.fnRegisterOperator LPM_stateSetsOperator