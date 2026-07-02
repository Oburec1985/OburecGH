import os
import _winapi

path = r"D:\works\OburecGH\sharedUtils\math\FFT_components"
target = r"D:\works\OburecGH\sharedUtils\math\FFT_койнов"

if os.path.exists(path) or os.path.islink(path):
    try:
        os.rmdir(path)
    except:
        try:
            os.unlink(path)
        except:
            pass

_winapi.CreateJunction(target, path)
print("Junction created successfully!")
