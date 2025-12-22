/* Framegrabber example script
   Render forerver */
options results
address command
if (show('P','FGRAB'))==0 then do
  'run FrameGrab iconified'            /* start FrameGrab,if it's not */
  do while (show('P','FGRAB'))==0      /* running */
    'wait 1 secs'                      /* for that, it must be in the path */
  end
end
address fgrab
do forever
  'QUERY FROZEN'
  if result='TRUE' then 'FREEZE'       /* activate FrameGrabber */
  address command wait 1 secs
  'RENDER'
  address command wait 10 secs
end
