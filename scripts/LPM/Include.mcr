/*
Lukas Lepicovsky / Jakub Jeziorski
L Pass Manager
lukashi@gmail.com
www.lukashi.com

	
*/


macroscript LPM category:"LPM"  buttonText:"LPM"
(
	filein (::LPM_DIR+"include.ms")
)


--render preview macro script
macroscript LPM_RenderPass category:"LPM" buttonText:"LPM Render"
(

	if(isvalidnode LPM_activePass) then
	(
			LPM_renderPass LPM_activePass #preview
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			filein (::LPM_DIR+"include.ms")
			messagebox "LPM Data found, but no pass has been picked.  Please pick a pass and hit render again."
				
		)
		else
			max quick render
	)
	
)

--render previewHalf macro script
macroscript LPM_RenderPassHalf category:"LPM" buttonText:"LPM Render Half"
(

	if(isvalidnode LPM_activePass) then
	(
		LPM_renderPass LPM_activePass #previewHalf
	)
	else
	(
		if isvalidnode $LPM_Root then
		(
			filein (::LPM_DIR+"include.ms")
			messagebox "LPM Data found, but no pass has been picked.  Please pick a pass and hit render again."
		)
		else
			max quick render
	)
)

