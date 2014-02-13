/*******************************************************************************
***
*** Filename         : typemorse.c
*** Purpose          : sends standard input in Morse
*** Author           : Matt J. Gumbley
*** Last updated     : 17/02/00
***
********************************************************************************
***
*** Modification Record
***
********************************************************************************
***
*** This program is free software; you can redistribute it and/or modify
*** it under the terms of the GNU General Public License as published by
*** the Free Software Foundation; either version 2 of the License, or
*** (at your option) any later version.
***
*** This program is distributed in the hope that it will be useful,
*** but WITHOUT ANY WARRANTY; without even the implied warranty of
*** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*** GNU General Public License for more details.
***
*** You should have received a copy of the GNU General Public License
*** along with this program; if not, write to the Free Software
*** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
***
*******************************************************************************/

#include <stdio.h>
#include "morse.h"

static int freq = 440;
static int samprate = 8000;
static int wpm = 12;

int main(int argc, char *argv[])
{
char ch;
  
/*  setvbuf(stdin, NULL, _IONBF, 1);*/

  morse_initialise(wpm, freq, samprate);
  while (read(0, &ch, 1) == 1) {
    if (ch != 10)
      morse_sendch(ch);
  }

  morse_close();
  return 0;
}


