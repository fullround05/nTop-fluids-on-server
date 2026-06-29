:: Configuration
set IP=%1
set Port=%2

set ntopUname=%3
set ntopPasswd=%4

set Viscocity=%5
set Density=%6

:: This is not a problem when running from the command prompt,
:: but the nTop run command block does not seem to like the format [x,y,z].
:: The notebook exports the vector as x_y_z and we convert it to [x,y,z] here
set Velocity=%7
set "Velocity=[%Velocity:_=,%]"

set Pressure=%8
set CellSize=%9


:: Change working directory to the folder this script is located in
cd /d "%~dp0"

:: Build the JSON input file
(
echo {
echo     "description": "",
echo     "inputs": [
echo        {
echo            "description": "",
echo            "name": "Fluid Viscocity",
echo            "type": "real",
echo            "value": %Viscocity%,
echo            "units": "mm^2/s"
echo        },
echo        {
echo            "description": "",
echo            "name": "Fluid Density",
echo            "type": "real",
echo            "value": %Density%,
echo            "units": "kg/m^3"
echo        },
echo         {
echo             "description": "",
echo             "name": "Inlet Velocity",
echo             "type": "vector",
echo             "value": %Velocity%,
echo             "units": "mm/s"
echo         },
echo         {
echo             "description": "",
echo             "name": "Outlet Pressure",
echo             "type": "real",
echo             "value": %Pressure%,
echo             "units": "Pa"
echo         },
echo         {
echo             "description": "",
echo             "name": "Cell Size",
echo             "type": "real",
echo             "value": %CellSize%,
echo             "units": "mm"
echo         }
echo     ],
echo     "title": "Server Side CFD"
echo }
) > exchange\input.json

:: Delete the old simulation results
del exchange\Result.vti

:: Import the ssh key so the user is prompted to decrypt the key if needed
pageant.exe key.ppk

:: Use the putty gui to confirm the fingerprint. This is the best soltuion I have been able to find
putty.exe -P %Port% root@%IP%

:: Copy the inputs, notebook, and simulation models to the server
pscp.exe -batch -P %port% exchange\input.json root@%ip%:
pscp.exe -batch -P %port% RegServerRunner.ntop root@%ip%:
pscp.exe -batch -P %port% exchange\Fluid.implicit root@%ip%:
pscp.exe -batch -P %port% exchange\Inlet.implicit root@%ip%:
pscp.exe -batch -P %port% exchange\Outlet.implicit root@%ip%:

:: SSH to the server and run the flow analysis
plink.exe -P %Port% root@%IP% "ntopcl --username %ntopUname% --password %ntopPasswd% -v2 -j input.json RegServerRunner.ntop"

pscp.exe -batch -P %port% root@%ip%:Result.vti exchange\Result.vti
