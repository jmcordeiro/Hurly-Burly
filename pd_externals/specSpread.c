/*

specSpread - A non-real-time spectral spread analysis external.

Copyright 2009 William Brent

This file is part of timbreID.

timbreID is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

timbreID is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


version 0.0.5, December 23, 2011

¥ 0.0.5 incorporates the tIDLib.h header
¥ 0.0.4 changed windowing functions so that they are computed ahead of time, this required considerable changes to the windowing stuff since 0.0.3 and before.  changed _bang() to remove needless end_samp calculation and pass length_samp rather than window to _analyze() so that windowing will not cover the zero padded section.  made power spectrum computation the first step, and changed the squaring function to a magnitude function instead.  in the case that power spectrum is used, this saves needless computation of sqrt and subsequent squaring. wherever possible, using getbytes() directly instead of getting 0 bytes and resizing.
¥Ê0.0.3 added an ifndef M_PI for guaranteed windows compilation
¥ 0.0.2 adds a #define M_PI for windows compilation, and declares all functions except _setup static

*/

#include "tIDLib.h"

static t_class *specSpread_class;

typedef struct _specSpread
{
    t_object x_obj;
    t_float sr;
	t_float window;
	int powerSpectrum;
	int windowFunction;
	int windowFuncSize;
	int maxWindowSize;
	int *powersOfTwo;
    int powTwoArrSize;
    t_float *binFreqs;
	t_sample *signal_R;
	t_float *blackman;
	t_float *cosine;
	t_float *hamming;
	t_float *hann;
	t_word *x_vec;
	t_symbol *x_arrayname;
	int x_arrayPoints;
    t_outlet *x_spread;
} t_specSpread;



static void sSpread_blackmanWindow(t_float *wptr, int n)
{
	int i;
    
	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.42 - (0.5 * cos(2*M_PI*i/n)) + (0.08 * cos(4*M_PI*i/n));
}

static void sSpread_cosineWindow(t_float *wptr, int n)
{
	int i;
    
	for(i=0; i<n; i++, wptr++)
    	*wptr = sin(M_PI*i/n);
}

static void sSpread_hammingWindow(t_float *wptr, int n)
{
	int i;
    
	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.5 - (0.46 * cos(2*M_PI*i/n));
}

static void sSpread_hannWindow(t_float *wptr, int n)
{
	int i;
    
	for(i=0; i<n; i++, wptr++)
    	*wptr = 0.5 * (1 - cos(2*M_PI*i/n));
}



int sSpread_signum(t_sample sample)
{
	int sign, crossings;
	
	sign=0;
	crossings=0;
	
	if(sample>0)
		sign = 1;
	else if(sample<0)
		sign = -1;
	else
		sign = 0;
	
	return(sign);
}

t_float sSpread_zeroCrossingRate(int n, t_sample *input)
{
	int i;
	t_float crossings;
	
	crossings = 0.0;
	
	for(i=1; i<n; i++)
		crossings += fabs(sSpread_signum(input[i]) - sSpread_signum(input[i-1]));
	
	crossings *= 0.5;
    
	return(crossings);
}

void sSpread_realfftUnpack(int n, int nHalf, t_sample *input, t_sample *imag)
{
	int i, j;
    
	imag[0]=0.0;  // DC
    
	for(i=(n-1), j=1; i>nHalf; i--, j++)
		imag[j] = input[i];
    
	imag[nHalf]=0.0;  // Nyquist
}

void sSpread_power(int n, t_sample *real, t_sample *imag)
{
	while (n--)
    {
        *real = (*real * *real) + (*imag * *imag);
        real++;
        imag++;
    };
}

void sSpread_mag(int n, t_sample *power)
{
	while (n--)
	{
	    *power = sqrt(*power);
	    power++;
	}
}

void sSpread_normal(int n, t_sample *input)
{
	int i;
	t_float sum, normScalar;
	
	sum=0;
	normScalar=0;
	
	for(i=0; i<n; i++)
		sum += input[i];
    
	sum = (sum==0)?1.0:sum;
    
	normScalar = 1.0/sum;
	
	for(i=0; i<n; i++)
		input[i] *= normScalar;
}

