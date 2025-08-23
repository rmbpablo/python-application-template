from __future__ import annotations


def test_import_package():
    import python_application_template  # noqa: PLC0415

    assert isinstance(python_application_template.__version__, str)
