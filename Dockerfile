# Stage 1: Build Stage
FROM python:3.12.3-alpine AS build

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk update && apk add --no-cache \
    build-base \
    python3-dev \
    libffi-dev \
    openssl-dev \
    git \
    curl

# Copy requirements file
COPY requirements.txt requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -U "steamio @ git+https://github.com/Gobot1234/steam.py@main" && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir git+https://github.com/Rapptz/asqlite

# Stage 2: Final Stage
FROM python:3.12.3-alpine

# Set working directory
WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache \
    libffi \
    openssl \
    curl \
    git

# Copy Python packages from the build stage
COPY --from=build /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=build /usr/local/bin /usr/local/bin

# Copy application files
COPY . .

# Set environment variable
ENV DOCKER_CONTAINER True

# Set default command
CMD ["python3", "-u", "async_main.py"]

