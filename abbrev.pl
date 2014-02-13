#!/usr/bin/perl

################################################################################
###
### Filename         : abbrev.pl
### Purpose          : Sends amateur abbreviations and Q-Code
### Author           : Matt J. Gumbley
### Last updated     : 21/02/00
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

my @qcode = qw/
qra qrg qrh qri qrk qrl qrm qrn qro qrp qrq qrs qrt qru qrv qrx qrz qsa qsb qsd qsl
qso qsp qsv qsy qsz qth qtr
/;

my @abbrevs = qw/
abt adr af agn ani ant bcnu bd bfo bk blv bug ck cld condx crd cud cuagn cul cw
dr dx elbug enuf es fb fm fer fone freq ga gb gd ge gld gm gn gnd gud ham hi hpe
hr hrd hv hvy hw inpt lid mni mod msg mtr na nbfm nr ob om op ot pse pwr rprt rx
sa sed sig sked sn sri ssb stn sum swl tks tmw tnx trx tvi tx u ur vy w wid wkd
wkg wl wud wx xmtr xyl yl 73 88
/;

my @entire = (@qcode, @abbrevs);

my $fh = FileHandle->new();
open $fh, "|./typemorse" or die "Can't open pipe to morse: $!\n";
$fh->autoflush();
print $fh, ">";
print $fh "        \n";
for (;;) {
  $i = rand(scalar(@entire));
  print "$entire[$i]\n";
  print $fh "$entire[$i]  \n";
}

print $fh "        \n";


