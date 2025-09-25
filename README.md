# 🚀 Safe PC Optimizer & Maintenance Script (Windows 10/11)

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/Roo0722/PC-Optimizer-Batch-Script?style=social)](https://github.com/Roo0722/PC-Optimizer-Batch-Script/stargazers)

## 💡 Overview

This is a **safe, conservative, and comprehensive batch file utility** designed to automate routine PC maintenance for Windows 10 and 11. Developed by an experienced system administrator, this script prioritizes **data integrity and system stability** over aggressive performance gains.

It clears temporary files, flushes network caches, checks system file integrity, and performs basic maintenance tasks—all with robust logging and safety checks.

---

## ✅ Key Features

* **Safety First:** **NEVER** deletes personal files, user documents, passwords, or critical system files (`system32`, core registry).
* **Comprehensive Cleanup:** Clears `%TEMP%`, `%WINDIR%\Temp`, Windows Update cache, and common browser caches.
* **System Integrity:** Executes the **SFC /SCANNOW** utility (user-confirmed) and runs non-destructive `chkdsk`.
* **Network Optimization:** Flushes DNS, resets Winsock, and resets the TCP/IP stack (requires restart).
* **Smart Maintenance:** **Detects and skips defragmentation on SSDs**; only runs on HDDs.
* **Advanced Logging:** Creates a detailed log file with timestamps, progress updates, and **custom Error Codes (EC)** for easy troubleshooting.
* **Restore Point:** Attempts to create a System Restore Point before execution.

---

## 🛠️ Prerequisites and Usage

### Prerequisites

* **OS:** Windows 10 or Windows 11.
* **Permissions:** Must be run with **Administrator privileges**.

### Step-by-Step Usage

1.  **Download:** Download the `Safe_PC_Optimizer_v2.bat` file from this repository.
2.  **Run as Admin:** **Right-click** the batch file and select **"Run as administrator."** (Crucial step!)
3.  **Confirm Execution:** When prompted, type **Y** to begin the optimization process.
4.  **SFC Scan:** When prompted during the System Maintenance section, confirm (Y/N) whether to run the lengthy **SFC /SCANNOW** scan.
5.  **Restart:** After the script completes, it will recommend and prompt for a system restart. This is necessary for network stack resets and certain cache changes to take full effect.

---

## 📝 Troubleshooting & Error Codes

The script is designed to fail gracefully. If any action fails, it records a specific **Custom Error Code (EC)** in the log file and continues to the next task.

### Where to Find the Log

The comprehensive log file (`PC_Optimizer_Log_[Date]_[Time].log`) is generated on your **Desktop** after the script completes.

### ❓ What if something goes wrong?

1.  **Check the Log:** Review the log file for any `[ERROR EC ###]` messages.
2.  **Consult `ERROR_CODES.md`:** Check the dedicated `ERROR_CODES.md` file in this repository to find the meaning and solution for the specific error code.
3.  **Network Issues:** If connectivity is lost, **immediately restart your computer**. Network stack resets require a reboot to finalize configuration.
4.  **Revert Changes:** If the system becomes unstable, use **System Restore** and choose the restore point labeled **"PC\_Optimizer\_Script"**.

---

## 🧑‍💻 Code Details

The core of the script implements robust control flow using standard Windows Batch commands:

* **Admin Check:** Uses `net session` to verify privileges.
* **Error Reporting:** Uses the custom `:LogAction` subroutine with `if %errorlevel% neq 0` checks after critical commands to record specific failure codes.
* **Cleanup:** Uses `rd /s /q` (Recursive Delete, Quiet) for temp folders and `del /f /s /q` for specific cache files.

---

## ⚖️ License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

