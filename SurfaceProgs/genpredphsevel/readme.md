Usage of genpredphsevel: 
------------------------
1. This will take the crustal (/mantle) model and generate predicted phase velocities at
the same points as the crustal model on the regular lat/lon grid.  
* Program is **phsevel2.f** 
* Input file is **phsevel2.input**  
* Example crustal model is **3Dcrust...**  
* __lowmantle3.d__ provides the structure for the rest of the mantle down to the core (needs to be altered if change depth extend covered in 3Dcrust...).  
* __perstart2.d__ specifies the periods and the range in which to search for the phase velocities and needs to be altered if you change the periods used.  

2. There is a makefile used for compiling __phsevel2.f__, linking to all the subroutines required for _Saito programs_ for calculating dispersion.
