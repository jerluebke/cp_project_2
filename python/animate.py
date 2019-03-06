#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation

import propagator


init_particles = np.array([
    [1., 1., 2., 0., 1., 0., 1., 1.]
], dtype=np.float64)

init_box = np.array([0, 0, 0], dtype=np.int32)

pg = propagator.PyPropagator(init_particles, init_box)


rectkwds = dict(width=16, height=16, alpha=0.5, color="red", zorder=1)

fig, (axy, axz, ayz) = plt.subplots(3, 1)
axy.set(title="x-y", xlabel="x", ylabel="y")
axz.set(title="x-z", xlabel="x", ylabel="z")
ayz.set(title="y-z", xlabel="y", ylabel="z")

axy.set(xlim=(0, 640), ylim=(0, 208))
axz.set(xlim=(0, 640), ylim=(0, 4))
ayz.set(xlim=(0, 208), ylim=(0, 4))

particles = [
    axy.plot([init_particles[0,0]], [init_particles[0,1]], 'bo')[0],
    axz.plot([init_particles[0,0]], [init_particles[0,2]], 'bo')[0],
    ayz.plot([init_particles[0,1]], [init_particles[0,2]], 'bo')[0]
]

boxes = [
    [axy.add_patch(plt.Rectangle((init_box[0], init_box[1]), **rectkwds))],
    [axz.add_patch(plt.Rectangle((init_box[0], init_box[2]), **rectkwds))],
    [ayz.add_patch(plt.Rectangle((init_box[1], init_box[2]), **rectkwds))]
]


fig.tight_layout()


def update(i):
    p, b = pg.timestep()
    b *= 16
    particles[0].set_data(p[0,0], p[0,1])
    particles[1].set_data(p[0,0], p[0,2])
    particles[2].set_data(p[0,1], p[0,2])
    boxes[0][0].set_xy((b[0,0], b[0,1]))
    boxes[1][0].set_xy((b[0,0], b[0,2]))
    boxes[2][0].set_xy((b[0,1], b[0,2]))
    return [*particles, *[c for b in boxes for c in b]]


FFWriter = animation.FFMpegWriter(fps=10)
animation.FuncAnimation(fig, update, frames=706, interval=100,
                        blit=True, repeat=False).save(
                            input("enter name: ") + ".mp4",
                            writer=FFWriter, dpi=100)
