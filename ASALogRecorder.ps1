## This Powershell (.ps1) script is used to collect Microsoft Azure Stream Analytics job definitions and operation logs for a given account,
## For the intent of sharing this information with the Microsoft CSS Azure Support Team engineers for troubleshooting purposes.
## 1. Please set the output folder below if C:\Temp is not sufficient. At the end, the output will be zipped into that location.
## 2. The script will prompt you for your Azure credential if you do not have it actively configured.
## 3. The script will prompt you on which job to collect data for, or all jobs as needed.
## 4. The script will prompt you to choose between 1 to 14 days worth of Operation Log events to collect.

Login-AzureRmAccount
# Below statement used to capture subscription id in variable.
$SubscriptionId = Get-AzureSubscription -Current

# Pick an Output folder before you run the code if needed to change.
$folder ="C:\temp\"

## No Edits below here required
## ======================================
$folder = $folder + "StreamAnalytics\"

## Helper Function to do the output prints
function PrintJobAndLog
(
 [Microsoft.Azure.Commands.StreamAnalytics.Models.PSJob] $PrintJob,
 [System.Int32] $JobNumber,
 [System.DateTime] $BeginDate,
 [System.DateTime] $EndDate,
 [System.String] $FileFolder
 )
{

    Try
    {
        # Build the file paths
        $FilePath = $FileFolder + 'StreamAnalytics_Job' + $JobNumber.ToString() + "_" + $BeginDate.ToString("yyyyMMdd") + "_" + $EndDate.ToString("yyyyMMdd") + '.txt'
        $FilePathJSON = $FileFolder + 'StreamAnalytics_Job' + $JobNumber.ToString() + "_" + $BeginDate.ToString("yyyyMMdd") + "_"  + $EndDate.ToString("yyyyMMdd") + '.json'
        $FilePathCSV = $FileFolder + 'StreamAnalytics_Job' + $JobNumber.ToString() + "_" + $BeginDate.ToString("yyyyMMdd") + "_" + $EndDate.ToString("yyyyMMdd") + '.csv'
     
        # Remove old files if any exists
        If (Test-Path $FilePath) 
        { 	
            Write-Host 'Removing existing file'  $FilePath -ForegroundColor Red
            Remove-Item $FilePath
        }
            If (Test-Path $FilePathJSON) 
        { 	
            Write-Host 'Removing existing file'  $FilePathJSON -ForegroundColor Red
            Remove-Item $FilePathJSON 
        }
        If (Test-Path $FilePathCSV) 
        { 	
            Write-Host 'Removing existing file'  $FilePathCSV -ForegroundColor Red
            Remove-Item $FilePathCSV 
        }

        $ResourceId = "/subscriptions/" + $SubscriptionId.SubscriptionID + "/resourceGroups/" + $PrintJob.ResourceGroupName + "/providers/Microsoft.StreamAnalytics/streamingjobs/" + $PrintJob.JobName

        Write-Host 'Writing log files.... at ' $FilePath ' and ' $FilePathJSON -ForegroundColor Yellow

        #Write out the information to files
        "The current user account in this PowerShell output is"                 | Out-File $FilePath -Append
                                                     $Accounts | ConvertTo-JSON | Out-File $FilePath -Append
        'Subscription:- ' +  $SubscriptionId.SubscriptionID                     | Out-File $FilePath -Append
        'Resource Name:- ' + $PrintJob.ResourceGroupName                        | Out-File $FilePath -Append
        
        '*****************************Log Report******************************' | Out-File $FilePath -Append
        "`r`n" + 'Job Name:- ' + $PrintJob.JobName                              | Out-File $FilePath -Append
        'Resource Name:- ' + $PrintJob.ResourceGroupName                        | Out-File $FilePath -Append
        'Log Starts From:- ' + $BeginDate.ToString("yyyyMMdd") + ' To ' + $EndDate.ToString("yyyyMMdd") `
                                                                                | Out-File $FilePath -Append

        '=====================================================================' | Out-File $FilePath -Append
        "`r`n" + 'Azure Stream Analytic Input Job Definition....              ' | Out-File $FilePath -Append
        Get-AzureRmStreamAnalyticsInput -ResourceGroupName $PrintJob.ResourceGroupName -JobName $PrintJob.JobName `
                                                                                | Out-File $FilePath -Append
        'End of Azure Stream Analytic Input Job Definition....                ' | Out-File $FilePath -Append
        '=====================================================================' | Out-File $FilePath -Append
        "`r`n" + 'Azure Stream Analytic Transformation Job Definition....     ' | Out-File $FilePath -Append
        Get-AzureRmStreamAnalyticsTransformation -ResourceGroupName $PrintJob.ResourceGroupName -JobName $PrintJob.JobName -Name $PrintJob.JobName `
                                                                                | Out-File $FilePath -Append
        'End of Azure Stream Analytic Transformation Job Definition....       ' | Out-File $FilePath -Append
        '=====================================================================' | Out-File $FilePath -Append
        "`r`n" + 'Azure Stream Analytic Output Job Definition....             ' | Out-File $FilePath -Append
        Get-AzureRmStreamAnalyticsOutput -ResourceGroupName $PrintJob.ResourceGroupName -JobName $PrintJob.JobName `
                                                                                | Out-File $FilePath -Append
        'End of Azure Stream Analytic Output Job Definition....               ' | Out-File $FilePath -Append
        '=====================================================================' | Out-File $FilePath -Append

        # Print the Operation Logs - may take a while
        "`r`n" + 'LOGS START FROM DATE :- ' + $BeginDate                         | Out-File $FilePath -Append
        
        Get-AzureRmlog -ResourceId $ResourceId -DetailedOutput -StartTime $BeginDate | Out-File $FilePath -Append

        Write-Host $ResourceId
        Write-Host $BeginDate

        Get-AzureRmlog -ResourceId $ResourceId -DetailedOutput -StartTime $BeginDate | ConvertTo-Json | Out-File $FilePathJSON

        '===================================================================== ' | Out-File $FilePath -Append

        Write-Host 'Finished Writing log files.... at ' $FilePath ' and ' $FilePathJSON -ForegroundColor Yellow
        Write-Host '==========================================================='-ForegroundColor Yellow
    }
    Catch
    {
        Write-Host "Error in PrintJobAndLog:", $_ -BackgroundColor Red
    }
}

