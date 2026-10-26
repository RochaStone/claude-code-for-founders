"""Finds and loads the shared style.json (see STYLE.md at the repo root).

Lookup order: $ROCHA_CODED_STYLE, ./style.json (or <cwd>/style.json), ~/.rocha-coded/style.json,
then the bundled example. Missing or blank keys fall back to the bundled example, key by key.
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
BUNDLED = [os.path.join(HERE, "style.rocha-coded.json"),
           os.path.join(HERE, "..", "examples", "style.rocha-coded.json")]
HEX = re.compile(r"^#[0-9A-Fa-f]{6}$")


def find_style(cwd=None):
    candidates = [os.environ.get("ROCHA_CODED_STYLE", ""),
                  os.path.join(cwd or os.getcwd(), "style.json"),
                  os.path.expanduser("~/.rocha-coded/style.json")] + BUNDLED
    for path in candidates:
        if path and os.path.isfile(path):
            return os.path.abspath(path)
    return ""


def _read(path):
    try:
        with open(path, encoding="utf-8") as fh:
            data = json.load(fh)
        return data if isinstance(data, dict) else {}
    except (OSError, json.JSONDecodeError):
        return {}


def _merge(base, over):
    out = dict(base)
    for key, val in over.items():
        if isinstance(val, dict) and isinstance(base.get(key), dict):
            out[key] = _merge(base[key], val)
        elif val not in ("", None, [], {}):
            out[key] = val
    return out


def load_style(path=None, cwd=None):
    """Returns (style dict, path used). Bad hex colours fall back to the bundled ones."""
    base = {}
    for b in BUNDLED:
        if os.path.isfile(b):
            base = _read(b)
            break
    path = path or find_style(cwd)
    style = _merge(base, _read(path)) if path else base
    palette = style.get("palette", {})
    for key, val in list(palette.items()):
        if not (isinstance(val, str) and HEX.match(val)):
            palette[key] = base.get("palette", {}).get(key, "#111111")
    return style, path


def slug(name):
    s = re.sub(r"[^a-z0-9]+", "-", str(name).lower()).strip("-")
    return s or "my-style"
