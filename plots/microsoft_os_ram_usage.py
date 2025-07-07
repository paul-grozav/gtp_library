import matplotlib.pyplot as plt

# OS versions and RAM requirements in MiB
os_versions = [
    "MS-DOS 1.0", "MS-DOS 2.x", "MS-DOS 3.x", "MS-DOS 4.x", "MS-DOS 5.0",
    "MS-DOS 6.x", "Windows 1.0", "Windows 3.0", "Windows 3.1", "Windows 95",
    "Windows 98", "Windows ME", "Windows 2000", "Windows XP", "Windows Vista",
    "Windows 7", "Windows 8", "Windows 10", "Windows 11"
]

ram_mib = [
    0.016, 0.032, 0.064, 0.256, 0.256, 0.512, 0.256, 1, 1, 4, 16, 32, 64, 64,
    512, 1024, 1024, 1024, 4096
]

# Plotting
plt.figure(figsize=(12, 6))
plt.plot(os_versions, ram_mib, marker='o', linestyle='-', color='blue')
plt.xticks(rotation=45, ha='right')
plt.ylabel('Minimum RAM (MiB)')
plt.title('Minimum RAM Requirements for MS-DOS and Windows Versions')
plt.grid(True)
plt.tight_layout()

plt.savefig("plot.png", dpi=300)
#plt.show()