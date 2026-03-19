"""Verification helpers for documented Stata output parity."""

from .checks import verify_documented_parity
from .reference import EXHIBITS, KNOWN_ALIAS_ANOMALIES, validate_reference_manifest

__all__ = [
    "EXHIBITS",
    "KNOWN_ALIAS_ANOMALIES",
    "validate_reference_manifest",
    "verify_documented_parity",
]
