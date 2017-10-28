# LPM 3DS MAX
L Pass Manager for 3ds max

##Installating
* [Download the archive](https://github.com/LPassManager/LPM_3DS_MAX/archive/master.zip)
* Extract archive to the 3ds max root folder.
* The LPM folder should be in the 3dsmax\scripts folder.
* The file LPM_Startup.ms should be in the 3dsmax\scripts\StartUp folder.
* Add a Keyboard Hotkey or Toolbar shortcut to launch LPM using Customize->Customize User Interface from the main menu in 3ds max.
  The group is "Main UI" and the category is "LPM".

##Uninstalling
* Delete 3dsmax\scripts\LPM
* Delete 3dsmax\scripts\Startup\LPM_Startup.ms
 
##Developers
* [Download Github for windows](https://windows.github.com/)
* [Clone the repository](github-windows://openRepo/https://github.com/LPassManager/LPM_3DS_MAX) to C:\LPM_3DS_MAX (or another directory of your choice)
* Copy Script\Startup\LPM_Startup.ms to you max startup directory
* In LPM_Startup.ms modify the LPM_DIR to point to C:\LPM_3DS_MAX
