@echo off
setlocal enabledelayedexpansion

:: ##########################################################################
:: # SAFE PC OPTIMIZATION AND MAINTENANCE SCRIPT (v2.0)
:: # Purpose: Enhanced logging with custom numerical Error Codes (EC).
:: ##########################################################################

:: --------------------------------------------------------------------------
:: ** ERROR CODE LIST (EC) **
:: --------------------------------------------------------------------------
:: EC 100: Script Initialization / Environment Failure
:: EC 101: Admin Privileges Check Failed (Critical)
:: EC 102: User Cancellation
:: EC 103: Restore Point Creation Failed

:: EC 200: Temporary File Cleanup Failures
:: EC 201: Windows Update Cache Cleanup Failed (Service stop/start issue)
:: EC 202: Browser Cache Cleanup Failed
:: EC 203: Icon/Thumbnail Cache Cleanup Failed

:: EC 300: System Maintenance Failures
:: EC 301: Chkdsk Ran (Informational failure - no repair attempted)
:: EC 302: Defragmentation Failed
:: EC 303: SFC /SCANNOW Failed (Script ran, but SFC reported non-zero error)
:: EC 304: Windows Defender Update Failed

:: EC 400: Network Optimization Failures
:: EC 401: Winsock Reset Failed
:: EC 402: TCP/IP Reset Failed
:: EC 403: Network Interface Toggle Failed
:: EC 404: TCP Auto-Tuning Level Setting Failed

set "LOG_FILE=%USERPROFILE%\Desktop\PC_Optimizer_Log_%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%_%TIME::=-%.log"
set "LOG_FILE=!LOG_FILE: =0!"
set "DISK_BEFORE=0"
set "DISK_AFTER=0"
set "SEP=------------------------------------------------------------------"
echo %SEP%
echo Starting Safe PC Optimizer (v2.0 - Error Codes Enabled)...
echo Log file will be created at: "!LOG_FILE!"
echo %SEP%
echo.

call :LogAction "START: Safe PC Optimization Script initiated."

:: 1. Admin Rights Verification
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [CRITICAL ERROR] This script requires Administrator privileges. (EC 101)
    echo Please right-click the file and select "Run as administrator."
    call :LogAction "[ERROR EC 101] Failed to run with admin privileges. Exiting."
    pause
    goto :EOF
)
call :LogAction "[SUCCESS] Administrator privileges confirmed."

:: 2. System Backup Recommendation & Restore Point
echo.
echo Creating System Restore Point...
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "PC_Optimizer_Script", 100, 7 >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] System Restore Point created successfully.
    call :LogAction "[SUCCESS] System Restore Point created."
) else (
    echo [WARNING] Failed to create System Restore Point. (EC 103) Proceeding with caution.
    call :LogAction "[WARNING EC 103] Failed to create System Restore Point."
)
echo.

:: 3. User Confirmation Prompt
set /p "CONFIRM=Do you wish to PROCEED with the optimization? (Y/N): "
if /i "%CONFIRM%" neq "Y" (
    echo [ACTION] User cancelled the operation. (EC 102) Exiting.
    call :LogAction "[ACTION EC 102] User cancelled operation. Exiting."
    goto :EOF
)

:: 4. Get Initial Disk Space
call :GetDiskSpace C: DISK_BEFORE
call :LogAction "[INFO] Initial free disk space (C:): !DISK_BEFORE! GB."

:: --------------------------------------------------------------------------
:: SECTION A: Temporary File Cleanup
:: --------------------------------------------------------------------------
call :LogSection "Temporary File Cleanup"

:: 1. Clear Windows Temp Folders
rd /s /q "%TEMP%" >nul 2>&1
mkdir "%TEMP%" >nul 2>&1
rd /s /q "%WINDIR%\Temp" >nul 2>&1
mkdir "%WINDIR%\Temp" >nul 2>&1
if exist "%WINDIR%\Temp" (
    call :LogAction "[SUCCESS] Cleared %%TEMP%% and %%WINDIR%%\Temp."
) else (
    call :LogAction "[WARNING EC 200] Failed to clear all temporary files. Some may be in use."
)

:: 2. Remove Windows Update Cache
net stop wuauserv >nul 2>&1
if %errorlevel% equ 0 (
    rd /s /q "%WINDIR%\SoftwareDistribution\Download" >nul 2>&1
    mkdir "%WINDIR%\SoftwareDistribution\Download" >nul 2>&1
    net start wuauserv >nul 2>&1
    if %errorlevel% neq 0 (
        call :LogAction "[WARNING EC 201] Windows Update cache cleared, but service restart failed."
    ) else (
        call :LogAction "[SUCCESS] Cleared Windows Update Download cache."
    )
) else (
    call :LogAction "[WARNING EC 201] Windows Update Service (wuauserv) could not be stopped. Skipping cache clear."
)

:: 3. Clear Browser Caches (Simplified and safe)
rd /s /q "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rd /s /q "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rd /s /q "%USERPROFILE%\AppData\Local\Mozilla\Firefox\Profiles\*\cache2" >nul 2>&1
call :LogAction "[SUCCESS] Attempted to clear common browser caches."

