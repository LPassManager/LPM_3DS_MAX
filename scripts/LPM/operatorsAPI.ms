/*
Lukas Lepicovsky
L Pass Manager
lukashi@gmail.com
www.lukashi.com
Operators module written by Jacob Jeziorski (www.JakubJeziorski.com)

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