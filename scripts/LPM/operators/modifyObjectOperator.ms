/*
Pass operator written by Jacob Jeziorski (www.JakubJeziorski.com)
for Lukas Lepicovsky's LPass Manager
www.lukashi.com
*/
/* OPERATORS*/
--All operators MUST implement the following:
--self (Pointer to the instance of the struct)
--INode (Pointer to the node holding the data)
--fnGetSubType (The type of the operator, alphaCharacters only, no spaces
--fnPerformAction (Function that takes as input a action type), return #NOT_IMPLEMENTED if I a function is not implemented


struct LPM_modifyObjectOperator
(
	
	self,--Required
	INode=0,--Required
	fn fnGetSubType=--Required
	(
		return "ModifyObject"
	),
	-- Custom data for the operator
	myObject=undefined,
	disabledModifiers=#(),
	isLoaded=false,
	--Save and store functions for the custom data
	fn fnload =
	(
		if(isLoaded==false) then
		(
			if(isvalidnode INode) then
			(
				print "load"
				myObject=INode.getValue "myObject" undefined
				disabledModifiers=INode.getArray "disabledModifiers" #()
			)
			isLoaded=true
		)
	),
	
	fn fnStore =
	(
		if(isvalidnode INode) then
		(
			print "store"
			print disabledModifiers
			
			INode.setValue "myObject" myObject
			INode.setArray "disabledModifiers" disabledModifiers
		)
	),
	--Actions
	fn fnDisableModifiers=
	(
		--Make sure we at least loaded...
		print "fnDisableModifiers"
		setCommandPanelTaskMode #Create
		if(isvalidnode myObject) then
		(
			for modi in myObject.modifiers do
			(
				if (findItem disabledModifiers modi.name !=0) then
					modi.enabled=false
				else
					modi.enabled=true
			)
		)
		
	),

	--#Edit
	fn fnEdit =
	(
		try(destroyDialog myRollout)catch()
		
		rollout myRollout "myRollout"
		(
			local self
			pickbutton  pbObject ""
			label lbl1 "Disabled Modifiers\n Note: All Selected Modifiers Will Be Disabled"
			multilistbox LBDisabledModifiers 
			button btnDisable "Disabled Selected"
			fn fnUpdateUI=
			(
				print self.disabledModifiers
				if(isvalidnode self.myObject==false) then
				(
					pbObject.text="Pick the Object To Modify"
				)
				else
				(
					pbObject.text=self.myObject.name
					LBDisabledModifiers.items=for modi in self.myObject.modifiers collect modi.name
					sel=#{}
					for i=1 to LBDisabledModifiers.items.count do
					(
						if(finditem self.disabledModifiers LBDisabledModifiers.items[i] !=0) then
							sel[i]=true
					)
					
					LBDisabledModifiers.selection=sel
					
				)
			)
			on LBDisabledModifiers selectionEnd do
			(
				self.disabledModifiers=for i=1 to LBDisabledModifiers.items.count where LBDisabledModifiers.selection[i] collect LBDisabledModifiers.items[i]
				print "selectionEnd"
				print self.DisabledModifiers
			)
			on pbObject picked obj do
			(
				self.myObject=obj
				fnUpdateUI()
			)
			on btnDisable pressed do
			(
				self.fnDisableModifiers()
			)
			fn fnOpen =
			(
				pbObject.object=self.myObject
				fnUpdateUI()
			)
			on myRollout close do
			(
				self.myObject=pbObject.object
				self.fnStore()
			)
		)
		
		createdialog myRollout
		myRollout.self=self	
		myRollout.fnOpen()
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
				print self
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
			#preRender:(fnDisableModifiers())
			#middleClick:(fnDisableModifiers())
			#rightClick:(fnRightClick())
			default:(return #NOT_IMPLEMENTED)
		)
	)
	
)

LPM_operators.fnRegisterOperator LPM_modifyObjectOperator