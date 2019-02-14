@echo off
:: Afterbuild script (nuget related)
set NugetBin=nuget.exe
set DebugSymbols=""
set Symbols=".nupkg"
set NetworkRepo="\\NETWORK\PATH\ROUTE"
set ConfigName="$(ConfigurationName)"
:: Messages Vars
set MsgInit=- INIT POST BUILD NUGET PACKAGING -
set MsgNugetFound=Found '%NugetBin%'!
set MsgNetworkRepoFound=Found '%NetworkRepo%'!
set MsgNugetNotFound='%NugetBin%' is not installed on this machine. You cannot publish your nuget Package to %NetworkRepo%
set MsgNetworkRepoNotFound='%NetworkRepo%' cannot be found, unable to publish package
set MsgClearPreviosNugetPackage=Clear .nupkg on $(ProjectDir)bin\$(ConfigurationName)
set MsgPackingNuget=Packing $(ProjectDir)$(ProjectFileName)
set MsgAddingPackage=Adding packge to the network repo '%NetworkRepo%' of working dir '$(ProjectDir)'
:: INIT
echo %MsgInit%
:: Previous validation
%NugetBin% >nul 2>&1
if errorlevel 9009 if not errorlevel 9010 (
    echo %MsgNugetNotFound%
    exit /B 0
)
echo %MsgNugetFound%

dir %NetworkRepo% >nul 2>&1
if errorlevel 1 (
    echo %MsgNetworkRepoNotFound%
    exit /B 0
)
echo %MsgNetworkRepoFound%
:: Do the packaging stuff
echo # %MsgClearPreviosNugetPackage% #
del $(ProjectDir)bin\$(ConfigurationName)\*.nupkg

echo # %MsgPackingNuget% #
if %ConfigName% == "Debug" (
  set DebugSymbols="-Symbols -Suffix $(ConfigurationName)"
)

set DebugSymbols=%DebugSymbols:"=%
set Symbols=%Symbols:"=%

%NugetBin% pack "$(ProjectDir)$(ProjectFileName)" -Properties Configuration=$(ConfigurationName) %DebugSymbols%

echo # %MsgAddingPackage% #
forfiles /P "$(ProjectDir)bin\$(ConfigurationName)" /m *%Symbols% /c "cmd /c %NugetBin% add "@FILE" -source %NetworkRepo%
