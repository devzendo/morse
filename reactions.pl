#!/usr/bin/perl -w

################################################################################
###
### Filename         : reactions.pl
### Purpose          : Tests reactions of all morse characters, several times,
###                    and tells you which ones you are worst at.
### Author           : Matt J. Gumbley
### Last updated     : 24/02/00
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
use Term::ReadKey;
use Time::HiRes qw(gettimeofday tv_interval);
use Data::Dumper;

my @chars = qw{
a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 . , ?
/ *ERR *AR *CT *BT *KN *VA
};

# knocked out, since we don't need them:
# ' " ( ) : -

my $numchars = scalar(@chars);
my $maxrounds = 1;
my %stats = ();
my $errors = 0;
my $unknowns = 0;
my $lastch = ' ';
my $verbose = 0;
my $fh = FileHandle->new();
open $fh, "|./typemorse" or die "Can't open pipe to morse: $!\n";
$fh->autoflush();
print $fh ">";

print <<TXT;
Welcome to the Morse reaction test. You will hear all the Morse
characters including numbers, punctuation and prosigns several times. As soon as
you know which character you have heard, press that key (no need to press Return
after each character).

If you hear a character you do not know, press Return.

If you need to pause the test (and ignore the timing for the last couple of
characters, in case you were disturbed by someone interrupting you), press
Space, and then Space again to resume.

We will go through the entire set once without recording your reactions, and
if you need to pause (with Space), we will test a few more characters upon
resumption, without recording their times.

When finished, a report file will be produced called reactions.<date>.txt
showing your performance. The characters you took longest to respond to are
shown at the top, so you know which ones you need to work on.

Prosigns: Label your keyboard accordingly:
F3 - ERR
F4 - AR            SPACE - PAUSE
F5 - BT
F6 - CT            PASS - RETURN
F7 - KN
F8 - VA
Press Return to start!
TXT
my $trash = (<STDIN>);
ReadMode 3;

resetcounts();
uptospeed();
foreach (1..$maxrounds) {
  resetrounddone();
  testreactions();
}
report();
close $fh;

END {
  ReadMode 0;
}

sub resetcounts
{
  my $i;
  $errors = 0;
  $unknowns = 0;
  foreach $i (@chars) {
    $stats{"$i"} = {
      'rounddone' => 0,
      'count' => 0,
      'low' => 999999,
      'high' => 0,
      'avg' => 0,
      'sum' => 0
    }
  }
}

sub resetrounddone
{
  my $i;
  $errors = 0;
  $unknowns = 0;
  foreach $i (@chars) {
    $stats{"$i"}{'rounddone'} = 0;
  }
}

sub uptospeed()
{
  foreach (0.. rand(10) + 4) {
    my $ch = sendrandom();
    my $key = getkey();
  }
}

sub testreactions
{
  while(testchar()){};
}


sub testchar
{
  # init counter
  my $t0 = [gettimeofday];
  my $ch = sendrandom();
  return undef unless $ch;
  # get character
  my $key = getkey();
  # get interval
  my $time = tv_interval ( $t0, [gettimeofday]);
  # Are they baffled?
  if ($key eq chr(10)) {
    print "It was $ch\n" if $verbose;
    $unknowns++;
    return;
  }
  # was it a pause?
  if ($key eq ' ') {
    print ">>>>>>>> PAUSED! <<<<<<<<\n";
    print ">> [Space to continue] <<\n";
    my $skey;
    do {
      $skey = ReadKey 0;
    }
    while ($skey != ' ');
    print "Sending test chars.....\n";
    uptospeed();
    return;
  }
  # was it right?
  if ($key ne $ch) {
    $errors ++;
    print "WRONG it was $ch\n" if $verbose;
  }
  else {
    print "I sent $ch, you replied $key, in $time secs\n" if $verbose;
#print "RECORDING $ch time $time\n";
    $stats{"$ch"}{'count'}++;
    $stats{"$ch"}{'rounddone'}=1;
    $stats{"$ch"}{'sum'} += $time;
    $stats{"$ch"}{'low'} = $time if ($time < $stats{"$ch"}{'low'});
    $stats{"$ch"}{'high'} = $time if ($time > $stats{"$ch"}{'high'});
  }
  return 1;
}

