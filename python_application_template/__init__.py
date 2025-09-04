from __future__ import annotations

from importlib.metadata import PackageNotFoundError
from importlib.metadata import version

try:
    __version__ = version('python_application_template')
except PackageNotFoundError:
    __version__ = '0.0.0'
