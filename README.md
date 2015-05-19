# CaptureASALogScript
This PowerShell script generates logs for ASA in local computer. This will also create a zip file in case you want to send it someone for troubleshooting. Please go through the content it generates before sharing it with anyone.

# Change PowerShell execution policy
Change machine's PowerShell execution policy to Unrestricted (see [this] (http://technet.microsoft.com/en-us/library/ee176961.aspx) to know how to change it). Make sure that this change is applied to PowerShell.exe under System32 and SysWOW64:
* C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
* C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe

# Install Prerequisites
* Install [Windows Azure SDK] (http://www.windowsazure.com/en-us/develop/net/) . Click Azure PowerShell release on the page.
* If Windows Azure SDK is already installed please make sure to have latest version from [here] (https://github.com/Azure/azure-powershell/releases).

# Execute Package
* Execute CaptureASALogScript\ASALogRecorder.ps1

#Changes to test