sub getkey
{
  my $key = ReadKey 0;
  if (substr($key, 0, 1) eq chr(27)) {
    $key = ReadKey 0;
    $key = ReadKey 0;
    $key = ReadKey 0;
    $key = substr($key, 0, 1);
#print "function key ". ord($key)."\n";;
    if ($key eq chr(51)) { # F3 - ERR
      $key = '*ERR';
    }
    if ($key eq chr(52)) { # F4 - AR
      $key = '*AR';
    }
    if ($key eq chr(53)) { # F5 - BT
      $key = '*BT';
    }
    if ($key eq chr(55)) { # F6 - CT
      $key = '*CT';
    }
    if ($key eq chr(56)) { # F7 - KN
      $key = '*KN';
    }
    if ($key eq chr(57)) { # F8 - VA
      $key = '*VA';
    }
    my $trash = ReadKey 0;
  }
  return $key;
}

sub sendrandom()
{
  my $ch;
#  do {
    $ch = getrandom();
  return undef unless $ch;
#  } while ($ch eq $lastch);
#  $lastch = $ch;
  # xlat string
  my $send = $ch;
  $send = chr(5) if ($send eq '*ERR');
  $send = chr(1) if ($send eq '*AR');
  $send = chr(3) if ($send eq '*CT');
  $send = chr(2) if ($send eq '*BT');
  $send = chr(11) if ($send eq '*KN');
  $send = chr(22) if ($send eq '*VA');
  print $fh "$send\n";
  return $ch;
}

sub getrandom
{
#print "\n\n GETRANDOM\n";
  my $i = int(rand($numchars));
  my $c = $chars[$i];
#print "looking at char $c\n";
#print "done is " . $stats{"$c"}{'rounddone'} . "\n";
  my $retry= 0 ;
  while ($stats{"$c"}{'rounddone'} == 1) {
#print "that's the max, searching...\n";
    $i++;
    if ($i > $#chars) {
#print "i has reached bound ($i) - wrapping\n";
      $i = 0 
    }
    $c = $chars[$i];
#print "looking at char $c\n";
#print "done is " . $stats{"$c"}{'rounddone'} . "\n";
    $retry ++;
    if ($retry > $numchars) {
      return undef;
    }
  }
#print "returning $c\n";
  return $c;
}

sub report
{
  my $date = scalar(localtime());
  $date =~ s/ /-/g;
  my $file = "reactions.$date.txt";
  my $report = "CHR LOW   AVG   HIGH  | HISTOGRAM\n";
  # Calculate averages
  my $i;
  my $largestavg = 0.0;
#print "largest avg is $largestavg\n";
print "counts:\n";
  foreach $i (sort(keys (%stats))) {
    print "$i : " . $stats{"$i"}{'count'} . "\n";
  }
  foreach $i (keys (%stats)) {
print "checking $i:" . Dumper($stats{"$i"}) . "\n";
    if ($stats{"$i"}{'count'} != $maxrounds) {
      print "bug: $maxrounds != char $i's count of " . $stats{"$i"}{'count'} .  "\n";
    }
#print "char $i sum " . $stats{"$i"}{'sum'} . " count " . $stats{"$i"}{'count'};
    $stats{"$i"}{'avg'} = $stats{"$i"}{'sum'} / $stats{"$i"}{'count'};
#print " avg ". $stats{"$i"}{'avg'} . "\n";
    $largestavg = $stats{"$i"}{'avg'} if ($stats{"$i"}{'avg'} > $largestavg);
  }
  # Order report by largest average time
  my @keys = sort { $stats{"$a"}{'avg'} <=> $stats{"$b"}{'avg'} } keys (%stats);
  foreach $i (reverse @keys) {
    my $avg = $stats{"$i"}{'avg'};
    my $histo = int(($avg / $largestavg) * 60);
    my $histstr = '#' x $histo;
    $report .= sprintf("%3s %.3f %.3f %.3f | %s\n", 
                      $i, $stats{"$i"}{'low'}, $avg, $stats{"$i"}{'high'}, $histstr);
  }
  open OUT, ">$file" or die "Can't create $file: $!\n";
  print OUT $report;
  close OUT;
  print $report;
}

