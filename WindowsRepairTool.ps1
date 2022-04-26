function choiceMenu () {
    

    $Title = "Do you want to proceed further?"
    $Prompt = 
    "    ..............66\......66\.66\.................66\.................................................
    ..............66.|.6\..66.|\__|................66.|................................................
    ..............66.|666\.66.|66\.6666666\...6666666.|.666666\..66\..66\..66\..6666666\...............
    ..............66.66.66\66.|66.|66..__66\.66..__66.|66..__66\.66.|.66.|.66.|66.._____|..............
    ..............6666.._6666.|66.|66.|..66.|66./..66.|66./..66.|66.|.66.|.66.|\666666\................
    ..............666../.\666.|66.|66.|..66.|66.|..66.|66.|..66.|66.|.66.|.66.|.\____66\...............
    ..............66../...\66.|66.|66.|..66.|\6666666.|\666666..|\66666\6666..|666666..|..............
    ..............\__/.....\__|\__|\__|..\__|.\_______|.\______/..\_____\____/.\_______/...............
    ...................................................................................................
    ...................................................................................................
    ...................................................................................................
    ......................................................66\..........................................
    ......................................................\__|.........................................
    ...............666666\...666666\...666666\...666666\..66\..666666\.................................
    ..............66..__66\.66..__66\.66..__66\..\____66\.66.|66..__66\................................
    ..............66.|..\__|66666666.|66./..66.|.6666666.|66.|66.|..\__|...............................
    ..............66.|......66...____|66.|..66.|66..__66.|66.|66.|.....................................
    ..............66.|......\6666666\.6666666..|\6666666.|66.|66.|.....................................
    ..............\__|.......\_______|66..____/..\_______|\__|\__|.....................................
    ..................................66.|.............................................................
    ..................................66.|.............................................................
    ..................................\__|.............................................................
    ................66\.........................66\....................................................
    ................66.|........................66.|...................................................
    ..............666666\....666666\...666666\..66.|...................................................
    ..............\_66.._|..66..__66\.66..__66\.66.|...................................................
    ................66.|....66./..66.|66./..66.|66.|...................................................
    ................66.|66\.66.|..66.|66.|..66.|66.|...................................................
    ................\6666..|\666666..|\666666..|66.|...................................................
    .................\____/..\______/..\______/.\__|...................................................
    ...................................................................................................
    ...................................................................................................
    ..................................................................................................."
    write-output "Your current computername: $env:computername"
    $ipv4 = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.AddressState -eq "Preferred" -and $_.ValidLifetime -lt "24:00:00"}).IPAddress
    Write-Output "The current IP addresses assigned to $env:computername are: $ipv4"
    $Choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&1", "&2", "&3", "&4", "&5", "&6", "&7", "&8", "&9", "&10", "&11", "&12", "&13", "&14", "&R", "&L", "&C")
    $Default = 0
    $prompt = "
    |||||||| Do not run these scripts unless you understand the programming intention, this is not a toy.      ||||||||
    |||||||| Read the script/readme files and become familiar with the operations first.                       ||||||||
    Developed By: Chase Corbin



    Type one of the following numbers to use tool:

    1 Reload
    2 Rename Computer
    3 join {name of domain} domain
    4 Change workgroup name 
    5 Add admin members to the administrators group
    6 Run WSUS repair tool
    7 Run wuauclt commands
    8 Run Adobe acrobat license fix
    9 gpupdate
    10 ipconfig
    11 system information
    12 dism.exe
    13 sfc-scan
    14 change powercfg to never
    R RESTART
    L leave domain
    C Close App

    "
    # Prompt for the choice
    $Choice = $host.UI.PromptForChoice($Title, $Prompt, $Choices,$Default)

    # functions
    function reloadShell () {
        write-output "Reloading..."
        pause
        choiceMenu
    }
    function wsusRepairTool () {
        # this runs a cmd file that resets a few things to fix wsus bug 
        powershell -command "Start-Process wsus-repair.BAT -Verb runas"
        pause
        choiceMenu
    }
    function joinDomain () {
        $checkDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
        $addDomain = if ( $checkDomain -eq $true )
        {
            write-output "your computer is in a domain already."
        } 
        else 
        {
            write-output "Your not on the domain, lets fix that!"
            # prompt user input for domain name and join the domain that the user put
            $dc = Read-Host -Prompt "Enter the Domain you want to join:"
            Add-Computer -ComputerName $env:computername -DomainName $dc -Options JoinWithNewName -Credential $creds -Verbose -Force
        }
        $addDomain
        pause
        choiceMenu
    }
    function leaveDomain () {
        # join domain if the workgroup is set
        # Check if computer is part of a domain
        $checkDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
        $removeDomain = if ( $checkDomain -eq $true )
        {
            write-output "your computer is on the domain, lets take it off."
        # removes computers domain
            Remove-Computer -ComputerName $env:computername -Credential $creds -Verbose -Force
        } 
        else 
        {
            write-output "Your on a workgroup, lets leave it for now or run the join domain command next."
        }
        $removeDomain
        pause
        choiceMenu
    }
    function renameWindows () {
        # renames computer
        $newName = read-host -prompt "type the name you want to change this computers name to:"
        write-host "you put '$newName' for your new computer name"

        # domaincredential can be removed for local configs but you need this if its domain joined and you just want a name change.
        Rename-Computer -NewName $newName -domaincredential Domain-username -force
        pause
        choiceMenu
    }
    function addMembers () {
        # prompts user for members to add to local administrators group
        $member1 = Read-Host -Prompt "Enter the member name you want to put in the local admin group (domain\name):"
        
        Add-LocalGroupMember -Group "Administrators" -Member "$member1"
        pause
        choiceMenu
    } 
    function reset-power-timers () {
        # these control the display timeout on ac adapter and dc battery for laptop power management
        powercfg -change -monitor-timeout-ac 0
        powercfg -change -monitor-timeout-dc 0
        powercfg -change -standby-timeout-ac 0
        powercfg -change -standby-timeout-dc 0
    }


# extra functions for the future do not uncomment until they are finished.
   
    
    # function renameWindows () {}
    # function renameWindows () {}
    # function renameWindows () {}
    # function renameWindows () {}
    # function renameWindows () {}
    # function renameWindows () {}
    # function renameWindows () {}



    
    # Action based on the choice
    switch($Choice)
    {
        0 { reloadShell }
        1 { renameWindows }
        2 { joinDomain }
        3 { $workGroupName = Read-Host -Prompt "Type the workgroup name:";Add-Computer -WorkGroupName "$workGroupName" }
        4 { addMembers }
        5 { wsusRepairTool }
        6 { wuauclt /reportnow /detectnow }
        7 { start LicFix_21319.exe }
        8 { gpupdate /force }
        9 { ipconfig /all }
        10 { get-computerinfo }
        11 { write-output "this may take some time..."; dism.exe /Online /Cleanup-image /Restorehealth }
        12 { write-output "this may take some time..."; sfc /scannow }
        13 { reset-power-timers }
        14 { shutdown -r -t 0 }
        15 { leaveDomain }
        16 { exit }
    }
    pause
    ChoiceMenu
}

ChoiceMenu
