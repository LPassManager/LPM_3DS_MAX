try( destroyDialog LPM_Object_Id ) catch()

rollout LPM_Object_Id "Object ID Manager" width:251 height:513
(
	local id=#()
	spinner spnAssign "" pos:[5,5] width:70 height:16 range:[0,65535,1] type:#integer
	button btnRefresh "Refresh UI" pos:[3,491] width:61 height:18
	
	dotNetControl tv "TreeView" pos:[3,26] width:244 height:461
	fn updateIds=
	(
		id=#()
		for it in objects where (superclassof it==geometryclass)do 
		(
			theId=it.gbufferChannel+1;
			if((id[theId])==undefined) then id[theId]=#()
			append id[theId] it
		)
	)
	
	fn initTv tv=
	(
	--	tv.AllowDrop = true -- allow DragandDrop for the Treeview
	)
	fn updateTv tv=
	(
		tv.nodes.clear()
		--Add the Root

	--	while tv.nodes.count > 0 do tv.nodes.remove(tv.nodes.item[0])
		for i=1 to id.count do
		(
			if(id[i]!=undefined) then
			(
				idNode=tv.Nodes.add ((i-1) as string)
				idNode.tag=i-1
				for it in id[i] do
				( 
					item=idNode.nodes.add it.name
					item.tag=dotNetMXSValue it
				)
				idNode.expand()
			)
			
		)
	)
	label lbl1 "Assign ID to Selected Objects" pos:[80,6] width:166 height:19

	on LPM_Object_Id open do
	(
		initTv tv;
		updateIds();
		updateTv tv;	
	)
	on spnAssign changed value do
	(
		for it in selection do try(it.gbufferChannel=spnAssign.value)catch()
		updateIds();
		updateTv tv;
	)
	on btnRefresh pressed do
	(
		updateIds();
		updateTv tv;
		
	)
	on tv mouseUp tvArg Arg do
	(
	
		hitNode = tv.GetNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
	
		
		if hitNode!=undefined then
		(
			if(Arg.button.ToString()=="Left") then
			(
				tag=hitNode.tag
				if(iskindof tag integer) then
				(
					
					for it in objects where it.gbufferChannel==tag do try(selectmore it)catch()
				)
				else
				(
					try (selectmore tag.value)catch()
				)
			)
		)
		else
		(
			max select none
		)
	
	)
)
createDialog LPM_Object_Id