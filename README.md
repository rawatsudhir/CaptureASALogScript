# CaptureASALogScript
This PowerShell script generates logs for ASA in local computer. This will also create a zip file in case you want to send it someone for troubleshooting. Please go through the content it generates before sharing it with anyone. We are still working on it to make it better so if you have any feedback please share it with sudhir.rawat@microsoft.com or jason.howell@microsoft.com.

# Change PowerShell execution policy
Change machine's PowerShell execution policy to Unrestricted (see [this] (http://technet.microsoft.com/en-us/library/ee176961.aspx) to know how to change it). Make sure that this change is applied to PowerShell.exe under System32 and SysWOW64:
* C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
* C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe

# Install Prerequisites
* Install [Windows Azure SDK] (http://www.windowsazure.com/en-us/develop/net/) . Click Azure PowerShell release on the page.

# Execute Package
* Execute CaptureASALogScript\ASALogRecorder.ps1