## Main

#Put all jobs into a collection
Write-Host "Enumerating your Stream Analytics jobs" -ForegroundColor Cyan

Try
    {
    
        $AllJobs = Get-AzureRmStreamAnalyticsJob -NoExpand
    }
Catch
    {
        Write-Host "Error in retrieving stream analytics job : ", $_ -BackgroundColor Red
    }

#Number the jobs 0 to ... then print the table to the screen
[System.Int32] $i = 0
ForEach($Job in $AllJobs) 
{ 
   Add-Member -NotePropertyName JobNum -NotePropertyValue $i -InputObject $Job 
   $i++
}
$AllJobs | Format-Table -AutoSize -Property *
Write-Host "    -1    ALL *"

#Let the user pick a number from the list of jobs
Write-Host "==============================================="
Do{
    Write-Host 'Please enter the job number from the list above. Or -1 for ALL jobs.' -ForegroundColor Cyan
    [System.Int32] $getJobNumber = Read-Host 'JobNum'
    
}
Until (($getJobNumber -lt $AllJobs.Count) -and ($getJobNumber -ge -1) )
If ($getJobNumber -eq -1 ) {    Write-Host "You picked ALL Jobs" }
Else {
    $PickedJob = $AllJobs[$getJobNumber]
    Write-Host "You picked Job ", $PickedJob.JobName, $PickedJob.ResourceGroupName, $PickedJob.JobID
}

