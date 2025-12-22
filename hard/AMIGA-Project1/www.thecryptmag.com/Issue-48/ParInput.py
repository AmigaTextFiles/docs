# An 8 channel event detector using standard Python, Version 1.4 minimum...
# This WILL run on a stock A1200, NO FastRAM is needed, but it helps. :)
# This is (C)2006, B.Walker, G0LCU. PAR_READ.lha from AMINET IS required.
# BEST VIEWED IN 640x200 using standard TOPAZ 8 FONTS.
# Press Ctrl-C or (Ctrl-D) to __STOP__ the program.

# Import any necessary module components.
import sys
import os
import time

# Test for genuine classic AMIGA platform.
# If it doesn't exist then completely quit the program and Python.
if sys.platform != 'amiga':
	print '\f'
	print 'This program is AMIGA A1200, (and greater), specific ONLY.'
	print
	print 'Closing down...'
	print
	time.sleep(3)
	# Shut down the program and Python.
	# Not really an error, so exit with ~RC~ of 0.
	sys.exit(0)

# If the correct platform print the version number.
if sys.platform == 'amiga':
	print '\f'
	print '$VER: Event_Detector_Version_0.90.34_(C)11-06-2006_B.Walker.'
	print
	# Ask for a check on the -ACK hardware.
	hw = raw_input('Is the board connected?, upper case ONLY, (Y/N):- ')
	# If NOT present don't allow program to run.
	# ONLY UPPERCASE ~Y~ IS ALLOWED!!!
	if hw != 'Y':
		print '\f'
		print 'The project MUST be connected or the system WILL hang.'
		print
		print 'Closing down...'
		print
		time.sleep(3)
		# Shut down the program and Python.
		# Not really an error, so exit with ~RC~ of 0.
		sys.exit(0)

# Established that the ~-ACK~ hardware from ~PAR_READ.lha~ IS connected.
# So now set up a working display that looks OK(ish :).
print '\f'
print '              8 Channel Event Detector, (C)2006, B.walker, G0LCU.'
print
print '                              No event detected.'

# This is the main working program. It is AMIGA compliant ONLY.
# Wake up the parallel port for use under this program.
pointer = open('PAR:', 'rb', 1)
mybyte = str(pointer.read(1))
# Put back to sleep again ready for general use.
pointer.close()

# This is the main coded segment.
def main():
	# Make ~mybyte~ and ~counter~ global.
	global mybyte
	global counter
	# Set both to 0.
	mybyte = 0
	counter = 0
	while 1:
		# Open a channel to the parallel port called ~pointer~.
		pointer = open('PAR:', 'rb', 1)
		# Read one byte, ~mybyte~, from that channel.
		mybyte = str(pointer.read(1))
		# Once read, immediately close that channel.
		pointer.close()
		# Set ~mybyte~ to decimal 0 to 255.
		mybyte = (ord(mybyte))
		# Subtract ~mybyte~ from 255 for easy coding! :)
		mybyte = 255-mybyte
		# Setup the main window again after any triggering.
		# The ~counter~ is used as a pseudo-time delay only.
		if mybyte == 0 and counter == 1000:
			counter = 0
			print '\f'
			print '              8 Channel Event Detector, (C)2006, B.Walker, G0LCU.'
			print
			print '                              No event detected.'
		# Now determine which line(s) has(have) been triggered.
		if mybyte >= 128 and mybyte <= 254:
			counter = 0
			print '\f'
			print 'Channel eight armed...'
			os.system('SYS:Utilities/Say "Channel EIGHT armed."')
			mybyte = mybyte - 128
		if mybyte >= 64 and mybyte <= 127:
			counter = 0
			print '\f'
			print 'Channel seven armed...'
			os.system('SYS:Utilities/Say "Channel SEVEN armed."')
			mybyte = mybyte - 64
		if mybyte >= 32 and mybyte <= 63:
			counter = 0
			print '\f'
			print 'Channel six armed...'
			os.system('SYS:Utilities/Say "Channel SIX armed."')
			mybyte = mybyte - 32
		if mybyte >= 16 and mybyte <= 31:
			counter = 0
			print '\f'
			print 'Channel five armed...'
			os.system('SYS:Utilities/Say "Channel FIVE armed."')
			mybyte = mybyte - 16
		if mybyte >= 8 and mybyte <= 15:
			counter = 0
			print '\f'
			print 'Channel four armed...'
			os.system('SYS:Utilities/Say "Channel FOUR armed."')
			mybyte = mybyte - 8
		if mybyte >= 4 and mybyte <= 7:
			counter = 0
			print '\f'
			print 'Channel three armed...'
			os.system('SYS:Utilities/Say "Channel THREE armed."')
			mybyte = mybyte - 4
		if mybyte >= 2 and mybyte <= 3:
			counter = 0
			print '\f'
			print 'Channel two armed...'
			os.system('SYS:Utilities/Say "Channel TWO armed."')
			mybyte = mybyte - 2
		if mybyte == 1:
			counter = 0
			print '\f'
			print 'Channel one armed...'
			os.system('SYS:Utilities/Say "Channel ONE armed."')
		# Add 1 to the pseudo-time delay.
		counter = counter + 1
		# When ~counter~ reaches 1001 set it to 0 again!!!.
		if counter >= 1001:
			counter = 0
main()
# Program End.
# DEAD SIMPLE EH!... :)
