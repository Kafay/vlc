/*****************************************************************************
 * float32tos16.c : converter from float32 to signed 16 bits integer
 *****************************************************************************
 * Copyright (C) 2002 VideoLAN
 * $Id: float32tos16.c,v 1.5 2002/08/13 16:11:15 sam Exp $
 *
 * Authors: Christophe Massiot <massiot@via.ecp.fr>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111, USA.
 *****************************************************************************/

/*****************************************************************************
 * Preamble
 *****************************************************************************/
#include <errno.h>
#include <stdlib.h>                                      /* malloc(), free() */
#include <string.h>

#include <vlc/vlc.h>
#include "audio_output.h"
#include "aout_internal.h"

/*****************************************************************************
 * Local prototypes
 *****************************************************************************/
static int  Create    ( vlc_object_t * );

static void DoWork    ( aout_instance_t *, aout_filter_t *, aout_buffer_t *,
                        aout_buffer_t * );

/*****************************************************************************
 * Module descriptor
 *****************************************************************************/
vlc_module_begin();
    set_description( _("aout filter for float32->s16 conversion") );
    set_capability( "audio filter", 1 );
    set_callbacks( Create, NULL );
vlc_module_end();

/*****************************************************************************
 * Create: allocate trivial mixer
 *****************************************************************************
 * This function allocates and initializes a Crop vout method.
 *****************************************************************************/
static int Create( vlc_object_t *p_this )
{
    aout_filter_t * p_filter = (aout_filter_t *)p_this;

    if ( p_filter->input.i_format != AOUT_FMT_FLOAT32
          || p_filter->output.i_format != AOUT_FMT_S16_NE )
    {
        return -1;
    }

    if ( p_filter->input.i_rate != p_filter->output.i_rate
          || p_filter->input.i_channels != p_filter->output.i_channels )
    {
        return -1;
    }


    p_filter->pf_do_work = DoWork;
    p_filter->b_in_place = 1;

    return 0;
}

/*****************************************************************************
 * DoWork: convert a buffer
 *****************************************************************************/
static void DoWork( aout_instance_t * p_aout, aout_filter_t * p_filter,
                    aout_buffer_t * p_in_buf, aout_buffer_t * p_out_buf )
{
    int i;
    float * p_in = (float *)p_in_buf->p_buffer;
    s16 * p_out = (s16 *)p_out_buf->p_buffer;

    for ( i = p_in_buf->i_nb_samples * p_filter->input.i_channels ; i-- ; )
    {
#if 0
        /* Slow version */
        if ( *p_in >= 1.0 ) *p_out = 32767;
        else if ( *p_in < -1.0 ) *p_out = -32768;
        else *p_out = *p_in * 32768.0;
#else
        /* This is walken's trick based on IEEE float format. */
        s32 * p_value = (s32 *)p_in;
        *p_in += 384.0;
        if ( *p_value > 0x43c07fff ) *p_out = 32767;
        else if ( *p_value < 0x43bf8000 ) *p_out = -32768;
        else *p_out = *p_value - 0x43c00000;
#endif
        p_in++; p_out++;
    }

    p_out_buf->i_nb_samples = p_in_buf->i_nb_samples;
}

