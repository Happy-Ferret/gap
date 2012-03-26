/* MP3.h - this file is part of Cynthiune
 *
 * Copyright (C) 2002, 2003, 2004 Wolfgang Sourdeau
 *
 * Author: Wolfgang Sourdeau <wolfgang@contre.com>
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef MP3_H
#define MP3_H

@protocol Format;

#define IBUFFER_SIZE 5 * 8192

typedef mad_fixed_t MadFixed;

typedef struct _audioDither {
  MadFixed error[3];
  MadFixed random;
} audioDither;

typedef enum _InputBufferStatus
{
  BufferHasUnrecoverableError = -2,
  BufferHasRecoverableError = -1,
  BufferHasNoError = 0
} InputBufferStatus;

typedef struct mad_frame MadFrame;
typedef struct mad_header MadHeader;
typedef struct mad_stream MadStream;
typedef struct mad_synth MadSynth;
typedef struct mad_bitptr MadBitPtr;

@interface MP3 : NSObject <CynthiuneBundle, Format>
{
  BOOL metadataRead;

  unsigned int channels;
  unsigned long rate;

  unsigned int duration;
  unsigned int size;

  unsigned int lostSyncs;

  FILE *mf;

  MadFrame frame;
  MadStream stream;
  MadSynth synth;

  int iRemain, oRemain;
  unsigned char iBuffer[IBUFFER_SIZE];

  audioDither leftDither, rightDither;

  NSString *openFilename;

  BOOL opened;
}

@end

typedef struct {
    @defs (MP3);
} CMp3;

#endif /* MP3_H */