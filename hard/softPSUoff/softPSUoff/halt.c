/* Poke 4 to bfd100 :) */
const char version[] = "$VER: Halt 1.01 (17.04.05) valwit.net";
int main(void)
{
  char *p = 0xbfd100;
  *p = 4;
}
