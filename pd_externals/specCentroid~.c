/*

specCentroid~

Copyright 2009 William Brent

This file is part of timbreID.

timbreID is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

timbreID is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


version 0.2.3, December 21, 2010

• 0.2.3 as part of timbreID-0.5 update, getting rid of unnecessary getbytes(0) calls. also adding power spectrum option. completely removing normalization functions (useless for this relative feature).
• 0.2.2 added an ifndef M_PI for guaranteed windows compilation
• 0.2.1 adds a #define M_PI for windows compilation, and declares all functions except _setup static
• 0.2.0 implements mayer_realfft
• Commenting out normalization since it's basically irrelevant in ratio measures lke this.
• 0.1.8 added normalization option

*/

#include "m_pd.h"
#include <math.h>
#include <limits.h>
#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795
#endif

static t_class *specCentroid_tilde_class;

typedef struct _specCentroid_tilde
{
    t_object x_obj;
    float sr;
    float n;
    int power_spectrum;
    int overlap;
    int window;
    double last_dsp_time;
    t_sample *signal_R;
    float *hann;
    float x_f;
    t_outlet *x_centroid;

} t_specCentroid_tilde;



/* ------------------------ spectrum functions -------------------------------- */

static void specCentroid_tilde_hann(int n, t_sample *in, float *hann)
{	
	while (n--)
    {
    	*in = *in * *hann;

    	in++;
    	hann++;
    };
}

static void specCentroid_tilde_realfft_unpack(int n, int n_half, t_sample *input, t_sample *imag)
{
	int i, j;
		
	imag[0]=0.0;  // DC
	
	for(i=(n-1), j=1; i>n_half; i--, j++)
		imag[j] = input[i];
}

static void specCentroid_tilde_power(int n, t_sample *real, t_sample *imag)
{
	while (n--)
    {   
        *real = (*real * *real) + (*imag * *imag);
        real++;
        imag++;
    };
}

static void specCentroid_tilde_mag(int n, t_sample *power)
{
	while (n--)
	{
	    *power = sqrt(*power);
	    power++;
	}	 
}

/* ------------------------ end spectrum functions -------------------------------- */



/* ------------------------ specCentroid~ -------------------------------- */

static void specCentroid_tilde_bang(t_specCentroid_tilde *x)
{
    int i, j, window, window_half, bang_sample;
    float dividend, divisor, centroid;
    t_sample *signal_R, *signal_I;
	double current_time;

    window = x->window;
    window_half = window*0.5;

	// create local memory
	signal_R = (t_sample *)getbytes(window*sizeof(t_sample));
	signal_I = (t_sample *)getbytes(window_half*sizeof(t_sample));
    
	current_time = clock_gettimesince(x->last_dsp_time);
	bang_sample = (int)(((current_time/1000.0)*x->sr)+0.5); // round

	if (bang_sample < 0)
        bang_sample = 0;
    else if ( bang_sample >= x->n )
        bang_sample = x->n - 1;
            
	// construct analysis window using bang_sample as the end of the window
	for(i=0, j=bang_sample; i<window; i++, j++)
		signal_R[i] = x->signal_R[j];
	
	specCentroid_tilde_hann(window, signal_R, x->hann);
	mayer_realfft(window, signal_R);
	specCentroid_tilde_realfft_unpack(window, window_half, signal_R, signal_I);
	specCentroid_tilde_power(window_half, signal_R, signal_I);
	
	if(!x->power_spectrum)
		specCentroid_tilde_mag(window_half, signal_R);

	dividend=0;
	divisor=0;
	centroid=0;
	
	for(i=0; i<window_half; i++)
		dividend += signal_R[i]*(i*(x->sr/window));  // weight by bin freq

	for(i=0; i<window_half; i++)
		divisor += signal_R[i];
		
	if(divisor==0) divisor = 1; // don't divide by zero
	
	centroid = dividend/divisor;
		
	outlet_float(x->x_centroid, centroid);

	// free local memory
	t_freebytes(signal_R, window * sizeof(t_sample));
	t_freebytes(signal_I, window_half * sizeof(t_sample));
}


static void specCentroid_tilde_window(t_specCentroid_tilde *x, t_floatarg f)
{
	int i, isPow2;
	
	isPow2 = (int)f && !( ((int)f-1) & (int)f );
	
	if( !isPow2 )
		error("requested window size is not a power of 2");
	else
	{
		x->signal_R = (t_sample *)t_resizebytes(x->signal_R, (x->window+x->n) * sizeof(t_sample), (f+x->n) * sizeof(t_sample));
		x->hann = (float *)t_resizebytes(x->hann, x->window * sizeof(float), f * sizeof(float));
		x->window = (int)f;
		
		for(i=0; i<x->window; i++)
			x->hann[i] = 0.5 * (1 - cos(2*M_PI*i/x->window));

		// init signal buffer
		for(i=0; i<(x->window+x->n); i++)
			x->signal_R[i] = 0.0;
					
		post("window size: %i. overlap: %i. sampling rate: %i", (int)x->window, x->overlap, (int)(x->sr/x->overlap));
	}
}


