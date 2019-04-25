$sourceFolder = "e:\DCIM\104UNSVD"
$destinationFolder = "C:\MyData\Videos"
#$destinationFolder = "D:\"

function New-MergedVideo($currentList, $firstDate) {
    $destinationFilename = "$destinationFolder\G$firstDate.mp4"
    if (Test-Path $destinationFilename) {
        $uniqueSuffix = 2
        while (Test-Path $destinationFilename) {
            $destinationFilename = "$destinationFolder\G$firstDate-$uniqueSuffix.mp4"
            $uniqueSuffix = $uniqueSuffix + 1
        }
    }
    Write-Output "$($currentList.Count) files getting combined into $destinationFilename"
    Write-Output "... $($currentList[0]) through $($currentList[$currentList.Count-1])"
    # https://gpac.wp.imt.fr/mp4box/mp4box-documentation/
    [string[]] $argList = "-force-cat"
    foreach ($fileName in $currentList) {
        $argList += "-cat"
        $argList += $fileName
    }
    $argList += "-new", $destinationFilename
    $argList += "-tmp", $destinationFolder
    Start-Process 'C:\Program Files\GPAC\mp4box.exe' -ArgumentList $argList -Wait -NoNewWindow
}

Set-Location $sourceFolder
$AllFiles = Get-ChildItem -Filter "GRMN????.mp4" | Sort-Object -Property LastWriteTime

[string[]] $currentList = @()
$lastTime = ""
$lastExactTime = ""
$alreadySawLastTime = $false
foreach ($file in $allFiles) {
    #Write-Output $file.Name
    $thisExactTime = $file.LastWriteTime
    $thisTime = $thisExactTime.AddSeconds(-$thisExactTime.Second)
    if ($currentList.Length -eq 0) {
        # a new list, so we prime it
        $currentList += $file.Name
        # the start hour and minute will be the time the file was written, minus one minute
        # because the last write is at the _end_ of the minute
        $firstDate = $thisExactTime.AddMinutes(-1).ToString("yyyy-MM-dd-HHmm")
    } elseif ($thisTime -eq $nextTime) {
        # the current file's write time is the expected next minute
        # this _should_ be the majority case
        $currentList += $file.Name
        # set up for the "new file" check later
        $alreadySawLastTime = $false
    } elseif (($thisTime -eq $lastTime) -and (-not $alreadySawLastTime)) {
        # the current file's write time is the same as the previous
        # same as previous is during last of a set or in the rare case of two very close starts
        # the problem is, we can't tell if it's the last or the start of the next
        # so we need to check that - if we haven't see the same last time minute,
        # then it's the last of the set.  If we have, then it's a new set.
        $currentList += $file.Name
        $alreadySawLastTime = $true
    } else {
        # we're some future time or the same as the previous minute but already saw
        # the last minute; so either way, a new set
        New-MergedVideo $currentList $firstDate 
        [string[]] $currentList = $file.Name
        $firstDate = $file.LastWriteTime.AddMinutes(-1).ToString("yyyy-MM-dd-HHmm")
    }
    # prime the next list
    $lastExactTime = $thisExactTime
    $lastTime = $thisTime
    $nextTime = $lastTime.AddMinutes(1)
}

# the last file set needs to be picked up so we fall through and do one more video
New-MergedVideo $currentList $firstDate