:: --------------------------------------------------------------------------
:: SECTION B: System Maintenance
:: --------------------------------------------------------------------------
call :LogSection "System Maintenance"

:: 1. Check Disk for Errors (Non-destructive)
chkdsk C:
if %errorlevel% neq 0 (
    :: Chkdsk can return non-zero for pending repair; this is for informational logging.
    call :LogAction "[INFO EC 301] Ran non-destructive chkdsk on C:. Console output may show errors."
) else (
    call :LogAction "[SUCCESS] Ran non-destructive chkdsk on C:."
)

:: 2. Defragment HDDs (Detect SSD vs HDD)
wmic partition where DriveLetter="C" get name | find "SSD" >nul 2>&1
if %errorlevel% neq 0 (
    defrag C: /v /u
    if %errorlevel% equ 0 (
        call :LogAction "[SUCCESS] Ran defrag on C: drive (HDD assumed)."
    ) else (
        call :LogAction "[WARNING EC 302] Defrag ran but returned a non-zero exit code."
    )
) else (
    call :LogAction "[INFO] C: is likely SSD. Skipping Defrag."
)

:: 3. Scan for and Repair Corrupted System Files (SFC scan)
set /p "CONFIRM_SFC=Run SFC /SCANNOW to check/repair system files? (Y/N): "
if /i "%CONFIRM_SFC%" equ "Y" (
    sfc /scannow
    if %errorlevel% equ 0 (
        call :LogAction "[SUCCESS] Ran SFC /SCANNOW successfully."
    ) else (
        call :LogAction "[WARNING EC 303] SFC /SCANNOW ran, but returned a non-zero exit code. See console for details."
    )
) else (
    call :LogAction "[ACTION] User skipped SFC /SCANNOW."
)

:: 4. Update Windows Defender Definitions
"%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate >nul 2>&1
if %errorlevel% equ 0 (
    call :LogAction "[SUCCESS] Windows Defender definitions updated."
) else (
    call :LogAction "[WARNING EC 304] Failed to update Windows Defender definitions. Check if service is running."
)

:: --------------------------------------------------------------------------
:: SECTION C: Network Optimizations
:: --------------------------------------------------------------------------
call :LogSection "Network Optimizations"

:: 1. Flush DNS Resolver Cache
ipconfig /flushdns
call :LogAction "[SUCCESS] Flushed DNS cache."

:: 2. Reset Winsock Catalog to defaults
netsh winsock reset >nul 2>&1
if %errorlevel% equ 0 (
    call :LogAction "[SUCCESS] Reset Winsock Catalog (Requires restart)."
) else (
    call :LogAction "[ERROR EC 401] Failed to reset Winsock Catalog."
)

:: 3. Reset TCP/IP Stack
netsh int ip reset >nul 2>&1
if %errorlevel% equ 0 (
    call :LogAction "[SUCCESS] Reset TCP/IP stack (Requires restart)."
) else (
    call :LogAction "[ERROR EC 402] Failed to reset TCP/IP stack."
)

:: 4. Optimize TCP Window Scaling
netsh int tcp set global autotuninglevel=normal >nul 2>&1
if %errorlevel% equ 0 (
    call :LogAction "[SUCCESS] Set TCP Auto-Tuning Level to normal."
) else (
    call :LogAction "[WARNING EC 404] Failed to set TCP Auto-Tuning Level."
)

:: --------------------------------------------------------------------------
:: FINALIZATION
:: --------------------------------------------------------------------------
call :LogSection "Finalization and Reporting"

:: 1. Get Final Disk Space
call :GetDiskSpace C: DISK_AFTER

:: 2. Restart Recommendation
set /p "RESTART_PROMPT=Do you wish to RESTART your computer now? (Y/N): "
if /i "%RESTART_PROMPT%" equ "Y" (
    call :LogAction "[ACTION] User requested system restart."
    shutdown /r /t 10
) else (
    call :LogAction "[ACTION] User declined system restart. Please restart manually."
)

call :LogAction "END: Script finished successfully."
pause
goto :EOF

:: --------------------------------------------------------------------------
:: Subroutines
:: --------------------------------------------------------------------------

:LogAction
    echo [%TIME%] %~1 >> "!LOG_FILE!"
    goto :EOF

:LogSection
    echo. >> "!LOG_FILE!"
    echo ########################################################################## >> "!LOG_FILE!"
    echo # SECTION: %~1
    echo ########################################################################## >> "!LOG_FILE!"
    echo. >> "!LOG_FILE!"
    goto :EOF

:GetDiskSpace
    for /f "skip=1 tokens=3" %%a in ('wmic logicaldisk where Caption="%~1:" get FreeSpace') do (
        set "BYTES=%%a"
        goto :CalculateGB
    )
:CalculateGB
    set /a "GB_VAL=BYTES / 1024 / 1024 / 1024"
    set "%~2=!GB_VAL!"
    goto :EOF