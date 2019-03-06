#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

import propagator


# number of particle grid points per box
N = 16


# set up propagator
init_particles = np.array([
    [1., 1., 2., 0., 1., 0., 1., 1.],
    [2., 1., 2., 0., 0., 2., 1., 1.]
], dtype=np.float64)
init_box = np.array([0, 0, 0], dtype=np.int32)
pg = propagator.PyPropagator(init_particles, init_box)


# plotting constants
rectkwds = dict(width=16, height=16, alpha=0.5, color="red", zorder=1)
xlim = (0, 512)
ylim = (0, 512)
zlim = (0, 512)

# set up plotting
fig = plt.figure()
axy = fig.add_subplot(221, title="x-y", xlabel="x", ylabel="y",
                      xlim=xlim, ylim=ylim)
axz = fig.add_subplot(222, title="x-z", xlabel="x", ylabel="z",
                      xlim=xlim, ylim=zlim)
ayz = fig.add_subplot(223, title="y-z", xlabel="y", ylabel="z",
                      xlim=ylim, ylim=zlim)
fig.tight_layout()


# plot initial data
particles = [
    axy.plot([init_particles[:,0]], [init_particles[:,1]], 'b.')[0],
    axz.plot([init_particles[:,0]], [init_particles[:,2]], 'b.')[0],
    ayz.plot([init_particles[:,1]], [init_particles[:,2]], 'b.')[0]
]
boxes = [
    [axy.add_patch(plt.Rectangle((init_box[0], init_box[1]), **rectkwds))],
    [axz.add_patch(plt.Rectangle((init_box[0], init_box[2]), **rectkwds))],
    [ayz.add_patch(plt.Rectangle((init_box[1], init_box[2]), **rectkwds))]
]


def update(i):
    # compute new coordinates of particles and boxes
    p, b = pg.timestep()
    # box coordinates in particle reference frame
    b *= N

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
        for i in range(new, old):
            for j in range(3):
                boxes[j][i].remove()
                del boxes[j][i]

    # return artists to be drawn
    return [*particles, *[c for b in boxes for c in b]]


#  write animation in movie
FFWriter = animation.FFMpegWriter(fps=10)
animation.FuncAnimation(fig, update, frames=500, interval=100,
                        blit=True, repeat=False).save(
                            input("enter name: ") + ".mp4",
                            writer=FFWriter, dpi=100)

