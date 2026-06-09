FROM python:3.11-slim

WORKDIR /app

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

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
