/* Framegrabber example script
   Saving of an image sequence */
options results
parse arg name increment               /* Command line: FILE INCREMENT */
if increment <=0 then increment=5
if name=='' then name='T:Test1'
address command
if (show('P','FGRAB'))==0 then do
  'run FrameGrab iconified nomessages' /* start FrameGrab, if it's not */
  do while (show('P','FGRAB'))==0      /* running */
    'wait 1 secs'                      /* for that, it must be in the path */
  end
end
hours=time('H')
minutes=time('M')-60*hours             /* what time is it ? */
minutes=trunc(minutes/increment)*increment
address fgrab
'SET DISPMESSAGES FALSE'
'SET FILENUM TRUE'
'QUERY SAVEAS'
if result='ASK' then 'SET SAVEAS TRUECOLOR'
'SET FILENAME ' || name                /* set FrameGrabs variables */
address command wait 1 secs
do forever
  minutes=minutes+increment            /* wait until ? */
  if minutes>=60 then do
    minutes=minutes-60
    hours=hours+1
    if hours==24 then hours=0
  end
  say 'Waiting until ' || hours || ':' || minutes
  address command 'wait until ' || hours || ':' || minutes
  'QUERY FROZEN'
  if result='TRUE' then 'FREEZE'       /* activate FrameGrabber */
  address command wait 1 secs
  'CALCPICLEVEL'
  'QUERY SAVEAS'
  if result='SCREEN' then 'RENDER'
  'SAVE'
  'QUERY FILENAME'
  say 'Picture saved as: ' || result
end