static void specCentroid_tilde_overlap(t_specCentroid_tilde *x, t_floatarg f)
{
	x->overlap = (int)f;

    post("overlap: %i", x->overlap);

}


// magnitude spectrum == 0, power spectrum == 1
static void specCentroid_tilde_power_spectrum(t_specCentroid_tilde *x, t_floatarg spec)
{
	x->power_spectrum = spec;
	
	if(x->power_spectrum)
		post("using power spectrum.");
	else
		post("using magnitude spectrum.");
}


static void *specCentroid_tilde_new(t_symbol *s, int argc, t_atom *argv)
{
    t_specCentroid_tilde *x = (t_specCentroid_tilde *)pd_new(specCentroid_tilde_class);
	int i, isPow2;
	s=s;
	
	x->x_centroid = outlet_new(&x->x_obj, &s_float);
	
	if(argc > 0)
	{
		x->window = atom_getfloat(argv);
		isPow2 = (int)x->window && !( ((int)x->window-1) & (int)x->window );
		
		if(!isPow2)
		{
			error("requested window size is not a power of 2. default value of 1024 used instead");
			x->window = 1024;
		};
	}
	else
		x->window = 1024;	
	
	
	x->sr = 44100.0;
	x->n = 64.0;
	x->overlap = 1;
	x->power_spectrum = 0;
	x->last_dsp_time = clock_getlogicaltime();

	x->signal_R = (t_sample *)getbytes((x->window+x->n) * sizeof(t_sample));
	x->hann = (float *)getbytes(x->window * sizeof(float));

	// initialize hann window
 	for(i=0; i<x->window; i++)
 		x->hann[i] = 0.5 * (1 - cos(2*M_PI*i/x->window));

 	for(i=0; i<(x->window+x->n); i++)
		x->signal_R[i] = 0.0;
		
    post("specCentroid~: window size: %i", (int)x->window);
    
    return (x);
}


static t_int *specCentroid_tilde_perform(t_int *w)
{
    int i, n;

    t_specCentroid_tilde *x = (t_specCentroid_tilde *)(w[1]);

    t_sample *in = (t_float *)(w[2]);
    n = w[3];
 			
 	// shift signal buffer contents back.
	for(i=0; i<x->window; i++)
		x->signal_R[i] = x->signal_R[i+n];
	
	// write new block to end of signal buffer.
	for(i=0; i<n; i++)
		x->signal_R[(int)x->window+i] = in[i];
		
	x->last_dsp_time = clock_getlogicaltime();

    return (w+4);
}


static void specCentroid_tilde_dsp(t_specCentroid_tilde *x, t_signal **sp)
{
	int i;
	
	dsp_add(
		specCentroid_tilde_perform,
		3,
		x,
		sp[0]->s_vec,
		sp[0]->s_n
	); 

// compare n to stored n and recalculate filterbank if different
	if( sp[0]->s_sr != x->sr || sp[0]->s_n != x->n )
	{
		x->signal_R = (t_sample *)t_resizebytes(x->signal_R, (x->window+x->n) * sizeof(t_sample), (x->window+sp[0]->s_n) * sizeof(t_sample));

		x->sr = sp[0]->s_sr;
		x->n = sp[0]->s_n;
		x->last_dsp_time = clock_getlogicaltime();

		// init signal buffer
		for(i=0; i<(x->window+x->n); i++)
			x->signal_R[i] = 0.0;
			
    	post("specCentroid~: window size: %i. overlap: %i. sampling rate: %i, block size: %i", (int)x->window, x->overlap, (int)(x->sr/x->overlap), (int)x->n);
	};
};

static void specCentroid_tilde_free(t_specCentroid_tilde *x)
{
	// free the input buffer memory
    t_freebytes(x->signal_R, (x->window+x->n)*sizeof(t_sample));

	// free the hann window memory
    t_freebytes(x->hann, x->window*sizeof(float));
}

void specCentroid_tilde_setup(void)
{
    specCentroid_tilde_class = 
    class_new(
    	gensym("specCentroid~"),
    	(t_newmethod)specCentroid_tilde_new,
    	(t_method)specCentroid_tilde_free,
        sizeof(t_specCentroid_tilde),
        CLASS_DEFAULT, 
        A_GIMME,
		0
    );

    CLASS_MAINSIGNALIN(specCentroid_tilde_class, t_specCentroid_tilde, x_f);

	class_addbang(specCentroid_tilde_class, specCentroid_tilde_bang);
	
	class_addmethod(
		specCentroid_tilde_class, 
        (t_method)specCentroid_tilde_window,
		gensym("window"),
		A_DEFFLOAT,
		0
	);
	
	class_addmethod(
		specCentroid_tilde_class, 
        (t_method)specCentroid_tilde_overlap,
		gensym("overlap"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specCentroid_tilde_class, 
        (t_method)specCentroid_tilde_power_spectrum,
		gensym("power_spectrum"),
		A_DEFFLOAT,
		0
	);

    class_addmethod(
    	specCentroid_tilde_class,
    	(t_method)specCentroid_tilde_dsp,
    	gensym("dsp"),
    	0
    );
}