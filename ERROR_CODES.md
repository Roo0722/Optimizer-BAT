# Custom Error Codes (EC) for Safe PC Optimizer Script

This file documents the custom error codes used in `Safe_PC_Optimizer_v2.bat`. These codes help quickly diagnose why a specific section or command may have failed or returned a warning.

| Error Code (EC) | Description | Section | Context/Solution |
| :---: | :--- | :--- | :--- |
| **EC 101** | **Admin Privileges Check Failed** | Initialization | **CRITICAL FAILURE:** Script terminated. Must run as Administrator. |
| **EC 102** | User Cancellation | Initialization | User chose 'N' when prompted to start the script. |
| **EC 103** | Restore Point Creation Failed | Initialization | The Volume Shadow Copy Service or System Protection may be disabled. Proceed with caution. |
| **EC 200** | Windows Temp Folder Cleanup Warning | Temp Cleanup | Some files were in use and could not be deleted. Common and safe to ignore. |
| **EC 201** | Windows Update Cache Cleanup Failed | Temp Cleanup | The Windows Update Service (`wuauserv`) could not be stopped or restarted. |
| **EC 301** | Chkdsk Ran (Informational Failure) | Maintenance | `chkdsk` reported pending repairs required upon the next system restart. |
| **EC 302** | Defragmentation Failed | Maintenance | The `defrag` command failed. Check drive health and the Defragmentation Service status. |
| **EC 303** | SFC /SCANNOW Failed | Maintenance | SFC ran, but reported unrecoverable file corruption. Check the `%windir%\Logs\CBS\CBS.log` file for details. |
| **EC 304** | Windows Defender Update Failed | Maintenance | `MpCmdRun.exe` failed to execute. Check if the Windows Defender service is running correctly. |
| **EC 401** | Winsock Reset Failed | Networking | The `netsh winsock reset` command failed. Try running it manually and immediately rebooting. |
| **EC 402** | TCP/IP Reset Failed | Networking | The `netsh int ip reset` command failed. Try running it manually and immediately rebooting. |
| **EC 404** | TCP Auto-Tuning Level Setting Failed | Networking | The script could not set `autotuninglevel=normal`. Minor issue; could be due to policy or network adapter state. |