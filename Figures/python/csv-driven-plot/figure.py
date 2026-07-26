from __future__ import annotations

import csv
import math
from pathlib import Path


OUT = Path(__file__).with_name("data.csv")

with OUT.open("w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["x", "sinx", "cosx"])
    for i in range(361):
        x = -math.pi + (2 * math.pi * i / 360)
        writer.writerow([f"{x:.6f}", f"{math.sin(x):.6f}", f"{math.cos(x):.6f}"])

print(f"Wrote {OUT}")
