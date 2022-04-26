@echo off
Echo This batch file will Force the Update Detection from the AU client:
Echo 1. Stops the Automatic Updates Service (wuauserv)
Echo 2. Deleting Software Distribution folder 
Echo 3. Restart the Automatic Updates Service (wuauserv)
Echo 4. Force the detection
 
Pause
@echo on
net stop wuauserv
del /f /s /q %SystemRoot%\SoftwareDistribution\*.*
net start wuauserv
wuauclt /reportnow /detectnow
@echo off
Echo This AU client will now check for the Updates on the Local WSUS Server.
Pause