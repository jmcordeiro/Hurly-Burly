/*

specCentroid - A non-real-time spectral centroid analysis external.

Copyright 2009 William Brent

This file is part of timbreID.

timbreID is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

timbreID is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


version 0.0.4, December 21, 2010

¥ 0.0.4 changed windowing functions so that they are computed ahead of time, this required considerable changes to the windowing stuff since 0.0.3 and before.  changed _bang() to remove needless end_samp calculation and pass length_samp rather than window to _analyze() so that windowing will not cover the zero padded section.  made power spectrum computation the first step, and changed the squaring function to a magnitude function instead.  in the case that power spectrum is used, this saves needless computation of sqrt and subsequent squaring. wherever possible, using getbytes() directly instead of getting 0 bytes and resizing.
¥Ê0.0.3 added an ifndef M_PI for guaranteed windows compilation
¥ 0.0.2 adds a #define M_PI for windows compilation, and declares all functions except _setup static

*/

#include "m_pd.h"
#include <math.h>
#include <string.h>
#include <limits.h>
#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795
#endif

static t_class *specCentroid_class;

typedef struct _specCentroid
{
    t_object x_obj;
    float sr;
	float window;
	int power_spectrum;
	int window_function;
	int window_func_size;
	int max_window_size;
	int *powers_of_two;
    int  pow_two_arr_size;
	t_sample *signal_R;
	float *blackman;
	float *cosine;
	float *hamming;
	float *hann;
	t_word *x_vec;
	t_symbol *x_arrayname;
	int x_array_points;
    t_outlet *x_centroid;

} t_specCentroid;




/* ---------------- dsp utility functions ---------------------- */

static void specCentroid_blackman_window(float *wptr, int n)
{
	int i;

	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.42 - (0.5 * cos(2*M_PI*i/n)) + (0.08 * cos(4*M_PI*i/n));
}


static void specCentroid_cosine_window(float *wptr, int n)
{
	int i;

	for(i=0; i<n; i++, wptr++)
    	*wptr = sin(M_PI*i/n);
}

static void specCentroid_hamming_window(float *wptr, int n)
{	
	int i;

	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.5 - (0.46 * cos(2*M_PI*i/n));
}

static void specCentroid_hann_window(float *wptr, int n)
{
	int i;

	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.5 * (1 - cos(2*M_PI*i/n));
}
 		
static void specCentroid_realfft_unpack(int n, int n_half, t_sample *input, t_sample *imag)
{
	int i, j;

	imag[0]=0.0;  // DC
	
	for(i=(n-1), j=1; i>n_half; i--, j++)
		imag[j] = input[i];
}

static void specCentroid_power(int n, t_sample *real, t_sample *imag)
{
	while (n--)
    {   
        *real = (*real * *real) + (*imag * *imag);
        real++;
        imag++;
    };
}

static void specCentroid_mag(int n, t_sample *power)
{
	while (n--)
	{
	    *power = sqrt(*power);
	    power++;
	}	 
}

/* ---------------- END utility functions ---------------------- */




/* ------------------------ specCentroid -------------------------------- */

