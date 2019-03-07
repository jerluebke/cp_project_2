# Tracking Particle Movement in Magnetic Fields
2nd project of the computational physics course (winter 18/19) at
Ruhr-University Bochum

## Aim
Tracking the motion of charged particles in a possibly large domain with
(turbolent) magnetic fields

## Idea
 * There exist two levels of grids (or two frames of reference): a fine
   particle grid and a coarse box grid (one box contains N*N*N particle grid
   points)
 * The boxes containing particles ("active" boxes) are stored in a
   double-linked list (std::list)
 * Each box has a 4-d array describing the magnetic field in the box
   (implemented as 1-d array with size 3*N^3; 3 spatial coordinates giving a
   3-d bfield-vector at each particle grid point)
 * Now the movements of the particles are computed in discrete time steps using
   the [boris method](https://en.wikipedia.org/wiki/Particle-in-cell#The_particle_mover)
   and the boxes magnetic field array
 * At each such time step it is checked whether the current particle left its
   box and is in that case moved to a list of temporary boxes
 * After all particles have been moved, the temp list is iterated and all
   displaced particles are moved into their new boxes
 * Empty active boxes are deleted
 * The active and temporary boxes are identified via their [morton
   keys](https://en.wikipedia.org/wiki/Z-order_curve)

## Implementation
The boris method is implemented in fortran, the propagator managing the lists
is implemented in c++ (using the STL) and visualization is done in python (with
a cython wrapper for the c++ code)

## Dependencies
 * [FFmpeg](https://ffmpeg.org/), _optional_, for saving the animation as a movie

## Usage
 * The animation (initial particle data and movie config are defined in
   [python/animate.py](https://github.com/jerluebke/cp_project_2/blob/master/python/animate.py)):
    ```
    make python
    cd python/
    python3 ./animate.py
    ```

 * To run tests:
    ```
    make ctest
    ./bin/ctest
    ```
    and
    ```
    make ftest
    ./bin/ftest
    ```