void sSpread_log(int n, t_sample *spectrum)
{
	while (n--)
    {
		// if to protect against log(0)
    	if(*spectrum==0)
    		*spectrum = 0;
    	else
	        *spectrum = log(*spectrum);
        
        spectrum++;
    };
}

void sSpread_realifft(int n, int nHalf, t_sample *real, t_sample *imag)
{
    int i, j;
    t_float nRecip;
    
	for(i=(nHalf+1), j=(nHalf-1); i<n; i++, j--)
		real[i] = imag[j];
    
    mayer_realifft(n, real);
    
    nRecip = 1.0/(t_float)n;
    
    // normalize by 1/N, since mayer doesn't
	for(i=0; i<n; i++)
		real[i] *= nRecip;
}

void sSpread_cosineTransform(t_float *output, t_sample *input, int numFilters)
{
	int i, k;
	t_float piOverNfilters;
    
	piOverNfilters = M_PI/numFilters; // save multiple divides below
    
	for(i=0; i<numFilters; i++)
    {
	   	output[i] = 0;
        
		for(k=0; k<numFilters; k++)
 	    	output[i] += input[k] * cos(i * (k+0.5) * piOverNfilters);  // DCT-II
	};
}


void sSpread_filterbankMultiply(t_sample *spectrum, int normalize, int filterAvg, t_filter *filterbank, int numFilters)
{
	int i, j, k;
	t_float sum, sumsum, *filterPower;
    
	// create local memory
	filterPower = (t_float *)t_getbytes(numFilters*sizeof(t_float));
    
 	sumsum = 0;
    
	for(i=0; i<numFilters; i++)
	{
	   	sum = 0;
        
		for(j=filterbank[i].indices[0], k=0; j<=filterbank[i].indices[1]; j++, k++)
	    	sum += spectrum[j] * filterbank[i].filter[k];
        
		if(filterAvg)
			sum /= k;
        
		filterPower[i] = sum;  // get the total power.  another weighting might be better.
        
 		sumsum += sum;  // normalize so power in all bands sums to 1
	};
    
	if(normalize)
	{
		// prevent divide by 0
		if(sumsum==0)
			sumsum=1;
		else
			sumsum = 1/sumsum; // take the reciprocal here to save a divide below
	}
	else
		sumsum=1;
    
	for(i=0; i<numFilters; i++)
		spectrum[i] = filterPower[i]*sumsum;
    
	// free local memory
	t_freebytes(filterPower, numFilters*sizeof(t_float));
}

/* ---------------- END dsp utility functions ---------------------- */


/* ------------------------ specSpread -------------------------------- */

