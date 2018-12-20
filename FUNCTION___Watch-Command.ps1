function Watch-Command {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [Parameter()]
        [int16]$Seconds = 10,
        [Parameter()]
        [ValidateSet('Numeric','Bar','HalfBar')]
        [string]$CountDownType = 'Bar'
    )

    function Start-CountDown {
        param(
            [Parameter(Mandatory)]
            [int16]$Seconds,
            [Parameter()]
            [ValidateSet('Numeric','Bar','HalfBar')]
            [string]$Type = 'Bar'
        )
        $Cy = [console]::CursorTop
        if ($Type -eq 'Bar' -and $Seconds -gt ([console]::WindowWidth/2)) {
            $Type = 'HalfBar'
        }
    
        switch ($Type) {
            'Numeric' {
                for ($i = 1; $i -le $Seconds; $i++) {
                    # set cursor to position before loop started (overwrite refresh counter)
                    [console]::SetCursorPosition(0,$Cy)
                    # output the counter, where '.' marks remaining seconds and 'o' passed seconds
                    Write-Host ("Refresh in $($Seconds-$i)" + ' ' * ($Seconds.ToString().Length - ($Seconds-$i).ToString().Length))
                    Start-Sleep -Seconds 1
                }            
            }
            'Bar' {
                for ($i = 1; $i -le $Seconds; $i++) {
                    # set cursor to position before loop started (overwrite refresh counter)
                    [console]::SetCursorPosition(0,$Cy)
                    # output the counter, where '.' marks remaining seconds and 'o' passed seconds
                    Write-Host ('Refresh in [' + 'o'*$i + '.'*($Seconds-$i) + ']')
                    Start-Sleep -Seconds 1
                }
              }
            'HalfBar' {
                for ($i = 1; $i -le $Seconds; $i++) {
                    # set cursor to position before loop started (overwrite refresh counter)
                    [console]::SetCursorPosition(0,$Cy)
                    # output the counter, where '.' marks remaining seconds and 'o' passed seconds
                    Write-Host ('Refresh in [' + 'O'*[math]::Floor($i/2) + 'o'*($i%2) + '.'*[math]::Floor(($Seconds+($Seconds%2)-$i)/2) + ']')
                    Start-Sleep -Seconds 1
                }
            }
    
            Default {}
        }

        [PSCustomObject]@{
            CursorY = $Cy
        }
    }


    $Output = $null
    $prevOutput = $null

    # Save current row position of cursor
    $C0y = [console]::CursorTop
    $C1y = 0    # set $C1y to avoid unnecessary "erase previous output" if there wasn't any, yet

    # run what ever the user throws at us and save the output. Throw any error encountered.
    try {
        $Output = & $ScriptBlock
    } catch {
        Throw $error[0]
    }
    $prevOutput = $Output

    try {
        # hide the cursor so nothing is blinking all the time
        [console]::CursorVisible = $false
        # if there is output, loop ...
        while ($Output) {

            # set cursor to original position to overwrite what ever was written in the run before
            [console]::SetCursorPosition(0,$C0y)
            # erase what was written before if there was one output already ($C1y was set) or new output differs from old
            if (($prevOutput -ne $Output) -and ($C1y)) {
                1..($C1y-$C0y+1) | ForEach-Object {' ' * ([console]::WindowWidth)}
                [console]::SetCursorPosition(0,$C0y)
            }

            # Output all the lines containing data
            $Output | Out-String

            $C1y = (Start-CountDown -Seconds $Seconds -Type $CountDownType).CursorY

            # run the scriptblock to watch again
            $prevOutput = $Output
            try {
                $Output = & $ScriptBlock
            } catch {
                Throw $error[0]
            }
        }
    } finally {
        # turn on the cursor again, even if the user hit Ctrl-C
        [console]::CursorVisible = $true
    }

}