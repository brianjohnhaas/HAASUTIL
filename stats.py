#!/usr/bin/env python3

import sys
import statistics

def main():
    # Read numbers from stdin
    numbers = []
    for line in sys.stdin:
        line = line.strip()
        if line:
            try:
                numbers.append(float(line))
            except ValueError:
                print(f"Warning: Skipping invalid number: {line}", file=sys.stderr)

    if not numbers:
        print("Error: No valid numbers provided", file=sys.stderr)
        sys.exit(1)

    # Sort numbers for quartile calculation
    numbers.sort()

    # Calculate statistics
    min_val = min(numbers)
    max_val = max(numbers)
    mean_val = statistics.mean(numbers)
    median_val = statistics.median(numbers)

    # Calculate quartiles
    q1 = statistics.quantiles(numbers, n=4)[0]  # 1st quartile (25th percentile)
    q3 = statistics.quantiles(numbers, n=4)[2]  # 3rd quartile (75th percentile)

    # Print results in column format
    print(f"{'Statistic':<15} {'Value':>15}")
    print(f"{'-'*15} {'-'*15}")
    print(f"{'Min':<15} {min_val:>15.4f}")
    print(f"{'Q1 (25%)':<15} {q1:>15.4f}")
    print(f"{'Median':<15} {median_val:>15.4f}")
    print(f"{'Mean':<15} {mean_val:>15.4f}")
    print(f"{'Q3 (75%)':<15} {q3:>15.4f}")
    print(f"{'Max':<15} {max_val:>15.4f}")
    print(f"{'Count':<15} {len(numbers):>15}")

if __name__ == "__main__":
    main()
