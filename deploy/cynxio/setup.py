#!/usr/bin/env python3
"""Create local Postiz secrets once; never replace an existing environment."""
import os
from pathlib import Path
import secrets

target = Path(__file__).resolve().parent / ".env"
if target.exists():
    print("Existing .env preserved.")
else:
    values = {
        "POSTIZ_JWT_SECRET": secrets.token_hex(64),
        "POSTIZ_DB_PASSWORD": secrets.token_hex(32),
        "TEMPORAL_DB_PASSWORD": secrets.token_hex(32),
        "DISABLE_REGISTRATION": "true",
    }
    with os.fdopen(os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), "w") as handle:
        handle.write("\n".join(f"{key}={value}" for key, value in values.items()) + "\n")
    print("Created private .env. No credentials printed.")
