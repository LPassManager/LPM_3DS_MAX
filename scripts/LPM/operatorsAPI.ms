/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com
Operators module written by Jacob Jeziorski (www.JakubJeziorski.com)

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

struct LPM_operatorAPI 
(
	operatorClasses = #(),
	operatorObjects = #(),

	fn fnRegisterOperator operator=
	(
		append operatorClasses operator
	),
	newOperatorParent=0,
	fn fnCreateOperatorObject newOperatorType=
	(
		pName="LPM_"+newOperatorType
		theNode=dummy name:pName
		theNode.pos=[0,0,-1000]
		LPM_Fun.addToLPMLayer theNode
		theNode.parent=newOperatorParent
		custAttributes.add theNode LPM_genericCA
		theNode.subtype=newOperatorType

		--Update the LPM_Treeview
		::LPM_treeview_rollout.updateTV()

		return theNode
	),
	fn fnNewOperator parent=
	(
		newOperatorParent=parent

		opTypes=for opC in operatorClasses collect opC.fnGetSubType()
		global RC_LPM_Operators
		
		RC="rcMenu RC_LPM_Operators (\n"
		for opt in opTypes do
		(
			
			RC+="menuItem "+opt+" \"" + opt +"\";\n"
			RC+="on "+opt + " picked do LPM_Operators.fnCreateOperatorObject \""+opt+"\";\n"
		)

		RC+=")\n"
		execute RC
		popUpMenu RC_LPM_Operators
		
		--This is a little hack to create a blocking call
		rcmenu null
		(
			seperator s1
			--menuitem null ""
		)
		--popUpMenu null
	),
	
	fn fnDeleteOperatorByNode INode=
	(
		for i=1 to operatorObjects.count where operatorObjects[i].INode==INode do
		(
			delete operatorObjects[i].INode
			deleteItem operatorObjects i
			LPM_Treeview_rollout.updateTV()
			return true
		)
		
		return false
	),
	--creates a new operator object if not existing or returns existing operator
	fn fngetByNode INode=
	(
		for op in operatorObjects where op.INode == INode do
			return op
		for opC in operatorClasses where opC.fnGetSubType()==INode.subType do
		(
			it=opC()
			append operatorObjects it
			it.INode=INode
			it.self=it
			return it
		)
		return 0
	),
	fn fnLoadOperators = 
	(
		operatorFiles = getFiles (::LPM_DIR+"operators\\*.ms")
		print operatorFiles
		for op in operatorFiles do
		(
			filein op
		)
		return true
	)
	
)

LPM_Operators=LPM_operatorAPI()
LPM_Operators.fnLoadOperators()