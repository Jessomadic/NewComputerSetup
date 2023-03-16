There are a few things you need to know before you get up and running

1)Run the .bat file as admin. If you don't some Ninite stuff won't install and the computer name will not change
2)DO NOT change the name of the folder the script looks for "Newinstall" and if it's changed it won't know where to find the files
3)(most likely already are but) Run this from a USB drive. For some reason, the command I used to find the file doesn't like coming from the C Drive 
4)Profit



Functions:
This script goes down the basics of what you need to do to set up a new computer
in this order it

Sets the active power plan for the computer

Makes it so the computer with not turn off the screen or go to sleep while plugged in

Sets the timezone to EST

Runs a Ninite file that installs the following programs

Firefox
Chrome
7zip
Notepad++
VLC
Foxit Reader
LibreOffice

It then will look for any Mcafee programs in 3 locations

C:\Program Files\McAfee
.\McAfee.com
or C:\Program Files (x86)\Common Files\McAfee
There is no way to make this uninstaller silent that is the cause of Mcafee being awful and making it as hard as possible to get rid of their nonsense

It will then prompt you for a new computer name
Make sure you follow the correct format for that client so that when RMM is installed (this script does not do that) it isn't loaded incorrectly
Even if it looks like it errored out as long as you run the script as admin and don't have another pending computer name change it will work

It then will scan the computer for Windows Updates
While it should find them on its own you will still have to go install them manually this just saves the time of having to wait for them to be found

You will then be prompted with a Windows 11 installer prompt
If you are setting up a new computer you will press 1(Yes)
If for some reason you are not installing Windows 11 press 2(No) and the script will end

After you press yes it will install the PC Health Check App on the computer (you don't need to interact with this but it needs to be on the computer for the windows 11 install to work)
Then the Windows 11 install will start silently in the background and the script will look to see if it is done every 60 seconds. If it is then a window will pop up saying the computer will restart in 30 mins
Ignore this as the computer will really restart 10 seconds after the script sees that this window has popped up
Once the computer finishes restarting you are done with the computer setup.