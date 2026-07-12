:: Batch variables
@echo off

:: Configuration
set "IP=%~1"
set "Port=%~2"

set "ntopUname=%~3"
set "ntopPasswd=%~4"

set "keyImported=%~5"
set "knownServer=%~6"

set "Mach=%~7"
set "Temperature=%~8"
set "Pressure=%~9"

:: Shift twice to move arguments 10 and 11 back to 8 and 9
shift
shift

set "AngleOfAttack=%~8"
set "CellSize=%~9"

:: Change working directory to the folder this script is located in
cd /d "%~dp0"

:: Build the JSON input file
(
echo {
echo     "description": "",
echo     "inputs": [
echo         {
echo             "description": "",
echo             "name": "Mach Number",
echo             "type": "real",
echo             "value": %Mach%
echo         },
echo         {
echo             "description": "",
echo             "name": "Temperature",
echo             "type": "real",
echo             "value": %Temperature%,
echo             "units": "K"
echo         },
echo         {
echo             "description": "",
echo             "name": "Pressure",
echo             "type": "real",
echo             "value": %Pressure%,
echo             "units": "Pa"
echo         },
echo         {
echo             "description": "",
echo             "name": "Angle of Attack",
echo             "type": "real",
echo             "value": %AngleOfAttack%,
echo             "units": "deg"
echo         },
echo         {
echo             "description": "",
echo             "name": "Cell Size",
echo             "type": "real",
echo             "value": %CellSize%,
echo             "units": "mm"
echo         }
echo     ],
echo     "title": "Server Side Aircraft Flow Analysis"
echo }
) > exchange\input.json

:: Delete the old simulation results
del exchange\Result.vti

:: Import the ssh key so the user is prompted to decrypt the key if needed
if "%keyImported%"=="0" pageant.exe key.ppk

:: Use the putty gui to confirm the fingerprint. This is the best soltuion I have been able to find
if "%knownServer%"=="0" putty.exe -P %Port% root@%IP%

:: Copy the inputs, notebook, and simulation model to the server
echo Uploading Files to Server
pscp.exe -batch -P %port% exchange\input.json root@%ip%:
pscp.exe -batch -P %port% AircraftServerRunner.ntop root@%ip%:
pscp.exe -batch -P %port% exchange\Body.implicit root@%ip%:

:: SSH to the server, remove the old results, and run the flow analysis
plink.exe -P %Port% root@%IP% "rm -f Result.vti && ntopcl --username %ntopUname% --password %ntopPasswd% -v2 -j input.json AircraftServerRunner.ntop"

:: Copy the result back
echo Downloading Simulation Result
pscp.exe -batch -P %port% root@%ip%:Result.vti exchange\Result.vti