static void specCentroid_analyze(t_specCentroid *x, t_floatarg start, t_floatarg n)
{
	int i, j, old_window, window, window_half, start_samp, end_samp, length_samp;
	float *window_func_ptr;
    float dividend, divisor, centroid;
	t_sample *signal_I;
	t_garray *a;

	if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
        pd_error(x, "%s: no such array", x->x_arrayname->s_name);
    else if(!garray_getfloatwords(a, &x->x_array_points, &x->x_vec))
    	pd_error(x, "%s: bad template for specCentroid", x->x_arrayname->s_name);
	else
	{

	start_samp = start;
	
	if(start_samp < 0)
		start_samp = 0;

	if(n)
		end_samp = start_samp + n-1;
	else
		end_samp = start_samp + x->window-1;
		
	if(end_samp > x->x_array_points)
		end_samp = x->x_array_points-1;

	length_samp = end_samp - start_samp + 1;

	if(end_samp <= start_samp)
	{
		error("bad range of samples.");
		return;
	}
		
	if(length_samp > x->powers_of_two[x->pow_two_arr_size-1])
	{
		post("WARNING: specCentroid: window truncated because requested size is larger than the current max_window setting. Use the max_window method to allow larger windows. Sizes of more than 131072 may produce unreliable results.");
		length_samp = x->powers_of_two[x->pow_two_arr_size-1];
		window = length_samp;
		end_samp = start_samp + window - 1;
	}
	else
	{
		i=0;
		while(length_samp > x->powers_of_two[i])
			i++;

		window = x->powers_of_two[i];
	}

	window_half = window * 0.5;

	if(x->window != window)
	{
		old_window = x->window;
		x->window = window;
		x->signal_R = (t_sample *)t_resizebytes(x->signal_R, old_window*sizeof(t_sample), window*sizeof(t_sample));
	}
	
	if(x->window_func_size != length_samp)
	{
		x->blackman = (float *)t_resizebytes(x->blackman, x->window_func_size*sizeof(float), length_samp*sizeof(float));
		x->cosine = (float *)t_resizebytes(x->cosine, x->window_func_size*sizeof(float), length_samp*sizeof(float));
		x->hamming = (float *)t_resizebytes(x->hamming, x->window_func_size*sizeof(float), length_samp*sizeof(float));
		x->hann = (float *)t_resizebytes(x->hann, x->window_func_size*sizeof(float), length_samp*sizeof(float));

		x->window_func_size = length_samp;
		
		specCentroid_blackman_window(x->blackman, x->window_func_size);
		specCentroid_cosine_window(x->cosine, x->window_func_size);
		specCentroid_hamming_window(x->hamming, x->window_func_size);
		specCentroid_hann_window(x->hann, x->window_func_size);
	}

	// create local memory
	signal_I = (t_sample *)getbytes(window_half*sizeof(t_sample));

	// construct analysis window
	for(i=0, j=start_samp; j<=end_samp; i++, j++)
		x->signal_R[i] = x->x_vec[j].w_float;

	// set window
	window_func_ptr = x->hann; //default case to get rid of compile warning
	switch(x->window_function)
	{
		case 0:
			window_func_ptr = x->blackman;
			break;
		case 1:
			window_func_ptr = x->cosine;
			break;
		case 2:
			window_func_ptr = x->hamming;
			break;
		case 3:
			window_func_ptr = x->hann;
			break;
		default:
			break;
	};
	
	// then multiply against the chosen window
	for(i=0; i<length_samp; i++, window_func_ptr++)
		x->signal_R[i] *= *window_func_ptr;

	// then zero pad the end
	for(; i<window; i++)
		x->signal_R[i] = 0.0;

	mayer_realfft(window, x->signal_R);
	specCentroid_realfft_unpack(window, window_half, x->signal_R, signal_I);
	specCentroid_power(window_half, x->signal_R, signal_I);

	if(!x->power_spectrum)
		specCentroid_mag(window_half, x->signal_R);

	dividend=0;
	divisor=0;
	centroid=0;
	
	for(i=0; i<window_half; i++)
		dividend += x->signal_R[i]*(i*(x->sr/window));  // weight by bin freq

	for(i=0; i<window_half; i++)
		divisor += x->signal_R[i];
		
	if(divisor==0) divisor = 1; // don't divide by zero
	
	centroid = dividend/divisor;
		
	outlet_float(x->x_centroid, centroid);

	// free local memory
	t_freebytes(signal_I, window_half*sizeof(t_sample));

	}
}


// analyze the whole damn array
static void specCentroid_bang(t_specCentroid *x)
{
	int window, start_samp, length_samp;
	t_garray *a;

	if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
        pd_error(x, "%s: no such array", x->x_arrayname->s_name);
    else if(!garray_getfloatwords(a, &x->x_array_points, &x->x_vec))
    	pd_error(x, "%s: bad template for specCentroid", x->x_arrayname->s_name);
	else
	{

	start_samp = 0;
	length_samp = x->x_array_points;

	if(length_samp > x->powers_of_two[x->pow_two_arr_size-1])
	{
		post("WARNING: specCentroid: window truncated because requested size is larger than the current max_window setting. Use the max_window method to allow larger windows.");
		length_samp = x->powers_of_two[x->pow_two_arr_size-1];
		window = length_samp;
	}

	specCentroid_analyze(x, start_samp, length_samp);

	}
}


static void specCentroid_set(t_specCentroid *x, t_symbol *s)
{
	t_garray *a;
	
	if(!(a = (t_garray *)pd_findbyclass(s, garray_class)))
		pd_error(x, "%s: no such array", s->s_name);
	else if(!garray_getfloatwords(a, &x->x_array_points, &x->x_vec))
		pd_error(x, "%s: bad template for specCentroid", s->s_name);
	else
	    x->x_arrayname = s;
}


static void specCentroid_samplerate(t_specCentroid *x, t_floatarg sr)
{
	if(sr<64)
		x->sr = 64;
	else
		x->sr = sr;

	post("samplerate: %i", (int)x->sr);
}


static void specCentroid_max_window(t_specCentroid *x, t_floatarg w)
{
	int i;
		
	if(w<64)
		x->max_window_size = 64;
	else
		x->max_window_size = w;

	x->powers_of_two = (int *)t_resizebytes(x->powers_of_two, x->pow_two_arr_size*sizeof(int), sizeof(int));

	x->powers_of_two[0] = 64; // must have at least this large of a window

	i=1;
	while(x->powers_of_two[i-1] < x->max_window_size)
	{
		x->powers_of_two = (int *)t_resizebytes(x->powers_of_two, i*sizeof(int), (i+1)*sizeof(int));
		x->powers_of_two[i] = pow(2, i+6); // +6 because we're starting at 2**6
		i++;
	}

	x->pow_two_arr_size = i;
	
	post("maximum window size: %i", x->max_window_size);
}


