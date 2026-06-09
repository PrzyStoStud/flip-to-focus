import os

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient as Tc
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Set up test environment variables before importing app
TEST_DB_PATH = "./test.db"
os.environ["DATABASE_URL"] = f"sqlite:///{TEST_DB_PATH}"
os.environ["API_SECRET_KEY"] = "test-secret-key"

from main import app  # noqa: E402
from routes.auth import get_db  # noqa: E402

# Setup test database
engine = create_engine(
    os.environ["DATABASE_URL"],
    connect_args={"check_same_thread": False},
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db


@pytest.fixture(scope="session", autouse=True)
def cleanup_test_db():
    # Remove the file before starting the whole suite if it's left over
    if os.path.exists(TEST_DB_PATH):
        os.remove(TEST_DB_PATH)
    yield
    # Remove the file after the whole suite finishes
    if os.path.exists(TEST_DB_PATH):
        os.remove(TEST_DB_PATH)


@pytest.fixture(autouse=True)
def apply_migrations():
    alembic_cfg = Config("alembic.ini")
    alembic_cfg.set_main_option("sqlalchemy.url", os.environ["DATABASE_URL"])
    command.upgrade(alembic_cfg, "head")

    try:
        yield
    finally:
        command.downgrade(alembic_cfg, "base")


def test_register_success():
    with Tc(app) as client:
        response = client.post(
            "/auth/register",
            json={"email": "test@example.com", "password": "password123"},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["email"] == "test@example.com"
        assert "id" in data


def test_register_duplicate_email():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "test@example.com", "password": "password123"},
        )
        response = client.post(
            "/auth/register",
            json={"email": "test@example.com", "password": "password456"},
        )
        assert response.status_code == 400
        assert response.json()["detail"] == "Email already registered"


def test_register_invalid_password():
    with Tc(app) as client:
        # Short password
        response = client.post(
            "/auth/register",
            json={"email": "test@example.com", "password": "short"},
        )
        assert response.status_code == 422


def test_login_success():
    with Tc(app) as client:
        # Register first
        client.post(
            "/auth/register",
            json={"email": "login@example.com", "password": "password123"},
        )

        # Login
        response = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "login@example.com",
                "password": "password123",
            },
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "Bearer"


def test_login_invalid_credentials():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "login@example.com", "password": "password123"},
        )

        response = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "login@example.com",
                "password": "wrongpassword",
            },
        )
        assert response.status_code == 401


def test_me_endpoint():
    with Tc(app) as client:
        # Register and login
        client.post(
            "/auth/register",
            json={"email": "me@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "me@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        response = client.get(
            "/auth/me",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        assert response.json()["email"] == "me@example.com"


def test_logout():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "logout@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "logout@example.com",
                "password": "password123",
            },
        )
        refresh_token = login_res.json()["refresh_token"]

        response = client.post(
            "/auth/logout",
            data={"refresh_token": refresh_token},
        )
        assert response.status_code == 200
        assert response.json()["message"] == "logged out"


def test_remove_user():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "remove@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "remove@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        response = client.post(
            "/auth/remove",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        assert response.json()["message"] == "removed"

        # Try to login again
        response = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "remove@example.com",
                "password": "password123",
            },
        )
        assert response.status_code == 401


# Sessions tests
def test_create_session():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "session@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "session@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        response = client.post(
            "/sessions",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["user_id"] is not None


def test_list_sessions():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "list@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "list@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        # Create two sessions
        client.post("/sessions", headers={"Authorization": f"Bearer {token}"})
        client.post("/sessions", headers={"Authorization": f"Bearer {token}"})

        response = client.get(
            "/sessions/list",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        assert len(response.json()) == 2


def test_get_session_by_id():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "get@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "get@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        create_res = client.post(
            "/sessions", headers={"Authorization": f"Bearer {token}"}
        )
        session_id = create_res.json()["id"]

        response = client.get(
            f"/sessions/{session_id}",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        assert response.json()["id"] == session_id


def test_delete_session():
    with Tc(app) as client:
        client.post(
            "/auth/register",
            json={"email": "delete@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "delete@example.com",
                "password": "password123",
            },
        )
        token = login_res.json()["access_token"]

        create_res = client.post(
            "/sessions", headers={"Authorization": f"Bearer {token}"}
        )
        session_id = create_res.json()["id"]

        response = client.delete(
            f"/sessions/{session_id}",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 200
        assert response.json()["deleted"] == session_id

        # Verify it's gone
        response = client.get(
            f"/sessions/{session_id}",
            headers={"Authorization": f"Bearer {token}"},
        )
        assert response.status_code == 404


def test_refresh_token_success():
    with Tc(app) as client:
        # Register and login
        client.post(
            "/auth/register",
            json={"email": "refresh@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "refresh@example.com",
                "password": "password123",
            },
        )
        refresh_token = login_res.json()["refresh_token"]

        # Refresh the token
        refresh_res = client.post(
            "/auth/token",
            data={"grant_type": "refresh_token", "refresh_token": refresh_token},
        )
        assert refresh_res.status_code == 200
        new_data = refresh_res.json()
        assert "access_token" in new_data
        assert "refresh_token" in new_data
        assert new_data["refresh_token"] != refresh_token


def test_refresh_token_revoked():
    with Tc(app) as client:
        # Register and login
        client.post(
            "/auth/register",
            json={"email": "refresh@example.com", "password": "password123"},
        )
        login_res = client.post(
            "/auth/token",
            data={
                "grant_type": "password",
                "username": "refresh@example.com",
                "password": "password123",
            },
        )
        refresh_token = login_res.json()["refresh_token"]

        # Logout (which revokes the token)
        client.post("/auth/logout", data={"refresh_token": refresh_token})

        # Try to refresh the token
        refresh_res = client.post(
            "/auth/token",
            data={"grant_type": "refresh_token", "refresh_token": refresh_token},
        )
        assert refresh_res.status_code == 401


def test_info_endpoint():
    with Tc(app) as client:
        response = client.get("/info")
        assert response.status_code == 200
        data = response.json()
        assert "server_version" in data
        assert "api_version" in data
