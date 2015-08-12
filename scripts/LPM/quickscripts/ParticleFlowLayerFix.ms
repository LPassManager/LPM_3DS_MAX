for pfSource in objects where classof pfSource==PF_Source do
(
	myLayer=pfSource.layer
	myRefs=refs.dependentNodes pfSource
	print myLayer.name
	pfClasses=#(Birth,Birth_Script,DeleteParticles,Position_Icon,Position_Object,rotation,scaleParticles,Spin,Keep_Apart,speed,Speed_By_Surface,SpeedByIcon,shapeStandard,Shape_Facing,\
			Shape_Instance,Shape_Mark ,mapping,Material_Dynamic ,Material_Frequency,Material_Static,Force,Script_Operator ,Cache,Notes,Event,renderParticles ,displayParticles,Age_Test,\
			Collision,Collision_Spawn,Find_Target ,Go_To_Rotation ,Scale_Test,Script_Test ,Send_Out ,Spawn,Speed_Test ,Split_Amount ,Split_Selected,	Split_Source,Particle_View ,ParticleGroup)
	
	for it in myRefs where finditem pfClasses (classof it)!=0 do (myLayer.addNode it)
)