static void specCentroid_window(t_specCentroid *x, t_floatarg w)
{
	int isPow2;
	
	isPow2 = (int)w && !( ((int)w-1) & (int)w );
	
	if( !isPow2 )
		error("requested window size is not a power of 2.");
	else
	{
		x->signal_R = (t_sample *)t_resizebytes(x->signal_R, x->window * sizeof(t_sample), w * sizeof(t_sample));
	
		x->window = (int)w;
 		
		// init signal buffer
		memset(x->signal_R, 0, x->window*sizeof(t_sample));
					
		post("window size: %i. sampling rate: %i", (int)x->window, (int)x->sr);
	}
}


static void specCentroid_window_function(t_specCentroid *x, t_floatarg f)
{
	x->window_function = f;
	
	switch(x->window_function)
	{
		case 0:
			post("window function: blackman.");
			break;
		case 1:
			post("window function: cosine.");
			break;
		case 2:
			post("window function: hamming.");
			break;
		case 3:
			post("window function: hann.");
			break;
		default:
			break;
	};
}


// magnitude spectrum == 0, power spectrum == 1
static void specCentroid_power_spectrum(t_specCentroid *x, t_floatarg spec)
{
	x->power_spectrum = spec;
	
	if(x->power_spectrum)
		post("using power spectrum for spectrum computation.");
	else
		post("using magnitude spectrum for spectrum computation.");
}


static void *specCentroid_new(t_symbol *s)
{
    t_specCentroid *x = (t_specCentroid *)pd_new(specCentroid_class);
	int i;
	t_garray *a;

	x->x_centroid = outlet_new(&x->x_obj, &s_float);

	if(s)
	{
		x->x_arrayname = s;

	    if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
	        ;
	    else if(!garray_getfloatwords(a, &x->x_array_points, &x->x_vec))
	    	pd_error(x, "%s: bad template for specCentroid", x->x_arrayname->s_name);
	}
	else
		error("specCentroid: no array specified.");

	x->sr = 44100.0;
	x->window = 1; // should be a bogus size initially to force the proper resizes when a real _analyze request comes through
	x->window_func_size = 1;
	x->window_function = 3;
	x->power_spectrum = 0;

	x->max_window_size = 131072; // this seems to be the maximum size allowable by mayer_realfft();
	x->powers_of_two = (int *)getbytes(sizeof(int));

	x->powers_of_two[0] = 64; // must have at least this large of a window

	i=1;
	while(x->powers_of_two[i-1] < x->max_window_size)
	{
		x->powers_of_two = (int *)t_resizebytes(x->powers_of_two, i*sizeof(int), (i+1)*sizeof(int));
		x->powers_of_two[i] = pow(2, i+6); // +6 because we're starting at 2**6
		i++;
	}

	x->pow_two_arr_size = i;

	x->signal_R = (t_sample *)getbytes(x->window*sizeof(t_sample));

	// initialize signal_R
	memset(x->signal_R, 0, x->window*sizeof(t_sample));
	
    return (x);
}


static void specCentroid_free(t_specCentroid *x)
{
	// free the input buffer memory
    t_freebytes(x->signal_R, x->window*sizeof(t_sample));

    t_freebytes(x->blackman, x->window_func_size*sizeof(float));
    t_freebytes(x->cosine, x->window_func_size*sizeof(float));
    t_freebytes(x->hamming, x->window_func_size*sizeof(float));
    t_freebytes(x->hann, x->window_func_size*sizeof(float));
    
	// free the powers of two table
    t_freebytes(x->powers_of_two, x->pow_two_arr_size*sizeof(int));
}


void specCentroid_setup(void)
{
    specCentroid_class = 
    class_new(
    	gensym("specCentroid"),
    	(t_newmethod)specCentroid_new,
    	(t_method)specCentroid_free,
        sizeof(t_specCentroid),
        CLASS_DEFAULT, 
        A_DEFSYM,
		0
    );

	class_addbang(specCentroid_class, specCentroid_bang);

	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_analyze,
		gensym("analyze"),
        A_DEFFLOAT,
        A_DEFFLOAT,
		0
	);

	class_addmethod(
		specCentroid_class,
		(t_method)specCentroid_set,
		gensym("set"),
		A_SYMBOL,
		0
	);

	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_window,
		gensym("window"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_samplerate,
		gensym("samplerate"),
		A_DEFFLOAT,
		0
	);
	
	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_max_window,
		gensym("max_window"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_window_function,
		gensym("window_function"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specCentroid_class, 
        (t_method)specCentroid_power_spectrum,
		gensym("power_spectrum"),
		A_DEFFLOAT,
		0
	);
}