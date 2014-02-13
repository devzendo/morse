#!/usr/bin/perl -w

################################################################################
###
### Filename         : histo.pl
### Purpose          : Displays bytes on stdin as a histogram
### Author           : Matt J. Gumbley
### Last updated     : 17/02/00
###
################################################################################
###
### Modification Record
###
################################################################################
###
### This program is free software; you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation; either version 2 of the License, or
### (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program; if not, write to the Free Software
### Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
###
################################################################################


#open A, "<foo" or die "can't open sample: $!\n";
my $byte;
while (read(STDIN, $byte, 1)) {
#  printf ("byte is 0x%02x\n", ord($byte));
  $len = 70 * (ord($byte) / 255);
  printf ("%3d ", ord($byte));
  print "#" x $len . "\n";
}
#close A;

