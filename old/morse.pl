#!/usr/bin/perl -w

################################################################################
###
### Filename         : morse.pl
### Purpose          : Sends morse code (old, not-quite-there version of morse.c)
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



use strict;
use FileHandle;
$^W = 1;

# Open the sound card
my $fh = FileHandle->new();
open $fh, ">/dev/dsp" or die "Can't open /dev/dsp: $!\n";
#$fh->autoflush();

my $wpm = 8;
my $freq = 440;
my $samprate = 8000;
# These will hold the dit and dah samples
my @dit = ();
my @dah = ();
my $ditdur = 0; # length of a dit in seconds


sub initialise;
sub gensample;
sub sendch;
sub gap;

# Morse lookup table
my %morse = (
  'a' => '.-',
  'b' => '-...',
  'c' => '-.-.',
  'd' => '-..',
  'e' => '.',
  'f' => '..-.',
  'g' => '--.',
  'h' => '....',
  'i' => '..',
  'j' => '.---',
  'k' => '-.-',
  'l' => '.-..',
  'm' => '--',
  'n' => '-.',
  'o' => '---',
  'p' => '.--.',
  'q' => '--.-',
  'r' => '.-.',
  's' => '...',
  't' => '-',
  'u' => '..-',
  'v' => '...-',
  'w' => '.--',
  'x' => '-..-',
  'y' => '-.--',
  'z' => '--..',
  '1' => '.----',
  '2' => '..---',
  '3' => '...--',
  '4' => '....-',
  '5' => '.....',
  '6' => '-....',
  '7' => '--...',
  '8' => '---..',
  '9' => '----.',
  '0' => '-----',
  '.' => '.-.-.-',
  ',' => '--..--',
  '?' => '..--..',
  ':' => '---...',
  "'" => '.----.',
  '-' => '-....-',
  '/' => '-..-.',
  '(' => '-.--.',
  ')' => '-.--.-',
  '"' => '.-..-.',
  'ERR' => '........',
  '+' => '.-.-.',
  'AR' => '.-.-.',
  'CT' => '-.-.-',
  '=' => '-...-',
  'BT' => '-...-',
  'KN' => '-.--.',
  'VA' => '...-.-',
);


initialise($wpm, $freq, $samprate);

# Process input
my $prosign = 0;
my $command = 0;
while (<>) {
  my $i;
  for ($i=0; $i<length($_); $i++) {
    my $ch = substr($_, $i, 1);
    if ($command) {
    }
    # Process command and prosign indicators
    if ($ch eq '*') {
      $command = 1;
      next;
    }
    if ($ch eq '_') {
      $prosign = 1;
      next;
    }
    else {
      $ch =~ tr/A-Z/a-z/;
      if ($ch =~ /[a-z0-9\?\.,+=:'-\/\(\)"]/) {
        sendch($ch);
      }
      elsif ($ch eq ' ') {
        gap(6); # probably just had 1 gap at end of character
      }
    }
  }
}

# All done
close $fh;


sub sendch
{
  my $letter = shift;
  return unless (defined $morse{$letter});
  my $out = $morse{$letter};
  my $element;
  # Send the letter
  my $i;
  for ($i=0; $i < length($out); $i++) {
    my $element = substr($out, $i, 1);
    warn "sending $element\n";
    dit() if ($element eq '.');
    dah() if ($element eq '-');
    gap(1);
  }
  warn "\n";
  # Send the inter-letter gap (we've just had one ditgap)
  gap(2);
}

sub initialise
{
  my $wpm = shift;
  my $freq = shift;
  my $samprate = shift;
  # PARIS is the standard 5-character word; it is 50 dits long, incl.
  # inter-element gaps, letter gaps, and the final gap at the end of the word
  # (From the Amateur Radio Operating Manual).
  #
  # Ergo, 50 elements/Word, at $wpm WPM...
  my $ditspersec = (50 * $wpm) / 60;
  # And at the sample rate given...
  my $ditlen = $samprate / $ditspersec;
warn "ditlen = $ditlen (should be 800 for 12 wpm)\n";
  # Generate two samples...
  gensample (\@dit, $ditlen, $freq);
  gensample (\@dah, $ditlen * 3, $freq);
warn "dit has " . scalar(@dit) . " samples\n";
warn "dah has " . scalar(@dah) . " samples\n";
  # How long is a dit, in seconds?
  $ditdur = 1.0 / $ditspersec;
warn "a dit is $ditdur seconds long\n";
}

sub gensample
{
  my $arrref = shift;
  my $numsamples = shift;
  my $freq = shift;
warn "creating sample with $numsamples samples\n";
  # Create a sample of a sine wave, with damped edges.
  my $pi = 3.141592654;
  my $twopi = 2.0 * $pi;
  my $twopibythree = (2.0 * $pi)/ 3.0;
  my $halfpi = $pi / 2.0;
  my $step = $twopi/($samprate/$freq);
warn "step is $step\n";
=head
  my $start = 0;
  my $end = int($numsamples/$twopi);
  my $iter;
  for ($iter=0; $iter < ($numsamples/$twopi); $iter++) {
    my $i;
    for ($i=$start;  $i<($start+$twopi); $i+= $step ) {
      my $y = sin($i);
      my $v = int($y * 127) + 128;
      push(@{$arrref}, $v);
      if ($iter == $end-1) {
        goto OUT if ($v < 12);
      }
    }
  }
=cut
  my $iter;
  my $i = 0.0;
  for ($iter=0; $iter < $numsamples; $iter++, $i+=$step) {
    my $y = sin($i);
    my $v = int($y * 127) + 128;
    push(@{$arrref}, $v);
  }
return;
  OUT:
  # round off the edges of the sample
  my $fact = 0;
  my $rndlen = 80;
  for ($i=0; $i<$rndlen; $i++) {
    $$arrref[$i] *= $fact;
    $$arrref[$i * -1] *= $fact;
    $fact += (1/$rndlen );
  }
}

sub dit
{
  foreach (@dit) {
    print $fh pack 'C', $_;
  }
}

sub dah
{
  foreach (@dah) {
    print $fh pack 'C', $_;
  }
}

sub gap
{
  my $numdits = shift;
warn "gap of $numdits\n";
  select(undef, undef, undef, $ditdur * $numdits);
}

