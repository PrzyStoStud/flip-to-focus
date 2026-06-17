# Flip to Focus - Server

This is the backend service for the Flip to Focus mobile application, built with FastAPI.

## Documentation

*   **API Documentation (OpenAPI):**
    *   Live Server: `https://flip-to-focus.tau2c.top/docs` or `https://flip-to-focus.tau2c.top/redoc`
    *   Local JSON Schema: [openapi.json](./docs/openapi.json)
*   **Privacy Policy:** [Privacy Policy](./docs/privacy_policy.md)

## Development Setup

1.  **Environment:** Ensure you have Python 3.10+ installed.
2.  **Dependencies:** `pip install -r requirements.txt`
3.  **Database:** Set up a database and configure `DATABASE_URL` in your environment (e.g., in a `.env` file).
4.  **Start Server:** Run `./start.sh`. This will automatically run database migrations and start the server with auto-reload. You may need to run `chmod +x start.sh` first to make it executable.
    *   *Note for development:* To enable verbose logging, set the environment variable `ENVIRONMENT=development` before starting the server. By default, the app runs in "production" mode which disables verbose request logging.
