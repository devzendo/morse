/*******************************************************************************
***
*** Filename         : brainwash.c
*** Purpose          : send random Morse characters
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
#include <time.h>

#include "morse.h"

static int freq = 440;
static int samprate = 8000;
static int wpm = 12;

/* define LIMITED if you want to train yourself with a limited subset */
#define LIMITED

#ifdef LIMITED
/* Place the characters you're having trouble with in here... */
char *duff = "dugbjwy";
#endif

unsigned char pickrandom()
{
long int r = random() % 2;
#ifdef LIMITED
  r = random() % strlen(duff);
  return duff[r];
#endif
  switch (r) {
    case 0: return 'a' + (random() % 25);
    case 1: return '0' + (random() % 9);
    case 2: 
      switch (random() % 15) {
        case 0: return '.';
        case 1: return ',';
        case 2: return '?';
        case 3: return ':';
        case 4: return '\'';
        case 5: return '-';
        case 6: return '/';
        case 7: return '(';
        case 8: return ')';
        case 9: return '"';
        case 10: return K_ERR;
        case 11: return K_AR;
        case 12: return K_CT;
        case 13: return K_BT;
        case 14: return K_KN;
        case 15: return K_VA;
      }
  }
  printf("bug in pickrandom\n");
}

void bigletter(unsigned char ch)
{
  switch (ch) {
    case K_ERR:
      printf("ERR");
      break;
    case K_AR:
      printf("-AR-");
      break;
    case K_CT:
      printf("-CT-");
      break;
    case K_BT:
      printf("-BT-");
      break;
    case K_KN:
      printf("-KN-");
      break;
    case K_VA:
      printf("-VA-");
      break;
    default:
      printf("%c", ch);
      break;
  }
  printf("\n");
  fflush(stdout);
}


int main(int argc, char *argv[])
{
char ch;

  morse_initialise(wpm, freq, samprate);
  srandom(time(NULL));
  for (;;) {
    ch = pickrandom();
    bigletter(ch);
    morse_sendch(ch);
    morse_wait();
  }
  morse_close();
  return 0;
}

