FROM python:3.11-slim

ARG SERVER_VERSION
ENV SERVER_VERSION=$SERVER_VERSION

WORKDIR /app

ENV PYTHONUNBUFFERED=1

# Install system dependencies (gcc might still be needed for some packages like bcrypt)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create data directory for SQLite
RUN mkdir -p /app/data

# Copy the rest of the application
COPY . .
RUN rm -rf .venv .ruff_cache .pytest_cache .mypy_cache

# Expose the port the app runs on
EXPOSE 8000

# Make start script executable
RUN chmod +x /app/start.sh

# Command to run the application
CMD ["/app/start.sh"]
