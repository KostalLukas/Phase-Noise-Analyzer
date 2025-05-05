# -*- coding: utf-8 -*-
"""
Phase Noise Analyzer

Lukas Kostal, 3.5.2025, ETH Zurich
"""


import numpy as np
import matplotlib.pyplot as plt
import scipy.signal as ss
import scipy.fft as sf


# frequency and amplitude of signal
f_sig = 1e3
A = 1

# frequency and amplitude of periodic phase noise
f_pha = 3000
B = 0.2

# amplitude of random phase noise
C = 0.2

# filter cutoff frequency
fc = 5000

# time interval and number of samples
t = 1
n = int(1e5)

# sampling frequency
fs = n / t

# arrays of time and frequency
t_arr = np.linspace(0, t, n)
f_arr = np.linspace(0, fs, n)

# phase noise
pha = B * np.sin(2*np.pi * f_pha * t_arr) + C * np.random.rand(n)

# signal with noise
sig = A * np.sin(2*np.pi * f_sig * t_arr + pha)

# reference signal
ref = A * np.sin(2*np.pi * f_sig * t_arr + np.pi/4)
ref = np.sign(ref)

# mixed signal
mix = sig * ref

# filtered signal
sos = ss.butter(10, fc, 'lp', fs=fs, output='sos')
lpf = ss.sosfilt(sos, mix)

# power spectrum
spc = np.abs(sf.fft(lpf))

# plot signals in time
plt.figure(1)
plt.title('Signal in Time')
plt.xlabel(r'time $t$ (s)')
plt.ylabel(r'signal $x$ (V)')
plt.rc('grid', linestyle=':', color='black', alpha=0.8)
plt.grid()

plt.plot(t_arr, sig, c='r', label="noisy signal")
plt.plot(t_arr, ref, c='b', label="reference signal")
plt.xlim(0, 6 / f_sig)

plt.legend(loc=1)

# plot signal power spectrum
plt.figure(2)
plt.title('Phase Noise Power Spectrum')
plt.xlabel(r'frequency $f$ (Hz)')
plt.ylabel(r'spectral power $X$ ($\text{V}^2$)')
plt.rc('grid', linestyle=':', color='black', alpha=0.8)
plt.grid()

plt.plot(f_arr[2:], spc[2:], c='g')
plt.xlim(0, fs/2)

plt.show()

