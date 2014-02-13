/*******************************************************************************
***
*** Filename         : morse.c
*** Purpose          : Morse Code generation routines
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
#include <fcntl.h>
#include <sys/soundcard.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

#include "morse.h"


/*#define DEBUG*/
/*#define SYNC*/
/*#define POST*/

#define SILENCE 128
#define VOLUME 120

static int fd;
static int wpm = 12;
static int elementspace = 0;
static int charspace = 0;
static int wordspace = 1;
static int freq = 440;
static int freqindex = 0;
static int samprate = 8000;
static int volume = VOLUME;
static int whitenoise = 1; /* increase for more white noise */
static int ditlen; /* length of the dit sample */
static int dahlen; /* length of the dah sample */
static double ditdur; /* duration of the dit sample */
static unsigned char lastwritten;

static unsigned char *dit = NULL; /* The samples... */
static unsigned char *dah = NULL;
static unsigned char *spdit = NULL;

/* Tables of morse lookups */
static char *letters[] = {
  /* a */ ".-",
  /* b */ "-...",
  /* c */ "-.-.",
  /* d */ "-..",
  /* e */ ".",
  /* f */ "..-.",
  /* g */ "--.",
  /* h */ "....",
  /* i */ "..",
  /* j */ ".---",
  /* k */ "-.-",
  /* l */ ".-..",
  /* m */ "--",
  /* n */ "-.",
  /* o */ "---",
  /* p */ ".--.",
  /* q */ "--.-",
  /* r */ ".-.",
  /* s */ "...",
  /* t */ "-",
  /* u */ "..-",
  /* v */ "...-",
  /* w */ ".--",
  /* x */ "-..-",
  /* y */ "-.--",
  /* z */ "--..",
};
static char *numbers[] = {
  /* 0 */ "-----",
  /* 1 */ ".----",
  /* 2 */ "..---",
  /* 3 */ "...--",
  /* 4 */ "....-",
  /* 5 */ ".....",
  /* 6 */ "-....",
  /* 7 */ "--...",
  /* 8 */ "---..",
  /* 9 */ "----.",
};
static char *specials[] = {
  /* . */ ".-.-.-",  /* 0 */
  /* , */ "--..--",  /* 1 */
  /* ? */ "..--..",  /* 2 */
  /* : */ "---...",  /* 3 */
  /* ' */ ".----.",  /* 4 */
  /* - */ "-....-",  /* 5 */
  /* / */ "-..-.",   /* 6 */
  /* ( */ "-.--.",   /* 7 */
  /* ) */ "-.--.-",  /* 8 */
  /* " */ ".-..-.",  /* 9 */
  /*ERR*/ "........",/* 10 */
  /* + */ ".-.-.", /* = AR */ /* 11 */
  /*CT */ "-.-.-",   /* 12 */
  /* = */ "-...-", /* = BT */ /* 13 */
  /*KN */ "-.--.",   /* 14 */
  /*VA */ "...-.-",  /* 15 */
};

#define FREQ_MAX 13
static int freqs[FREQ_MAX] = {
  440, 466, 494, 523, 554, 587, 622, 659, 698, 740, 784, 831, 880
};

/* note in scale:
 * freq = 440 * 2^(number of notes from A/12)
 */



static unsigned char *gensample(int *numsamples, int freq);
static void senddit();
static void senddah();
static void gap(int dits);
static char *xlat(unsigned char ch);
static void dump(char *fn, unsigned char *buf, int len);
 
void morse_close()
{
  if (fd)
    close(fd);
}

void morse_sendch(unsigned char ch)
{
char *morse = xlat(ch);
char *c;
  if (ch == ' ') {
    gap(5 + wordspace); /* Assume last character had 2 gaps at the end */
    return;
  }
  if (ch == '>') {
    if (freqindex < FREQ_MAX) {
      freq = freqs[++freqindex];
      morse_initialise(wpm, freq, samprate);
      return;
    }
  }
  else if (ch == '<') {
    if (freqindex > 0) {
      freq = freqs[--freqindex];
      morse_initialise(wpm, freq, samprate);
      return;
    }
  }

  c = morse;
  while (*c) {
    if (*c == '.')
      senddit();
    else if (*c == '-')
      senddah();
    gap(1 + elementspace);
    c++;
  }
  /* Send the inter-letter gap (we've just had one ditgap) */
  gap(2 + charspace);
}

void morse_initialise(int nwpm, int nfreq, int nsamprate)
{
int ditspersec; 
int i;

  /* Store globals */
  wpm = nwpm;
  freq = nfreq;
  samprate = nsamprate;

  if (fd) 
    close(fd);
  fd = open("/dev/dsp", O_WRONLY);
  if (fd == -1) {
    perror("Could not open /dev/dsp ");
    exit(1);
  }

  if (dit)
    free(dit);
  if (dah)
    free(dah);
  if (spdit)
    free(spdit);
  /* PARIS is the standard 5-character word; it is 50 dits long, incl.
   * inter-element gaps, letter gaps, and the final gap at the end of the word
   * (From the Amateur Radio Operating Manual).
   * 
   * Ergo, 50 elements/Word, at $wpm WPM...
   */
  ditspersec = (50 * wpm) / 60;
  /* And at the sample rate given... */
  ditlen = samprate / ditspersec;
  dahlen = ditlen * 3;
  /* These will be modified to give clean samples by gensample */
#ifdef DEBUG
  printf( "ditlen = %d (should be 800 for 12 wpm)\n", ditlen);
#endif
  /* Generate two samples... */
  dit = gensample(&ditlen, freq);
  dump("dit", dit, ditlen);
  dah = gensample(&dahlen, freq);
  dump("dah", dah, dahlen);

  spdit = (unsigned char *)calloc(ditlen, 1);
  for (i=0; i< ditlen; i++) 
    spdit[i] = SILENCE;

  /* How long is a dit, in microseconds? */
  ditdur = 1.0 / ditspersec;
#ifdef DEBUG
printf ("a dit is %.8f seconds long\n", ditdur);
#endif
  ditdur *= 1000000;
#ifdef DEBUG
  printf ("a dit is %.8f microseconds long\n", ditdur);
#endif
}

