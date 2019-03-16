#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

import propagator


plt.rcParams["text.usetex"] = True


# particle grid in box
N = 64
# box grid
M = 8

# label frequency on plot axes
LABELFACTOR = 4

# movie settings
FRAMES  = 500
FPS     = 30
DPI     = 300


#============================================================================#

#####################
# PARTICLE CONFIG   #
#####################

PARTICLE_NUMBERS = 50

# set up propagator
#  init_particles = np.array([
#      [1., 1., 2., 0., 1., 1., 1., 1.],
#      [2., 1., 2., 0., 0., 2., 1., 1.]
#  ], dtype=np.float64)
#  init_box = np.array([0, 0, 0], dtype=np.int32)

init_particles = np.empty((PARTICLE_NUMBERS, 8), dtype=np.float64)

# init_particles = [ x, y, z, vx, vy, vz, m, q ]

# m, q
init_particles[:,6:] = 1
# position
init_particles[:,:3] = np.random.normal(32, 2, (PARTICLE_NUMBERS, 3))
# x velocity
init_particles[:,3] = np.random.normal(10, 4, (PARTICLE_NUMBERS,))
# y, z velocity
init_particles[:,4:6] = np.random.normal(0, 8, (PARTICLE_NUMBERS, 2))

init_box = np.array([0, 4, 4], dtype=np.int32)
pg = propagator.PyPropagator(init_particles, init_box)

#============================================================================#


# plotting constants
rectkwds = dict(width=N, height=N, alpha=0.5, color="red", zorder=1)
xlim = (0, N*M)
ylim = (0, N*M)
zlim = (0, N*M)

# set up plotting
fig = plt.figure()
axy = fig.add_subplot(221, title="$x-y$", xlabel="$x$", ylabel="$y$")
axz = fig.add_subplot(222, title="$x-z$", xlabel="$x$", ylabel="$z$")
ayz = fig.add_subplot(223, title="$y-z$", xlabel="$y$", ylabel="$z$")

for a in (axy, axz, ayz):
    tickarr = np.arange(0, N*M+1, N)
    labellist = [i if i % (N*LABELFACTOR) == 0 else '' for i in tickarr]
    a.set(xlim=xlim, ylim=ylim,
          xticks=tickarr, yticks=tickarr,
          xticklabels=labellist, yticklabels=labellist)
    a.grid(True)

fig.tight_layout()


# plot initial data
particles = [
    axy.plot([], [], 'b.')[0],
    axz.plot([], [], 'b.')[0],
    ayz.plot([], [], 'b.')[0]
]
boxes = [
    [axy.add_patch(plt.Rectangle((init_box[0], init_box[1]), **rectkwds))],
    [axz.add_patch(plt.Rectangle((init_box[0], init_box[2]), **rectkwds))],
    [ayz.add_patch(plt.Rectangle((init_box[1], init_box[2]), **rectkwds))]
]


def update(f):
    # compute new coordinates of particles and boxes
    p, b = pg.timestep()
    # box coordinates in particle reference frame
    b *= N

    if (f+1)%100 == 0:
        print('frame: %d' % (f+1))

    # find duplicate boxes
    #  box_list = [tuple(elem) for elem in b]
    #  dboxes = set([elem for elem in box_list if box_list.count(elem) > 1])
    #  if dboxes:
    #      print(f, dboxes)

    # set particle coordinates
    particles[0].set_data(p[:,0], p[:,1])
    particles[1].set_data(p[:,0], p[:,2])
    particles[2].set_data(p[:,1], p[:,2])

    # set box coordinates
    old = len(boxes[0])
    new = len(b)
    for i in range(min(old, new)):
        boxes[0][i].set_xy((b[i, 0], b[i, 1]))
        boxes[1][i].set_xy((b[i, 0], b[i, 2]))
        boxes[2][i].set_xy((b[i, 1], b[i, 2]))

    # number of boxes increased: add them
    if old < new:
        for i in range(old, new):
            boxes[0].append(axy.add_patch(plt.Rectangle((b[i, 0], b[i, 1]),
                                                        **rectkwds)))
            boxes[1].append(axz.add_patch(plt.Rectangle((b[i, 0], b[i, 2]),
                                                        **rectkwds)))
            boxes[2].append(ayz.add_patch(plt.Rectangle((b[i, 1], b[i, 2]),
                                                        **rectkwds)))

    # number of boxes decreased: remove them
    elif new < old:
        for i in range(new, old-1):
            for j in range(3):
                boxes[j][i].remove()
                del boxes[j][i]

    # return artists to be drawn
    return [*particles, *[c for b in boxes for c in b]]


#  write animation in movie
FFWriter = animation.FFMpegWriter(fps=FPS)
animation.FuncAnimation(fig, update, frames=FRAMES, interval=100,
                        blit=True, repeat=False).save(
                            input("enter name: ") + ".mp4",
                            writer=FFWriter, dpi=DPI)

