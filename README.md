```                                                                                                 

                       _                                                              _               _
  _ __  __ __ __  ___ | |_    ___   ___  __ __  ___   __   ___   __ _   _ _    __ _  | |  _  _   ___ (_)  ___
 | '_ \ \ V  V / (_-< | ' \  |___| / -_) \ \ / / -_) / _| |___| / _ |  | ' \  / _  | | | | || | (_-< | | (_-<
 | .__/  \_/\_/  /__/ |_||_|       \___| /_\_\ \___| \__|       \__,_| |_||_| \__,_| |_|  \_, | /__/ |_| /__/
 |_|                                                                                      |__/


```

# PowerShell Execution Analysis

This repository contains scripts and configurations for analyzing PowerShell execution on Windows systems. It is inspired by the work of [IppSec's PowerSiem](https://github.com/IppSec/PowerSiem) and [Neo23x0's sysmon-config](https://github.com/Neo23x0/sysmon-config).

## Overview

The provided scripts and configurations are designed to enhance visibility into PowerShell activity on Windows systems. By leveraging PowerShell logging and Sysmon configurations, this analysis tool helps in identifying potentially malicious or suspicious PowerShell commands and activities.

![Overview](https://github.com/cridin1/pwsh-execution-analysis/blob/main/exec-analysis.png)

PowerShell version: 5.1.19041.1645 (or compatible)

## Usage

### Virtual Machine Setup
1. Ensure that you have VirtualBox and VBoxManage installed.
2. Install a Windows virtual machine with the following name `Malware-VM-Windows`.
3. Clone the repository on the target VM.
4. Ensure that PowerShell (`pwsh`) is running with administrative privileges.
5. Save a snapshot and update the id in `exec-from-host.ps1` script.

To utilize the tools in this repository, follow these steps:
1. Clone or download this repository to your local machine.
2. Run the `exec-from-host.ps1` script with the appropriate parameters:

```powershell
.\exec-from-host.ps1 OUTPUT_DIR_PATH COMMANDS_PATH
```

Update 
