from __future__ import annotations

import python_application_template.main as app


def test_main_returns_zero():
    """Directly test the main() function."""
    assert app.main() == 0
