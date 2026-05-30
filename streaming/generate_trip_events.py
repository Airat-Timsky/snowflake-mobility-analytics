"""Generate simulated NYC taxi trip completion events in JSONL format."""

from __future__ import annotations

import argparse
import json
import random
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


# Selected taxi zone IDs used for demonstration.
# We will enrich them with the Snowflake taxi zone lookup table later.
ZONE_IDS = [132, 161, 162, 163, 164, 186, 230, 236, 237, 239]

PAYMENT_TYPES = [1, 1, 1, 1, 2]  # Mostly card payments, some cash.


def build_event() -> dict[str, Any]:
    """Create one simulated completed-trip event."""
    pickup_location_id = random.choice(ZONE_IDS)
    dropoff_location_id = random.choice(
        [zone_id for zone_id in ZONE_IDS if zone_id != pickup_location_id]
    )

    trip_distance = round(random.uniform(0.8, 22.0), 2)
    fare_amount = round(3.0 + trip_distance * random.uniform(2.5, 4.0), 2)
    tip_amount = round(fare_amount * random.choice([0, 0.1, 0.15, 0.2]), 2)
    extra_charges = round(random.uniform(1.0, 7.5), 2)
    total_amount = round(fare_amount + tip_amount + extra_charges, 2)

    return {
        "event_id": str(uuid.uuid4()),
        "event_type": "trip_completed",
        "event_ts": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "vendor_id": random.choice([1, 2]),
        "pickup_location_id": pickup_location_id,
        "dropoff_location_id": dropoff_location_id,
        "passenger_count": random.randint(1, 4),
        "trip_distance": trip_distance,
        "fare_amount": fare_amount,
        "tip_amount": tip_amount,
        "total_amount": total_amount,
        "payment_type": random.choice(PAYMENT_TYPES),
    }


def generate_events(output_path: Path, count: int, interval_seconds: float) -> None:
    """Generate events and write one JSON object per line."""
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with output_path.open("w", encoding="utf-8") as output_file:
        for event_number in range(1, count + 1):
            event = build_event()
            output_file.write(json.dumps(event) + "\n")
            output_file.flush()

            print(
                f"[{event_number}/{count}] "
                f"{event['event_ts']} "
                f"trip {event['pickup_location_id']} -> "
                f"{event['dropoff_location_id']} "
                f"${event['total_amount']}"
            )

            if event_number < count and interval_seconds > 0:
                time.sleep(interval_seconds)


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Generate simulated NYC taxi trip events as JSONL."
    )
    parser.add_argument(
        "--count",
        type=int,
        default=20,
        help="Number of events to generate. Default: 20.",
    )
    parser.add_argument(
        "--interval",
        type=float,
        default=0.2,
        help="Seconds to wait between events. Default: 0.2.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("streaming/output/stream_trip_events.jsonl"),
        help="Output JSONL file path.",
    )
    return parser.parse_args()


def main() -> None:
    """Run the event generator."""
    args = parse_args()

    if args.count <= 0:
        raise ValueError("--count must be greater than zero.")

    if args.interval < 0:
        raise ValueError("--interval cannot be negative.")

    generate_events(args.output, args.count, args.interval)

    print(f"\nGenerated {args.count} events in {args.output}")


if __name__ == "__main__":
    main()