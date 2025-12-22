compile = gcc -noixemul -Wall
targets = SendI2C ReceiveI2C I2CScan

all : $(targets) ;
         
ReceiveI2C : ReceiveI2C.c
	$(compile) ReceiveI2C.c -o ReceiveI2C

SendI2C : SendI2C.c
	$(compile) SendI2C.c -o SendI2C

I2CScan : I2CScan.c
	$(compile) I2CScan.c -o I2CScan

clean :
	delete $(targets)

