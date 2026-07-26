from __future__ import annotations

import csv
import math
from pathlib import Path


OUT = Path(__file__).with_name("pendulum.csv")


def small_angle_theta(theta0: float, omega: float, t: float) -> float:
    return theta0 * math.cos(omega * t)


with OUT.open("w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    writer.writerow(["t", "theta"])
    for i in range(241):
        t = i / 40
        writer.writerow([f"{t:.4f}", f"{small_angle_theta(0.55, 1.8, t):.6f}"])

print(f"Wrote {OUT}")