static void specSpread_analyze(t_specSpread *x, t_floatarg start, t_floatarg n)
{
	int i, j, oldWindow, window, windowHalf, startSamp, endSamp, lengthSamp;
    t_float dividend, divisor, centroid, spread, *windowFuncPtr;
	t_sample *signal_I;
	t_garray *a;

	if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
        pd_error(x, "%s: no such array", x->x_arrayname->s_name);
    else if(!garray_getfloatwords(a, &x->x_arrayPoints, &x->x_vec))
    	pd_error(x, "%s: bad template for specSpread", x->x_arrayname->s_name);
	else
	{

	startSamp = start;
	startSamp = (startSamp<0)?0:startSamp;

	if(n)
		endSamp = startSamp + n-1;
	else
		endSamp = startSamp + x->window-1;

	if(endSamp > x->x_arrayPoints)
		endSamp = x->x_arrayPoints-1;

	lengthSamp = endSamp-startSamp+1;

	if(endSamp <= startSamp)
	{
		error("bad range of samples.");
		return;
	}

	if(lengthSamp > x->powersOfTwo[x->powTwoArrSize-1])
	{
		post("WARNING: specSpread: window truncated because requested size is larger than the current max_window setting. Use the max_window method to allow larger windows.");
		lengthSamp = x->powersOfTwo[x->powTwoArrSize-1];
		window = lengthSamp;
		endSamp = startSamp + window - 1;
	}
	else
	{
		i=0;
		while(lengthSamp > x->powersOfTwo[i])
			i++;

		window = x->powersOfTwo[i];
	}

	windowHalf = window * 0.5;

	if(x->window != window)
	{
		oldWindow = x->window;
		x->window = window;

		x->signal_R = (t_sample *)t_resizebytes(x->signal_R, oldWindow*sizeof(t_sample), x->window*sizeof(t_sample));

		x->binFreqs = (t_float *)t_resizebytes(x->binFreqs, oldWindow*sizeof(t_float), window*sizeof(t_float));
	
		// freqs for each bin based on current window size and sample rate
		for(i=0; i<window; i++)
			x->binFreqs[i] = (x->sr/window)*i;
	}

	if(x->windowFuncSize != lengthSamp)
	{
		x->blackman = (t_float *)t_resizebytes(x->blackman, x->windowFuncSize*sizeof(t_float), lengthSamp*sizeof(t_float));
		x->cosine = (t_float *)t_resizebytes(x->cosine, x->windowFuncSize*sizeof(t_float), lengthSamp*sizeof(t_float));
		x->hamming = (t_float *)t_resizebytes(x->hamming, x->windowFuncSize*sizeof(t_float), lengthSamp*sizeof(t_float));
		x->hann = (t_float *)t_resizebytes(x->hann, x->windowFuncSize*sizeof(t_float), lengthSamp*sizeof(t_float));

		x->windowFuncSize = lengthSamp;

		sSpread_blackmanWindow(x->blackman, x->windowFuncSize);
		sSpread_cosineWindow(x->cosine, x->windowFuncSize);
		sSpread_hammingWindow(x->hamming, x->windowFuncSize);
		sSpread_hannWindow(x->hann, x->windowFuncSize);
	}

	// create local memory
	signal_I = (t_sample *)t_getbytes((windowHalf+1)*sizeof(t_sample));

	// construct analysis window
	for(i=0, j=startSamp; j<=endSamp; i++, j++)
		x->signal_R[i] = x->x_vec[j].w_float;

	// set window function
	windowFuncPtr = x->hann; //default case to get rid of compile warning

	switch(x->windowFunction)
	{
		case 0:
			break;
		case 1:
			windowFuncPtr = x->blackman;
			break;
		case 2:
			windowFuncPtr = x->cosine;
			break;
		case 3:
			windowFuncPtr = x->hamming;
			break;
		case 4:
			windowFuncPtr = x->hann;
			break;
		default:
			break;
	};

	// if windowFunction == 0, skip the windowing (rectangular)
	if(x->windowFunction>0)
		for(i=0; i<lengthSamp; i++, windowFuncPtr++)
			x->signal_R[i] *= *windowFuncPtr;

	// then zero pad the end
	for(; i<window; i++)
		x->signal_R[i] = 0.0;

	mayer_realfft(window, x->signal_R);
	sSpread_realfftUnpack(window, windowHalf, x->signal_R, signal_I);
	sSpread_power(windowHalf+1, x->signal_R, signal_I);

	// power spectrum sometimes generates lower scores than magnitude. make it optional.
	if(!x->powerSpectrum)
		sSpread_mag(windowHalf+1, x->signal_R);

	dividend=0;
	divisor=0;
	centroid=0;
	
	for(i=0; i<=windowHalf; i++)
	{
		dividend += x->signal_R[i] * x->binFreqs[i];  // weight by bin freq
		divisor += x->signal_R[i];
	}
	
	divisor = (divisor==0)?1.0:divisor; // don't divide by zero
	
	centroid = dividend/divisor;

	dividend=0;
	spread=0;

	for(i=0; i<=windowHalf; i++)
		dividend += ( (x->binFreqs[i] - centroid) * (x->binFreqs[i] - centroid) ) * x->signal_R[i];

	spread = sqrt(dividend/divisor);
		
	outlet_float(x->x_spread, spread);

	// free local memory
	t_freebytes(signal_I, (windowHalf+1)*sizeof(t_sample));
	}
}


