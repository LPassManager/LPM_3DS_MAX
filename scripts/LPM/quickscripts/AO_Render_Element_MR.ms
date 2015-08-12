if(iskindof renderers.current mental_ray_renderer) then
(
re = maxOps.GetCurRenderElementMgr()
re.AddRenderElement (mr_Shader_Element())
newEle=re.GetRenderElement (re.NumRenderElements() - 1)
newEle.shader=Ambient_Reflective_Occlusion__3dsmax samples:50
newEle.elementName="AO"
)
else messagebox "Please Enable Mental Ray"