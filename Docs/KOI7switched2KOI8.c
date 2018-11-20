/* From https://forum.maxiol.com/index.php?showtopic=4788 */

#include <stdio.h>
void main(int argc, char *argv[])
{
FILE *f1,*f2;
int cc,RUS=0;
if (argc==3)
  {
   f1 = fopen(argv[1],"rb");
   f2 = fopen(argv[2],"wb");
   while ((cc=getc(f1))!=EOF)
    {
     switch (cc)
      {
       case '\016':
        RUS=1; break;
       case '\017':
        RUS=0; break;
       default:
        if (cc>=64 && cc<=127 && RUS)
         cc=cc|128;
        putc(cc,f2);
      }
    }
   fclose(f1);
   fclose(f2);
  }
}