// analyze the whole damn array
static void specSpread_bang(t_specSpread *x)
{
	int window, startSamp, lengthSamp;
	t_garray *a;

	if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
        pd_error(x, "%s: no such array", x->x_arrayname->s_name);
    else if(!garray_getfloatwords(a, &x->x_arrayPoints, &x->x_vec))
    	pd_error(x, "%s: bad template for specSpread", x->x_arrayname->s_name);
	else
	{

	startSamp = 0;
	lengthSamp = x->x_arrayPoints;

	if(lengthSamp > x->powersOfTwo[x->powTwoArrSize-1])
	{
		post("WARNING: specSpread: window truncated because requested size is larger than the current max_window setting. Use the max_window method to allow larger windows. Sizes of more than 131072 may produce unreliable results.");
		lengthSamp = x->powersOfTwo[x->powTwoArrSize-1];
		window = lengthSamp;
	}

	specSpread_analyze(x, startSamp, lengthSamp);

	}
}


static void specSpread_set(t_specSpread *x, t_symbol *s)
{
	t_garray *a;

	if(!(a = (t_garray *)pd_findbyclass(s, garray_class)))
		pd_error(x, "%s: no such array", s->s_name);
	else if(!garray_getfloatwords(a, &x->x_arrayPoints, &x->x_vec))
		pd_error(x, "%s: bad template for specSpread", s->s_name);
	else
	    x->x_arrayname = s;
}


static void specSpread_print(t_specSpread *x)
{
	post("samplerate: %f", x->sr);
	post("window: %f", x->window);

	post("power spectrum: %i", x->powerSpectrum);
	post("window function: %i", x->windowFunction);
}


static void specSpread_samplerate(t_specSpread *x, t_floatarg sr)
{
	int i;

	if(sr<64)
		x->sr = 64;
	else
		x->sr = sr;

	// freqs for each bin based on current window size and sample rate
	for(i=0; i<x->window; i++)
		x->binFreqs[i] = (x->sr/x->window)*i;
}


static void specSpread_max_window(t_specSpread *x, t_floatarg w)
{
	int i;

	if(w<64)
		x->maxWindowSize = 64;
	else
		x->maxWindowSize = w;

	x->powersOfTwo = (int *)t_resizebytes(x->powersOfTwo, x->powTwoArrSize*sizeof(int), sizeof(int));

	x->powersOfTwo[0] = 64; // must have at least this large of a window

	i=1;
	while(x->powersOfTwo[i-1] < x->maxWindowSize)
	{
		x->powersOfTwo = (int *)t_resizebytes(x->powersOfTwo, (i)*sizeof(int), (i+1)*sizeof(int));
		x->powersOfTwo[i] = pow(2, i+6); // +6 because we're starting at 2**6
		i++;
	}

	x->powTwoArrSize = i;

	post("maximum window size: %i", x->maxWindowSize);
}


static void specSpread_windowFunction(t_specSpread *x, t_floatarg f)
{
    f = (f<0)?0:f;
    f = (f>4)?4:f;
	x->windowFunction = f;

	switch(x->windowFunction)
	{
		case 0:
			post("window function: rectangular.");
			break;
		case 1:
			post("window function: blackman.");
			break;
		case 2:
			post("window function: cosine.");
			break;
		case 3:
			post("window function: hamming.");
			break;
		case 4:
			post("window function: hann.");
			break;
		default:
			break;
	};
}


// magnitude spectrum == 0, power spectrum == 1
static void specSpread_powerSpectrum(t_specSpread *x, t_floatarg spec)
{
    spec = (spec<0)?0:spec;
    spec = (spec>1)?1:spec;
	x->powerSpectrum = spec;

	if(x->powerSpectrum)
		post("using power spectrum for specSpread computation.");
	else
		post("using magnitude spectrum for specSpread computation.");
}