#Make the folder if it does not exist.
If ((Test-Path $folder))
{
   Write-Host "The output folder", $folder, " already exists. Would you like to delete it?" -ForegroundColor Red
   
   $getYN = Read-Host 'Y/N'
   If($getYN -eq "Y" -or $getYN -eq "y" -or $getYN -eq "Yes" -or $getYN -eq "yes")
   {
        Write-Host 'Removing existing folder...'  $folder -ForegroundColor Red
        Remove-Item -path $folder -Recurse
        Write-Host "Making a fresh folder to hold the output:", $folder  -ForegroundColor Yellow
        New-Item -Path $folder -ItemType directory
   }
   Else
   {
       Write-Host 'Leaving folder in tact, but overwriting individual files if needed.'  $folder
   }

}
Else
{
   Write-Host "Making a folder to hold the output:", $folder
   New-Item -Path $folder  -ItemType directory
}


# Save the list of all jobs to a text file. 
$FileAllJobsPath = $folder + "StreamAnalytics_JobsListing.txt"
If (Test-Path $FileAllJobsPath) 
    { 	
        Write-Host 'Removing existing file'  $FileAllJobsPath -ForegroundColor Red
        Remove-Item $FileAllJobsPath
    }
Write-Host "Writing list of jobs... at ", $FileAllJobsPath -ForegroundColor Yellow
$AllJobs | Format-Table -Property * -AutoSize | Out-String -Width 4096 | Out-File $FileAllJobsPath
$AllJobs | ConvertTo-Json | Out-File $FileAllJobsPath -Append


#Get input from the user to specify a number of days of log data to collect between 1 and 14 (15 max may cause errors)
Do{
    Write-Host 'How many past days worth of logs do you want to gather? 14 days maximum.' -ForegroundColor Cyan
    [System.Int32] $LogDays = Read-Host 'Days'
}
Until ($LogDays -gt 0  -and $LogDays -lt 15)
$CurrentDate= Get-Date
$StartDate = $CurrentDate.AddDays($LogDays * -1)
Write-Host "These logs will include data from ", $StartDate.ToString("yyyyMMdd"), " until today ", $CurrentDate.ToString("yyyyMMdd"), "."


# If -1 Then Loop Over ALL jobs to print
If ($getJobNumber -eq -1)
{
    Write-Host "Collecting logs for ALL jobs" -ForegroundColor Yellow
    Write-Host '==========================================================='-ForegroundColor Yellow
    [System.Int32] $i=0
    ForEach($Job in $AllJobs) 
    { 
        Write-Host "Working on logs for Job #" $i, $Job.JobName, $Job.ResourceGroupName, $Job.JobID
        PrintJobAndLog -PrintJob $Job -JobNumber $i -BeginDate $StartDate -EndDate $CurrentDate -FileFolder $folder
        $i++
    }
}
# Else Print one job only
Else 
{
    PrintJobAndLog -PrintJob $AllJobs[$getJobNumber] -JobNumber $getJobNumber -BeginDate $StartDate -EndDate $CurrentDate -FileFolder $folder
}

# Zip the folder
Try
{
    $Directory = Get-Item $folder
    $parentfolder = $folder + ".."
    $ParentDirectory = Get-Item ($parentfolder)
    $ZipFileName = $ParentDirectory.FullName + "\" + $Directory.Name + ".zip" 
    if (test-path $ZipFileName) { 
      Write-Host "Zip file already exists at $ZipFileName. Would you like to delete it?" -ForegroundColor Cyan
      $getYN = Read-Host 'Y/N'
      If($getYN -eq "Y" -or $getYN -eq "y" -or $getYN -eq "Yes" -or $getYN -eq "yes")
      {
        Write-Host 'Removing existing file'  $ZipFileName -ForegroundColor Red
        Remove-Item $ZipFileName
      }
      Else
      {
        Write-Host "Done. Could not generate Zip file. Please zip the folder ", $folder, "and send to Microsoft Support." -BackgroundColor Red
        return 
      }
    } 
    set-content $ZipFileName ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
    #(dir $ZipFileName).IsReadOnly = $false 
    $ZipFile = (new-object -com shell.application).NameSpace($ZipFileName) 
    $ZipFile.CopyHere($Directory.FullName)
    Write-Host "Done. Please send the .zip file ", $ZipFileName, "to Microsoft Support." -BackgroundColor Green -ForegroundColor Black
}
Catch
{
    Write-Host "Done. Could not generate Zip file. Please zip the folder ", $folder,  "and send to Microsoft Support." -BackgroundColor Red
}
