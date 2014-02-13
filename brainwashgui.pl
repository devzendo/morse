#!/usr/bin/perl

################################################################################
###
### Filename         : brainwashgui.pl
### Purpose          : Displays the brainwash characters in a big window
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

use Tk qw/:eventtypes/;
use FileHandle;

$m = MainWindow->new();
$m->title("BrainWash");
$f = $m->Frame(-borderwidth => 10);
$t1 = $f->Label(-text => "-----------------------------------------------------------------------------");
$t1->pack(side=>'top');

$f->pack();
$l = $f->Label(-text => "", -font => 'Helvetica 400 bold');
$l->pack();
$t2 = $f->Label(-text => "-----------------------------------------------------------------------------");
$t2->pack(side=>'bottom');
yield();
yield();

$fh = FileHandle->new();
$buf = ' ' x 20;
open $fh, "./brainwash|" or die "Can't open pipe:$!\n";

$in = '';
for (;;){
  update();
  yield();
}


sub update
{
my $ch;
  sysread($fh, $ch, 1);
  if ($ch eq "\n") {
    #print "word is $in\n";
    $in =~ tr/a-z/A-Z/;
    $l->configure(-text => $in);
    $in = '';
  }
  else {
    #print "adding $ch\n";
    $in .= $ch;
  }
}

sub yield
{
  while (Tk::DoOneEvent(DONT_WAIT)) { };
}

