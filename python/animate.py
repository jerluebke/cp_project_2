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

PARTICLE_NUMBERS = 20


# set up propagator
#  init_particles = np.array([
#      [1., 1., 2., 0., 1., 0., 1., 1.],
#      [2., 1., 2., 0., 0., 2., 1., 1.]
#  ], dtype=np.float64)
#  init_box = np.array([0, 0, 0], dtype=np.int32)
init_particles = np.empty((PARTICLE_NUMBERS, 8), dtype=np.float64)
init_particles[:,6:] = 1
init_particles[:,:3] = np.random.normal(8, 3, (PARTICLE_NUMBERS, 3))
init_particles[:,3:6] = np.random.normal(6, 3, (PARTICLE_NUMBERS, 3))
init_box = np.array([1, 1, 1], dtype=np.int32)
pg = propagator.PyPropagator(init_particles, init_box)


# plotting constants
rectkwds = dict(width=N, height=N, alpha=0.5, color="red", zorder=1)
xlim = (0, N*M)
ylim = (0, N*M)
zlim = (0, N*M)

# set up plotting
fig = plt.figure()
axy = fig.add_subplot(221, title="$x-y$", xlabel="$x$", ylabel="$y$",
                      xlim=xlim, ylim=ylim)
axz = fig.add_subplot(222, title="$x-z$", xlabel="$x$", ylabel="$z$",
                      xlim=xlim, ylim=zlim)
ayz = fig.add_subplot(223, title="$y-z$", xlabel="$y$", ylabel="$z$",
                      xlim=ylim, ylim=zlim)
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

    # find duplicate boxes
    box_list = [tuple(elem) for elem in b]
    dboxes = set([elem for elem in box_list if box_list.count(elem) > 1])
    if dboxes:
        print(f, dboxes)

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
FFWriter = animation.FFMpegWriter(fps=30)
animation.FuncAnimation(fig, update, frames=300, interval=100,
                        blit=True, repeat=False).save(
                            input("enter name: ") + ".mp4",
                            writer=FFWriter, dpi=300)

