import sys
import importlib.metadata

import tensorflow as tf

python_version = sys.version.split(" ")[0]
basenji_version = importlib.metadata.version("basenji")

print(f"Hello from Python {python_version}")
print(f"  Using {tf.__name__} ({tf.__version__}) and basenji ({basenji_version})")
