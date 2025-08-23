# ==========================
# ---------- BUILDER --------
# ==========================
FROM python:3.13.7-slim AS builder

WORKDIR /tmp/_build/

# Copy source and requirements
COPY ./src/ ./src/
COPY ./requirements/ ./requirements/
COPY pyproject.toml pyproject.toml ./

# Install uv from official repo and build wheel
RUN \
    # Setup uv
    pip install --no-cache-dir uv==0.8.11 \
    # Build the python package (TODO: Move to a proper pypi index) and create a virtual environment for it
    && uv pip install --system --no-cache build==1.3.0 && python -m build --wheel \
    && uv venv /opt/venv \
    && uv pip install --no-cache --python /opt/venv/bin/python ./dist/*.whl

# ==========================
# ---------- PRODUCTION -----
# ==========================
FROM python:3.13.7-slim AS production

WORKDIR /app

# Copy the python virtual environment within all dependencies
COPY --from=builder /opt/venv /opt/venv

# Add the venv into the PATH
ENV PATH="/opt/venv/bin:$PATH"

# Use an unprivileged user (without shell access and home directory)
RUN addgroup --gid 1001 --system app && \
    adduser --no-create-home --shell /bin/false --disabled-password --uid 1001 --system --group app && \
    apt-get update && apt-get install -y --no-install-recommends \
        libglib2.0-0t64=2.84.3-1 \
        libgl1=1.7.0-1+b2\
        libglx-mesa0=25.0.7-2\
        libsm6=2:1.2.6-1 \
        libxrender1=1:0.9.12-1 \
        libxext6=2:1.3.4-1+b3 \
    && rm -rf /var/lib/apt/lists/*

USER app

# call lib entrypoint
ENTRYPOINT ["python_application_template"]


# ==========================
# ---------- DEVELOPMENT ----
# ==========================
FROM production AS dev

WORKDIR /app

# For dev, optionally run as root for bind-mounts/debug
USER root

# Install extra dependencies for development (pytest, coverage, etc.)
COPY ./requirements/ ./requirements/
#
# RUN apt-get update && apt-get install -y --no-install-recommends \
#         git

RUN pip install --no-cache-dir uv==0.8.11 \
    && uv pip install --no-cache --python /opt/venv/bin/python -r requirements/requirements-dev.txt

USER app

CMD ["bash"]
