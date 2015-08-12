--Load Core Files
filein (::LPM_DIR+"Globals.ms")
--filein (::LPM_DIR+"include.mcr")
filein (::LPM_DIR+"CA.ms")
filein (::LPM_DIR+"functions.ms")
filein (::LPM_DIR+"render.ms")
filein (::LPM_DIR+"rcMenus.ms")
filein (::LPM_DIR+"treeView.ms")
LPM_PluginFiles=getfiles(::LPM_DIR+"plugins/*")
for f in LPM_PluginFiles do filein f
filein (::LPM_DIR+"operatorsAPI.ms")