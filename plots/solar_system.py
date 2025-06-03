import matplotlib.pyplot as plt
import numpy as np

# Constants (simplified)
AU = 1.496e+11  # meters (1 AU)
mars_orbit_radius = 1.524 * AU  # Mars average distance from the sun
earth_orbit_radius = AU
sun_position = (0, 0)

# Straight-line path
straight_line_x = np.linspace(earth_orbit_radius, mars_orbit_radius, 500)
straight_line_y = np.zeros_like(straight_line_x)

# Hohmann transfer arc (half ellipse)
theta = np.linspace(0, np.pi, 500)
semi_major_axis = (earth_orbit_radius + mars_orbit_radius) / 2
eccentricity = (mars_orbit_radius - earth_orbit_radius) / (mars_orbit_radius + earth_orbit_radius)
a = semi_major_axis
b = np.sqrt(a**2 * (1 - eccentricity**2))
hohmann_x = a * np.cos(theta) - (a - earth_orbit_radius)
hohmann_y = b * np.sin(theta)

# Plotting
plt.figure(figsize=(8, 8))
# Orbits
earth_orbit = plt.Circle(sun_position, earth_orbit_radius, color='blue', fill=False, linestyle='--', label='Earth Orbit')
mars_orbit = plt.Circle(sun_position, mars_orbit_radius, color='red', fill=False, linestyle='--', label='Mars Orbit')
plt.gca().add_patch(earth_orbit)
plt.gca().add_patch(mars_orbit)

# Trajectories
plt.plot(straight_line_x, straight_line_y, 'k-', label='Straight Line Path (Theoretical)')
plt.plot(hohmann_x, hohmann_y, 'g-', label='Hohmann Transfer Orbit')

# Sun, Earth, Mars
plt.plot(0, 0, 'yo', label='Sun')
plt.plot(earth_orbit_radius, 0, 'bo', label='Earth (at launch)')
plt.plot(mars_orbit_radius, 0, 'ro', label='Mars (at arrival)')

plt.axis('equal')
plt.xlabel('Distance (m)')
plt.ylabel('Distance (m)')
plt.title('Straight Line vs Hohmann Transfer to Mars')
plt.legend()
plt.grid(True)
plt.show()