static void *specSpread_new(t_symbol *s)
{
    t_specSpread *x = (t_specSpread *)pd_new(specSpread_class);
	int i;
	t_garray *a;

	x->x_spread = outlet_new(&x->x_obj, &s_float);
	
	if(s)
	{
		x->x_arrayname = s;

	    if(!(a = (t_garray *)pd_findbyclass(x->x_arrayname, garray_class)))
	        ;
	    else if(!garray_getfloatwords(a, &x->x_arrayPoints, &x->x_vec))
	    	pd_error(x, "%s: bad template for specSpread", x->x_arrayname->s_name);
	}
	else
		error("specSpread: no array specified.");

	x->sr = 44100.0;
	x->window = 1; // should be a bogus size initially to force the proper resizes when a real _analyze request comes through
	x->windowFuncSize = 1;
	x->windowFunction = 4; // 4 is hann window
	x->powerSpectrum = 0; // choose mag (0) or power (1) spec in the specSpread computation

	x->maxWindowSize = MAXWINDOWSIZE; // this seems to be the maximum size allowable by mayer_realfft();
	x->powersOfTwo = (int *)t_getbytes(sizeof(int));

	x->powersOfTwo[0] = 64; // must have at least this large of a window

	i=1;
	while(x->powersOfTwo[i-1] < x->maxWindowSize)
	{
		x->powersOfTwo = (int *)t_resizebytes(x->powersOfTwo, i*sizeof(int), (i+1)*sizeof(int));
		x->powersOfTwo[i] = pow(2, i+6); // +6 because we're starting at 2**6
		i++;
	}

	x->powTwoArrSize = i;

	x->signal_R = (t_sample *)t_getbytes(x->window*sizeof(t_sample));

	for(i=0; i<x->window; i++)
		x->signal_R[i] = 0.0;

  	x->blackman = (t_float *)t_getbytes(x->windowFuncSize*sizeof(t_float));
  	x->cosine = (t_float *)t_getbytes(x->windowFuncSize*sizeof(t_float));
  	x->hamming = (t_float *)t_getbytes(x->windowFuncSize*sizeof(t_float));
  	x->hann = (t_float *)t_getbytes(x->windowFuncSize*sizeof(t_float));

 	// initialize signal windowing functions
	sSpread_blackmanWindow(x->blackman, x->windowFuncSize);
	sSpread_cosineWindow(x->cosine, x->windowFuncSize);
	sSpread_hammingWindow(x->hamming, x->windowFuncSize);
	sSpread_hannWindow(x->hann, x->windowFuncSize);

	x->binFreqs = (t_float *)t_getbytes(x->window*sizeof(t_float));

    return (x);
}


static void specSpread_free(t_specSpread *x)
{
	// free the input buffer memory
    t_freebytes(x->signal_R, x->window*sizeof(t_sample));

	// free the window memory
    t_freebytes(x->blackman, x->windowFuncSize*sizeof(t_float));
    t_freebytes(x->cosine, x->windowFuncSize*sizeof(t_float));
    t_freebytes(x->hamming, x->windowFuncSize*sizeof(t_float));
    t_freebytes(x->hann, x->windowFuncSize*sizeof(t_float));

	// free the binFreqs memory
    t_freebytes(x->binFreqs, x->window*sizeof(t_sample));

	// free the powers of two table
    t_freebytes(x->powersOfTwo, x->powTwoArrSize*sizeof(int));
}


void specSpread_setup(void)
{
    specSpread_class =
    class_new(
    	gensym("specSpread"),
    	(t_newmethod)specSpread_new,
    	(t_method)specSpread_free,
        sizeof(t_specSpread),
        CLASS_DEFAULT,
        A_DEFSYM,
		0
    );

	class_addbang(specSpread_class, specSpread_bang);

	class_addmethod(
		specSpread_class,
        (t_method)specSpread_analyze,
		gensym("analyze"),
        A_DEFFLOAT,
        A_DEFFLOAT,
		0
	);

	class_addmethod(
		specSpread_class,
		(t_method)specSpread_set,
		gensym("set"),
		A_SYMBOL,
		0
	);

	class_addmethod(
		specSpread_class,
		(t_method)specSpread_print,
		gensym("print"),
		0
	);

	class_addmethod(
		specSpread_class,
        (t_method)specSpread_samplerate,
		gensym("samplerate"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specSpread_class,
        (t_method)specSpread_max_window,
		gensym("max_window"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specSpread_class,
        (t_method)specSpread_windowFunction,
		gensym("window_function"),
		A_DEFFLOAT,
		0
	);

	class_addmethod(
		specSpread_class,
        (t_method)specSpread_powerSpectrum,
		gensym("power_spectrum"),
		A_DEFFLOAT,
		0
	);
}

