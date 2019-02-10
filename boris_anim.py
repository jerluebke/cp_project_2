# -*- coding: utf-8 -*-

import os
import numpy as np
import matplotlib.pyplot as plt
import mpl_toolkits.mplot3d.axes3d as p3
import matplotlib.animation as animation
os.environ['PATH'] += os.pathsep + os.path.realpath('.\\boris\\.libs')
import boris

plt.rcParams['animation.ffmpeg_path'] = 'D:\\source\\Libs\\ffmpeg-20180521-c24d247-win64-static\\bin\\ffmpeg.exe'

boris_step = boris.boris_module.boris_step

def E(r, t):
    return np.array([0., 0., 0.])

def B(r, t):
    d = np.sqrt(r[0]**2 + r[1]**2)
    b0 = 1/d
    return np.array([-b0*r[1]/d, b0*r[0]/d, 0.5])


r = np.array([1., 0., 0.])
v = np.array([0., 1., 0.])
q = m = 1
dt = 0.1
t = 0
tmax = 100
frames = 1000
data = np.zeros((frames, 3))
data[0] = r

fig = plt.figure()
a3 = fig.add_subplot(111, projection='3d')
traj, = a3.plot([r[0]], [r[1]], [r[2]], 'b-')
part, = a3.plot([r[0]], [r[1]], [r[2]], 'ro')

#  a3.set_xlim3d(0, 5)
#  a3.set_ylim3d(0, 5)
#  a3.set_zlim3d(0, 5)

def update(f):
    global t
    t += 0.5 * dt
    data[f] = boris_step(r, v, E, B, q, m, dt, t)
    t += 0.5 * dt
    traj.set_data(data[:f,0], data[:f,1])
    traj.set_3d_properties(data[:f,2])
    part.set_data(data[f,0], data[f,1])
    part.set_3d_properties(data[f,2])
    xmin = data[:f,0].min(); xmax = data[:f,0].max()
    ymin = data[:f,1].min(); ymax = data[:f,1].max()
    zmin = data[:f,2].min(); zmax = data[:f,2].max()
    a3.set_xlim3d(xmin-.1, xmax+.1)
    a3.set_ylim3d(ymin-.1, ymax+.1)
    a3.set_zlim3d(zmin-.1, zmax+.1)
    return traj, part

if __name__ == '__main__':
    FFMpegWriter = animation.FFMpegWriter(fps=30)
    anim = animation.FuncAnimation(fig, update, range(1, frames), blit=True,
                                   repeat=False).save(
                                       'boris.mp4', writer=FFMpegWriter,
                                        dpi=100)
