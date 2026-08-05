# -*- coding: utf-8 -*-
from PIL import Image
import os

img_path = r"C:\Users\User12345\.gemini\antigravity\brain\6671eb74-1f58-4897-bc28-5b10d4f7c8ac\startup_state_fresh.png"

if not os.path.exists(img_path):
    print(f"Error: Image {img_path} not found")
    exit(1)

img = Image.open(img_path)
width, height = img.size
print(f"Image size: {width}x{height}")

# Let's count pixels that are strongly red.
# Red line color: R is high (say > 200), G is low (< 50), B is low (< 50).
red_pixel_count = 0
for y in range(height):
    for x in range(width):
        r, g, b = img.getpixel((x, y))[:3]
        if r > 200 and g < 50 and b < 50:
            red_pixel_count += 1

print(f"Found {red_pixel_count} strongly red pixels in the image.")
if red_pixel_count > 100:
    print("Success: Red line is visible!")
else:
    print("Failure: Red line is NOT visible!")
