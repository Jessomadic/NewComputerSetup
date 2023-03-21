@echo Off


net stop wuauserv
net stop bits
 
set Basedir=C:\STI
rem set Basedir=%~d0

rem Set the active power profile to "balanced"
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

rem Prevent the computer from going to sleep when it is plugged in
powercfg /x monitor-timeout-ac 0

rem Prevent the screen from turning off when it is plugged in
powercfg /x standby-timeout-ac 0

rem Change the time zone to Eastern standard time
tzutil /s "Eastern Standard Time"

:Ninite
rem Run the executable file
Start "Ninite" %Basedir%\NewInstall\Installer.exe
timeout 260

rem Check if Chrome is installed
if exist "C:\Program Files (x86)\Google\Chrome\Application\" (
  set chromePath="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
  echo "Chrome is installed in Program Files(x86)"
  goto :BrowserDefault
) else (
	if exist "C:\Program Files\Google\Chrome\Application\" (
 	 set chromePath="C:\Program Files\Google\Chrome\Application\chrome.exe"
  	 echo "Chrome is installed in ProgramFiles"
  	 goto :BrowserDefault
))

:BrowserDefault
%Basedir%\Newinstall\SetDefaultBrowser\setdefaultbrowser.exe chrome delay=100
reg load HKEY_USERS\TEMP "C:\Users\default\ntuser.dat"
reg add HKEY_USERS\TEMP\Software\Microsoft\Windows\CurrentVersion\RunOnce /v SetDefaultBrowser /d "%basedir%\NewInstall\SetDefaultBrowser\setdefaultbrowser.exe chrome delay=200" /f
Timeout 5

rem Uninstall McAfee
Echo Checking for McAfee
if exist "C:\Program Files\McAfee" (
	echo starting uninstall
	start %Basedir%\NewInstall\MCPR.exe
	timeout 90
	goto :NortonUninstall
) else (
	Echo Checking Next Location
)

if exist "C:\Program Files\McAfee.com" (
	echo starting uninstall
	start %Basedir%\NewInstall\MCPR.exe
	timeout 90
	goto :NortonUninstall
) else (
	Echo Checking Next Location
)

if exist "C:\Program Files (x86)\Common Files\McAfee" (
	echo starting uninstall
	start %Basedir%\NewInstall\MCPR.exe
	timeout 90 
	goto :NortonUninstall
) else (
	Echo Checking for Norton
)

:NortonUninstall
if exist "C:\Program Files (x86)\Common Files\Norton" (
	echo starting uninstall
	start %Basedir%\NewInstall\NRnR.exe
	timeout 90 
	goto :ComputerRename
) else (
	Echo Checking Next Location
)

if exist "C:\Program Files\Norton" (
	echo starting uninstall
	start %Basedir%\NewInstall\NRnR.exe
	timeout 90 
	goto :ComputerRename
) else (
	Echo Checking For Malwarebytes
)

:MalwareBytesUninstall
if exist "C:\Program Files\Malwarebytes\Anti-Malware\" (
	echo starting uninstall
	start %Basedir%\NewInstall\MBU.exe /y /cleanup /noreboot /nopr
	timeout 90 
	goto :ComputerRename
) else (
	Echo Skipping Uninstall
)

:Computerrenamequestion
Echo Do you need to rename the computer?
Echo Please Type 1 for Yes or 2 For No
Echo 1. Yes
Echo 2. No
Set /p rename=Enter Your Choice:
if %rename% == 1 (
	goto :ComputerRename
) else if %rename% == 2 (
	Goto :agentinstallprompt
) else (goto :Computerrenamequestion
)

:ComputerRename
rem Get the current computer name
set OLD_COMPUTER_NAME=%COMPUTERNAME%
echo Your old computer name is %COMPUTERNAME%

rem Prompt the user for the new computer name
set /p NEW_COMPUTER_NAME=Enter the new computer name:

echo Are you sure that %New_Computer_Name% is correct?
echo Please Type 1 for Yes Or 2 for No
set /p NameChange=Enter Your Choice:
if %NameChange% == 1 (
  goto :NameChange
) else if %NameChange% == 2 (
  echo Rolling Back
  goto :ComputerRename
) else (goto :ComputerRename
)

:NameChange
rem Change the computer name
wmic computersystem where name="%OLD_COMPUTER_NAME%" call rename name="%NEW_COMPUTER_NAME%"


rem This line doesn't matter for non-employees you can edit it to allow whatever program/command to run a single time upon next startup (password changes,program installs,etc)
:agentinstallprompt
Echo Do you need to Install an Agent for this Computer?
Echo Please Type 1 for Yes or 2 For No
Echo 1. Yes
Echo 2. No
Set /p choice=Enter Your Choice:
if %choice% == 1 (	
reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce /v RMMAgent /d "%basedir%\NewInstall\RMMAgentInstall.exe" /f
Timeout 5
goto :Windows11install
rem goto :AgentInstall
) else if %choice% == 2 (
	Goto :Windows11Install
) else (goto :Windows11Install
)

