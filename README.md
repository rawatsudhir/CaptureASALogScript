# CaptureASALogScript
This PowerShell script generates logs for ASA in local computer. This will also create a zip file in case you want to send it someone for troubleshooting. Please go through the content it generates before sharing it with anyone. Copy the content from CaptureASALogScript/ASALogRecorder file in PowerShell and execute it. We are still working on it to make it better so please share your feedback at sudhir.rawat@microsoft.com or jason.howell@microsoft.com.

# Change PowerShell execution policy
Change machine's PowerShell execution policy to Unrestricted (see [this] (http://technet.microsoft.com/en-us/library/ee176961.aspx) to know how to change it). Make sure that this change is applied to PowerShell.exe under System32 and SysWOW64:
* C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
* C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe


# Install Prerequisites
* Install [Windows Azure SDK] (http://www.windowsazure.com/en-us/develop/net/) . Click Azure PowerShell release.