void morse_wait()
{
  ioctl(fd, SNDCTL_DSP_SYNC, 0);
}



static char *xlat(unsigned char ch)
{
  /* ignore specials */
  if (ch == '>' || ch == '<')
    return "";
  if (isalpha(ch))
    ch=tolower(ch);
  if (ch >= '0' && ch <= '9')
    return numbers[ch - '0'];
  if (ch >= 'a' && ch <= 'z')
    return letters[ch - 'a'];
  switch (ch) {
    case '.' : return specials[0];
    case ',' : return specials[1];
    case '?' : return specials[2];
    case ':' : return specials[3];
    case '\'' : return specials[4];
    case '-' : return specials[5];
    case '/' : return specials[6];
    case '(' : return specials[7];
    case ')' : return specials[8];
    case '"' : return specials[9];
    case K_ERR : return specials[10];
    case '+' : return specials[11];
    case K_AR : return specials[11];
    case K_CT : return specials[12];
    case '=' : return specials[13];
    case K_BT : return specials[13];
    case K_KN : return specials[14];
    case K_VA : return specials[15];
  }
printf("Unknown request %d (%c)\n", ch, ch);
  return "";
}


static void dump(char *fn, unsigned char *buf, int len)
{
int dfd = open(fn, O_WRONLY|O_CREAT);
  write(dfd, buf, len);
  close(dfd);
}


/* Create a sample of a sine wave, with damped edges. */
static unsigned char *gensample(int *numsamples, int freq)
{
#define PI 3.141592654
double twopi = PI * 2.0;
/* each cycle has samprate/freq samples */
double samplesPerCycle = samprate/freq;
double step = twopi/samplesPerCycle;
int lastsample = ((int)((*numsamples)/samplesPerCycle))*samplesPerCycle;
unsigned char *sample = (unsigned char *)malloc(*numsamples);
int x;
double i;
double y;
char v;
unsigned char u;
int cx;
  *numsamples = lastsample;
  /* what's last x before numsamples where i will be 0? I should truncate the
   * sample there... */
#ifdef DEBUG
  printf("creating sample with %d samples\n", *numsamples);
#endif
  if (!sample) {
    printf("Out of memory allocating sample of %d bytes\n", *numsamples);
    exit(1);
  }
  i = 0.0;
  for (x=0; x < lastsample; x++, i+=step) {
    y = sin(i); /* -1 <= i <= 1 */
    /* Round off the edges of the sample */
    if (x<80) {
      y *= ((double)x/80.0);
    }
    if (x>(lastsample-80)) {
      y *= ((double)(lastsample-x)/80.0);
    }

    v = (int)(y * volume); /* -volume <= v <= volume */
    u = (unsigned char)(v + SILENCE);
/*
    v = (int)(y * 127.0);
    u = (unsigned char)(v + 126);
*/
#ifdef DEBUG
    fprintf(stderr,"x=%d, sin = %f, sample = %d, usample = %d\n", x,y,v,u);
    fprintf(stderr,"%4d %3d ", x, u);
    for (cx=0; cx < (int)((u*70)/255); cx++) {
      fprintf(stderr,"x");
    }
    fprintf(stderr,"\n");
#endif
    sample[x] = u;
  }

  return sample;
}

static void senddit()
{
int i;
unsigned int b;
  for (i=0; i< ditlen; i++) {
    b = dit[i] ^ (random() & whitenoise);
    write(fd, &b, 1);
    lastwritten = b;
  }
#ifdef SYNC
  ioctl(fd, SNDCTL_DSP_SYNC, 0);
#endif
#ifdef POST
  ioctl(fd, SNDCTL_DSP_POST, 0);
#endif
}

static void senddah()
{
int i;
unsigned int b;
  for (i=0; i< dahlen; i++) {
    b = dah[i] ^ (random() & whitenoise);
    write(fd, &b, 1);
    lastwritten = b;
  }
#ifdef SYNC
  ioctl(fd, SNDCTL_DSP_SYNC, 0);
#endif
#ifdef POST
  ioctl(fd, SNDCTL_DSP_POST, 0);
#endif
}


static void gap(int dits)
{
int i,j;
unsigned int b;
  for (j=0; j< dits; j++) {
    for (i=0; i< ditlen; i++) {
/*      b = spdit[i] ^ (random() & whitenoise);*/
      b = lastwritten;
      write(fd, &b, 1);
    }
#ifdef SYNC
    ioctl(fd, SNDCTL_DSP_SYNC, 0);
#endif
#ifdef POST
    ioctl(fd, SNDCTL_DSP_POST, 0);
#endif
  }
}