:AgentInstall
"%Basedir%\Newinstall\RMMAgentInstall.EXE"
Timeout 150
Goto :Windows11Install

:Windows11Install
echo Are you Installing Windows 11?
echo 1. Yes
echo 2. No
set /p Windowsinstall=Enter your choice:
if %Windowsinstall% == 1 (
%Basedir%\NewInstall\WindowsPCHealthCheckSetup.msi /quiet /norestart
timeout 20
taskkill /im pchealthcheck.exe /f
) else if %Windowsinstall% == 2 (
	goto :PasswordSet
) else (goto :Windows11Install
  echo Skipping
)

echo At this point you should remove the password from the computer if one is set.
echo This will make it so that the computer can just restart as much as needed while windows is updating.
echo The Window 11 upgrade is silent so go get a cup of coffee it's going to take a while. Time Est is about 45 mins for a good internet connection (about 200 down) and a decent processor (recent i5 or better)

if exist "C:\Users\%username%\appdata\local\PCHealthCheck\" (
	echo PC Health Check Exists Starting Upgrade
    start %Basedir%\NewInstall\Windows11InstallationAssistant.exe /Quietinstall /SkipEULA /SkipCompatCheck /update
) else (
	Echo Skipping Windows 11 Upgrade
)

timeout 30

echo Looking for Windows Upgrade Completion


:UpgradeWindowsSearch
rem Get the list of running processes and search for the Windows Upgrade process
del Temp.txt
tasklist /fi "WindowTitle eq Windows 11*" > Temp.txt

rem Read the contents of the Temp.txt file
set /p tempfile=<Temp.txt

rem Check if the process was found
if "%tempfile%" == "INFO: No tasks are running which match the specified criteria." (
  echo Windows 11 Install is not yet Completed. Will repeat until it's done
  type temp.txt
  set "tempfile="
  timeout 180
  goto :UpgradeWindowsSearch
) else (
  echo The process was found
  echo %tempfile%
  echo Stopping Windows Update Service
  net stop wuauserv
  net stop bits
  timeout 10
  echo Deleting Windows Update Folder to clear out Windows 10 Updates
  rmdir /Q /S "%windir%\SoftwareDistribution\DataStore\
  rmdir /Q /S "%windir%\SoftwareDistribution\Download\
  rmdir /Q /S "%windir%\SoftwareDistribution\PostRebootEventCache.V2\
  rmdir /Q /S "%windir%\SoftwareDistribution\ScanFile\
  rmdir /Q /S "%windir%\SoftwareDistribution\SLS\
  del /Q /F "C:\Windows\SoftwareDistribution\ReportingEvents.log"
  del /Q /F "C:\Users\%username%\AppData\Local\Temp\*"
  reg add HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce /v Windowsoldclear /d rmdir /Q /S "C:\Windows.old\" /f
  timeout 10
  goto :PasswordSet
)

:PasswordSet
Echo Do you need to Set a password for an acct?
Echo Please Type 1 for Yes or 2 For No
Echo 1. Yes
Echo 2. No
Set /p choice=Enter Your Choice:
	if %choice% == 1 (
		net user
		Echo Please Enter the User from the list
		Set /p Username=Enter Your Choice:
		Echo Please Enter the Password you want to set for the User
		Set /p Password=Enter Your Choice:
		echo %Password%
		echo Is this the correct password?
		Echo Please Type 1 for Yes or 2 For No
		Echo 1. Yes
		Echo 2. No
		Set /p answer=Enter Your Choice:
		if %answer% == 1 (
			Net User %Username% %password%
			goto :localadmin
) 		else if %answer% == 2 (
			goto :PasswordSet
) 		else if %choice% == 2 (
		goto :SystemRestart
)

:localadmin
Echo Does this user need to be a local admin?
Echo Please Type 1 for Yes or 2 For No
Echo 1. Yes
Echo 2. No
Set /p Admin=Enter Your Choice:
if %Admin% == 1(
net localgroup administrators %Username% /add
Timeout 5
goto :SystemRestart
) else if %choice% == 2 (
goto :SystemRestart
)

:SystemRestart
Echo Do you need to restart this Computer?
Echo Please Type 1 for Yes or 2 For No
Echo 1. Yes
Echo 2. No
Set /p choice=Enter Your Choice:
if %choice% == 1 (	
shutdown -f -r -t 10
Timeout 5
) else if %choice% == 2 (
goto :EOF
)

:EOF

pause