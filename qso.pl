#!/usr/bin/perl

################################################################################
###
### Filename         : qso.pl
### Purpose          : Sends amateur QSO's
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
use integer;

@prefix = ('M', 'MM', 'P');
@wx = ('wet', 'windy', 'hot', 'sticky', 'calm', 'cool', 'stormy', 'cold',
'freezing', 'tropical', 'mild');
@names = qw/
AL ALAN ALICE ALLEN ALTON AMBER AMY ANDREW ANDY ANGELA ANN ANTHONY ARLENE ART
ARTHUR AUDREY BARB BARBARA BARRY BEN BETH BETTY BILL BLAKE BOB BOBBIE BOBBY
BONNIE BRAD BRIAN BRYAN BRUCE CARL CAROL CASEY CATHERINE CHARLENE CHARLES
CHARLEY CHARLOTTE CHERYL CHESTER CHET CHRIS CHUCK CLARENCE CLIFF CLYDE COLLEEN
CONNIE CONSTANCE CRAIG CURT CYNTHIA DALE DAN DARRELL DAVE DAVID DAWN DEAN DEB
DEBBIE DEBRA DENISE DENNIS DIANE DON DONALD DONNA DOROTHY DOUG DOUYGLAS DUANE
EARL EILEEN ERIC ERNIE EUGENE FLORENCE FRAN FRANK FRED GARY GENE GEORGE GERTRUDE
GORDON GLENDA GLENN GLORIA GREG HAL HANK HARLAN HAROLD HARRY HOWARD HOWIE HUGH
IRV JACK JAMES JAMIE JAN JANET JAY JEAN JEFF JENNIFER JENNY JERRY JIM JIMMY JO
JOAN JOANNE JOE JOEL JOEY JOHN JONATHAN JOYCE JUDITH JUDY JULIA JULIE KAREN
KATHLEEN KATHRYN KATHY KATIE KATRINA KELLY KEN KENNETH KEVIN KIM KIMBERLY KYLE
LACEY LARRY LAUREN LEE LEN LINDA LISA LIZ LLOYD LOIS LON LORI LOU LOUISE LOWELL
LUKE LYLE LYNN MAC MARIAN MARILYN MARK MARSHA MARTIN MARTY MARV MARVIN MARY MATT
MAUREEN MAX MEG MEL MELISSA MERRILL MICHAEL MIKE MIMI NANCY NATHAN NEIL NELL
NICK NORM OLIVIA ORVILLE OSCAR OWEN PAM PAMELA PAT PATRICIA PATSY PATTY PAUL
PAULA PAULINE PEGGY PERRY PETE PETER PHYLLIS RALPH RANDY RAY RAYMOND REGGIE REX
RHONDA RICH RICHARD RICK RITA ROB ROBERT ROCKY ROD ROGER RON ROY ROYCE RUDY RUSS
RUTH SALLY SAM SANDRA SANDY SARAH SCOTT SCOTTY SHEILA SHIRLEY SKIP STAN STEVE
SUE SUSAN SUSIE SYLVIA TIM TED TERESA TERRI TERRY TODD TOM TONY TRAVIS VERN
VICKIE VIRGINIA WAYNE WILL
/;


my $fh = FileHandle->new();
open $fh, "|./typemorse" or die "Can't open pipe to morse: $!\n";
$fh->autoflush();
print $fh  ">";
print $fh "        \n";
foreach (1..40) {
  $cs1 = callsign();
  $cs2 = callsign();
  $cq = 0;
  $s = '';
  if (rand(100) < 5) {
    $cq = 1;
    $s .= "cq cq ";
    $s .= "dx " if (rand(10) > 3);
    $s .= "de ";
  }
  $s .= $cs1;
  unless ($cq) {
    if (rand(100) > 5) {
      $s .= " de ";
      $s .= $cs2;
      $s .= " = ";
    }
    if (rand(10) > 2) {
      $s .= "ur rst ";
      $s .= chr(rand(5)+1 + 48);
      $s .= chr(rand(9)+1 + 48);
      $s .= chr(rand(9)+1 + 48);
      $s .= " = ";
    }
    if (rand(10) > 3) {
      $s .= "wx is " . $wx[rand(scalar(@wx))] . " = ";
    }
    if (rand(10) > 3) {
      $s .= "name is " . $names[rand(scalar(@names))] . " = ";
    }
    $s .= "$cs1 de $cs2 kn";
  }
  else {
    $s .= "k";
  }
  $s .= "   ";
  print "$s\n";
  print $fh "$s\n";
}

print $fh "        \n";

sub callsign
{
  my $s = '';
  $s .= randchar();
  $s .= randchar() if (rand(10) > 5);
  $s .= randdigit();
  $s .= randchar();
  $s .= randchar();
  $s .= randchar() if (rand(10) > 3);
  if (rand(10) > 7) {
    $s .= '/';
    $s .= $prefix[rand(3)];
  }
  return $s;
}


sub randchar
{
  $i = rand(26);
  return chr ($i + 65);
}
sub randdigit
{
  $i = rand(10);
  return chr ($i + 48);
}

