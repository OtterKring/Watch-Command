# Watch-Command / Monitoring a silent process
## Monitor some process you would have to manually run a status request on



### Why ...

We all know that some processes take longer than others. Synchronously running tasks may even show you a progress bar or some other continuously updated output while they are running. If you write such scripts by yourself you hopefully do that to keep the user informed.
The drawback is that your console is locked while the process is running. If you want to do something in parallel, you must open another console. No (easy) way around that.

Asynchronous tasks on the other hand, be it Powershell jobs or other processes running on your server you just triggered from your console, might run silently and once in a while, if you are interested in their progress, you have to run an additional command to get the current state of the process.

#### Example:

Lets assume you are administering some Microsoft Exchange E-Mail server and want to move a mailbox to another database.

You start the process with:

`New-MailboxMoveRequest mailbox -TargetDatabase target_db -BadItemLimit 100`

Given that everything was set up correctly the move will silently run through until it is done.

If you want to know more about the current state of all your currently running moves you run:

`Get-MailboxMoveRequest -MoveStatus inprogress | Get-MailboxMoveRequestStatistics`

**BUT** ... you have to run this *every time* you want to get an update on your move. This is ok, if you have other things to tinker with in your shell, but maybe you just want it to be automatically monitored, so everytime you take a look on your console window you see the up-to-date status.

This is exactly why I built this function.



### How to use the Watch-Command function


Basically `Watch-Command` works just like `Measure-Command` by handing a Scriptblock used to check your process' state to the function as a parameter:

`Watch-Command -Scriptblock {Get-MailboxMoveRequest -MoveStatus inprogress | Get-MailboxMoveRequestStatistics}`

By default, this will run the provided Scriptblock every ten seconds showing a custom progress bar counting down the seconds to the next refresh. To not clutter your console the previous output will be overwritten by the new one.

**NOTE:** if your Scriptblock produces no output, the function will quit!

If you want a diffent interval for the monitoring and maybe a less prominent numeric countdown you can also set that with parameters:

`Watch-Command -Scriptblock {...} -Seconds 120 -CountDownType Numeric`

Other possible values for `-CountDownType` are `Bar`, which is the default setting, and `HalfBar`. The latter will use two seconds for each counter position in the bar to save space. If you use `Bar` and request more seconds as intervall than half of your console windows counts in characters, the function will automatically switch to `HalfBar` for aestethic reasons.


### This is what it looks like (yeah, German console, sorry :-) )

    Watch-Command -ScriptBlock {gci d*} -Seconds 30 -CountDownType HalfBar


        Verzeichnis: C:\Users\hauptbenutzer
    

    Mode                LastWriteTime         Length Name
    ----                -------------         ------ ----
    d-r---       09.12.2018     09:07                Desktop
    d-r---       09.12.2018     11:52                Documents
    d-r---       21.12.2018     21:00                Downloads



    Refresh in [OOOo...........]





Hopefully, I could make the life of some of you easier.

Good luck and happy coding!
Max