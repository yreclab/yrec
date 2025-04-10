EOS_2005 Equation of State tables

>>NOTES<<
Revised tables were introduced on Feb. 22, 2006. These tables correct
an error in earlier tables.

There is small discountinuity in P/T and E/T at density=177 g/cc.
This is due to switching of calculational methods (see below).

The Z=0 tables extend to lower temperatue at high density than the Z=0.02 
and Z=0.04 tables.  This data is at or near the limits of the theory
and its use is only recommended for exploratory calculations.
>>END<<
_______________________________________________________________________
This directory contains equation of state data files for pure H, pure 
He, H-He mixtures and H-He mixtures having a small admixture of C-N-
O-Ne that update files available earlier on this site.  Rudimentary routines 
for interpolating the data are also provided.  The new equation of state 
tables have improved thermodynamic consistency and use a slightly 
modified method for treating the region of pressure ionization. 
The EOS_2005 tables cover temperature-density values 
encountered in stars having masses greater than about 0.1-0.15 solar.
-----------------------------------------------------------------------

	The activity expansion method is in principle thermodynamically 
consistent.  However, after the EOS_2001 tables were calculated it was 
realized that the calculational method used was not strictly consistent and 
also gave inaccurate estimates for the adiabatic gradient at high density.  
The main source of thermodynamic inconsistency was traced to an 
approximation introduced to help stabilize the iterative solution of the 
activity equations.  This approximation has not been used in the current 
calculations.  As a result, with a few exceptions, the new tables are 
thermodynamically consistent to better than 0.01% when dE/dRho is 
calculated by two different methods (E is energy and Rho is density).  We 
have also made a number of small changes in the physics, which mostly 
affect the pressure-ionization region.  It has proven to be difficult to apply 
the activity expansion method to high-density degenerate matter.  
Consequently, in the current work, we have used the activity expansion 
method only up to densities of 177 gm/cc, where stellar matter is nearly 
completely ionized.  At higher density we have used multi-component 
hypernetted chain calculations for screened, fully ionized plasmas, i.e., a 
generalization of the well-known one-component plasma model (OCP).

	The basic data files are:
                     EOS5_00z0x
                     EOS5_00z2x
                     EOS5_00z4x
                     EOS5_00z6x
                     EOS5_00z8x
                     EOS5_00z10x
                     EOS5_02z0x
                     EOS5_02z2x
                     EOS5_02z4x
                     EOS5_02z6x
                     EOS5_02z8x
                     EOS5_04z0x
                     EOS5_04z2x
                     EOS5_04z4x
                     EOS5_04z6x
                     EOS5_04z8x
Where, **z indicates the value of Z, the heavy element mass fraction and 
*x indicates X, the H mass fraction.  For pure H-He mixtures Z is by 
definition zero.  For example EOS5_04z2x, is the data file for Z=0.04 and 
X=0.2.  The following rudimentary interpolation routines are also 
provided:
                     ZFS_interp_EOS5.f
                     EOS5_xtrin.f
                     EOS5_xtrin_H_He.f.

The routine ZFS_interp_EOS5.f  interpolates the entire data set for a given 
value of Z, creating the file  EOS5_data.  This file can then be interpolated 
in X, T6 (temperature in units of 10e+6K), and Rho by the routine 
EOS5_xtrin.f.   The routine EOS5_xtrin_H_He.f interpolates the file 
EOS5_data_H_He (Z=0.0 data file available from the web site).  
Alternatively, it is possible to interpolate the Z=0.0 data using the routine 
EOS5_xtrin.f, but in that case interpolation is limited to the same 
parameter range as spanned by the Z=0.02 and Z=0.04 tables.

	Quadratic interpolation in X, T6, and Rho is performed and the 
results returned via the array eos(i).  These results have been smoothed by 
mixing overlapping quadratics. The  returned quantities are :

              eos(1) is the pressure in Mbar (10E+12dyne/cm^2)
              eos(2) is energy in 10E+12 ergs/gm. Reference zero  at zero T6
              eos(3) is the entropy in units of energy/T6
              eos(4) is dE/dRho at constant T6
              eos(5) is the specific heat, dE/dT6 at constant V.
              eos(6) is dlogP/dlogRho at constant T6. 
                     Cox and Guil1 eq 9.82
              eos(7) is dlogP/dlogT6 at constant Rho.
                     Cox and Guil1 eq 9.81
              eos(8) is gamma1. Eqs. 9.88 Cox and Guili.
              eos(9) is gamma2/(gamma2-1). Eqs. 9.88 Cox and Guili.
where,
T6=temperature in millions of degrees Kelvin
Rho=density(g/cm^3)
See subroutine esac in EOS5_xtrin_H-He.f for more details.
The temperature is tabulated in the range 0.002 to 100.0 and the density in 
the range 10E-14 to 10E+7 grams/cc.  (Note: much of the region around 
Rho=10E-14 is radiation dominated and is included mainly for 
convenience of tabulation.)  The lower temperature limit of the tables 
gradually increases for densities >0.00237 gm/cc.

	The EOS5_**z*x files also include the mean molecular weight, the
electron number-density and the derivative of the energy with respect to
Rho (dE/dRho), none of which were included in the EOS_2001 tables.   
For the lowest few temperatures, in order to obtain solutions to the activity 
equations, it was necessary to introduce an artificial electron abundance 
(chosen to be 0.0001 by number fraction).  These temperature points can 
be identified by noting were the electron density suddenly increases with 
decreasing temperature.  This affects the pressure and energy by about 
0.01%, but has little affect on the derivatives. The quantity gamma3-1 is 
no longer tabulated.  It can be obtained from the other tabulated values if 
needed.

        The computer time required to calculate the actual stellar 
mixture for elements up to Ni would be substantial, so a truncated mixture 
was used.  In the truncated mixture the mass contribution of all elements 
above neon where added in with the neon.  Contrary to the situation with 
opacity, these high Z elements do not contribute substantially

	The fractional elemental number components of Z for the reduced 
mixture are the same as used in previous work:
(Grevesse, N. 1991, A&A 242,488):

		XC= 0.2471362
		XN= 0.0620778
 		XO= 0.528368 
		XNe=0.1624178

The corresponding number fractions, including hydrogen and helium, are 
listed at the front of each of the EOS5**z*x files.  More recent estimates 
of steller element abundances change these values slightly, but should 
have a small affect on the EOS.  In the current context, this is 
accommodated by choosing a different value of Z.

-----------------------------------------------------------------------
A report on this work is being prepared for publication.  Some references 
to earlier work are:

Rogers FJ, Nayfonov A, ApJ 2002, 576,1064
Rogers, F.J., Contrib. to Plasma Physics, 2001, V41 (N2-3): 179-182       
Rogers, F.J., Physics of Plasmas,  2000, V7 (N1): 51-58.
Rogers, F.J., Swenson, F.J. and Iglesias, C. A. 1996,ApJ, 456, 902
Rogers, F.J. 1994, in "The Equation of State in Astrophysics", IAU
	Colloquium 147, eds.. G. Chabrier and E. Schatzman (Cambridge 
        University Press), p16

--------------------------------------------------------------------
