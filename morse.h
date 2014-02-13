/*******************************************************************************
***
*** Filename         : morse.h
*** Purpose          : API for morse.c
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

#ifndef _morse_h
#define _morse_h

#define K_ERR ('e' - 'a' + 1)
#define K_AR ('a' - 'a' + 1)
#define K_CT ('c' - 'a' + 1)
#define K_BT ('b' - 'a' + 1)
#define K_KN ('k' - 'a' + 1) /* 11 */
#define K_VA ('v' - 'a' + 1) /* 22 */
 
extern void morse_sendch(unsigned char ch);
extern void morse_initialise(int wpm, int freq, int samprate);
extern void morse_close();
extern void morse_wait();

#endif /* _morse_h */

