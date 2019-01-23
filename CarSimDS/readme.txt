to use DS module, do the following steps:

step 1: install the lgs510x64 following the SW instructions
		just skip the hardware part if no logitech hardware
				
step 2: use CarSim to import the  CarSim2016_DS.cpar file
		note: this file in intended for CarSim 2016.
		
step 3: after import into CarSim, several files are generated:
		Simulink_DS, StandaloneDS file folder
		from carsim, in the DS 2016 w/Simulink Categery, choose a dataset and click
		the "Send to Simulink" buttom, MATLAB/SIMULINK will in envolked.
		a simulink model will be opened, with RT module and CarSim S-Function
		the default directory of MATLAB is the CarSim data folder

step 4: check the DS Lib
		from the simulink mdl opened in step 3, open simulink lib, check the DS S-fucntion
		lib existance.
		
step 5: add RT sfunction in MATLAB
		MATLAB--preset filefolder--add folder and subfolders--*\Simulink_DS\DS_SF_Library
		in simulink, open simulink lib, click lib fix, the DS function module will
		appear in the lib.
		just new a simulink in whatever folder, drag the module into it, and keep carsim running,
		the RT module will work just fine.

enjoy!

## update: step 1 is not really neccesery.