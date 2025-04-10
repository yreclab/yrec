/* Filename: MakeLS
   Append a backslash to the end of each line except for the last. 
   used to build namelists from ls -Cx output  */
   
   
#include <stdio.h>

main()
{
   int InChar;		/* The input file is read into this, a character at a time */

   InChar = getc(stdin);   
   while (InChar != EOF)
   {
      while( (InChar != EOF) && InChar != '\n')
      {
         putc(InChar,stdout);
	 InChar = getc(stdin);
      }
      InChar = getc(stdin);
      if (InChar != EOF)
      {
         putc(' ',stdout);
	 putc('\\',stdout);
      }
      putc('\n',stdout);
  }
   return 0;
}
      
