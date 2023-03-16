rem @echo off

cd 
:MakeDIR
if exist "C:\STI\" (
    robocopy %~d0\Newinstall "C:\STI\NewInstall" /E /IS /IT
    timeout 5
    start "Computer Setup" "C:\STI\NewInstall\NewComputerSetup.bat"
) else (
    mkdir "C:\STI\"
    goto :MakeDIR
)

:EOF

