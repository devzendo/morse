#!/usr/bin/perl

################################################################################
###
### Filename         : words.pl
### Purpose          : Sends words of increasing size (trains your ability to
###                    decode and spell simultaneously!!)
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



use FileHandle;

my $wordptrs = {
  2 => (),
  3 => (),
  4 => (),
  5 => (),
  6 => (),
  7 => (),
  other => ()
};

open WORDS, "</usr/dict/words" or die "Can't open /usr/dict/words: $!\n";
while (<WORDS>) {
  chomp;
  my $l = length($_);
  if ($l >= 2 && $l <= 7) {
    push (@{$wordptrs{$l}}, $_);
  }
  else {
    push (@{$wordptrs{other}}, $_);
  }
}
close WORDS;

my $fh = FileHandle->new();
open $fh, "|./typemorse" or die "Can't open pipe to morse: $!\n";
$fh->autoflush();
print $fh ">";
words(2, 20);
words(3, 40);
words(4, 50);
words(5, 50);
words(6, 50);
words(7, 50);
words('other', 50);
close $fh;

sub words
{
  my $len = shift;
  my $rept = shift;
  my $num = scalar(@{$wordptrs{$len}});
  print $fh "        \n";
  print "words of '$len' length...\n";
  foreach (1..$rept) {
    my $r = rand($num);
    print "$wordptrs{$len}[$r]\n";
    print $fh "$wordptrs{$len}[$r] \n";
    print $fh "$wordptrs{$len}[$r]    \n";
  }
  print $fh "        \n";
}

