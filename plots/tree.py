# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.widgets import Slider

def draw_tree(ax, x, y, angle, length, depth, branch_angle, num_branches):
  if depth == 0 or length < 1:
    return

  # Calculate end point of current branch
  x_end = x + length * np.cos(np.radians(angle))
  y_end = y + length * np.sin(np.radians(angle))

  # Draw the branch
  ax.plot([x, x_end], [y, y_end], color='#2E7D32', lw=depth * 0.5)

  if num_branches > 1:
    # Spread branches evenly across the total angle
    start_angle = angle - branch_angle
    step = (2 * branch_angle) / (num_branches - 1)

    for i in range(num_branches):
      new_angle = start_angle + (i * step)
      draw_tree(ax, x_end, y_end, new_angle, length * 0.7, depth - 1, \
        branch_angle, num_branches)
  else:
    # Just grow straight if only 1 branch
    draw_tree(ax, x_end, y_end, angle, length * 0.7, depth - 1, branch_angle, \
      num_branches)

# Setup UI
fig, ax = plt.subplots(figsize=(8, 8))
plt.subplots_adjust(bottom=0.35)

# Slider Axes
ax_len = plt.axes([0.25, 0.20, 0.5, 0.03])
ax_ang = plt.axes([0.25, 0.15, 0.5, 0.03])
ax_split = plt.axes([0.25, 0.10, 0.5, 0.03])
ax_dep = plt.axes([0.25, 0.05, 0.5, 0.03])

# Sliders
s_len = Slider(ax_len, 'Trunk Length', 10, 100, valinit=50)
s_ang = Slider(ax_ang, 'Spread Angle', 10, 90, valinit=30)
s_split = Slider(ax_split, 'Branch Count', 2, 5, valinit=2, valstep=1)
s_dep = Slider(ax_dep, 'Bifurcations', 1, 8, valinit=5, valstep=1)

def update(val):
  ax.clear()
  ax.axis('off')
  draw_tree(ax, 0, 0, 90, s_len.val, int(s_dep.val), s_ang.val, \
    int(s_split.val))
  fig.canvas.draw_idle()

s_len.on_changed(update)
s_ang.on_changed(update)
s_split.on_changed(update)
s_dep.on_changed(update)

update(None)
plt.show()
# ============================================================================ #
