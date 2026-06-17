# FlipToFocus 

![Flutter CI](https://github.com/PrzyStoStud/flip-to-focus/actions/workflows/flutter_ci.yaml/badge.svg)
![Server CI](https://github.com/PrzyStoStud/flip-to-focus/actions/workflows/server_ci.yaml/badge.svg)

**FlipToFocus** is an innovative mobile productivity application designed to help you eliminate digital distractions. Instead of fighting for your attention, the app rewards you for physically putting your phone face down and focusing on your tasks. It is built as a complete end-to-end system with a mobile frontend and a containerized backend API.

##  Key Features

* **Physical Focus Trigger:** Utilizes the device's Z-axis accelerometer to detect when the phone is placed face down, automatically starting the session.
* **Focus Modes:** Choose between 3 dedicated Pomodoro session lengths: **15, 25, or 60 minutes**.
* **Gamification & Progress Tracking:** Earn points for successfully completing uninterrupted sessions. Lifting the phone before the timer ends cancels the session and forfeits the points.
* **Authentication System:** Secure user registration and login flow using JWT access tokens.
* **Offline-First Capabilities:** Once logged in, the app works entirely offline. Focus sessions and earned points are saved locally on the device via offline storage and can be synchronized with the server later.

##  Tech Stack

### Frontend (Mobile App)
* **Framework:** Flutter (Dart)
* **Features:** Native sensor integration (accelerometer), local storage, state management.

### Backend (REST API)
* **Language & Framework:** Python, FastAPI
* **Database & ORM:** SQLite, SQLAlchemy
* **Testing:** Pytest (Unit and Integration tests)
* **Infrastructure:** Docker & Docker Compose

##  Quality Assurance & CI/CD

The project strictly follows IT industry standards using GitHub Actions. Every Pull Request must pass rigorous automated quality gates before being merged:

**Backend Pipeline:**
* `mypy .` - Static type checking.
* `ruff check .` - Fast Python linting and code quality analysis.
* `black --check .` - Strict code formatting enforcement.
* `pytest -q -vv` - Automated unit and integration testing.

**Frontend Pipeline:**
* `dart format --set-exit-if-changed` - Dart code formatting validation.
* `flutter analyze` - Static analysis for Dart/Flutter best practices.
* `flutter test` - Automated frontend unit testing.
* **Auto-Build:** Automatically generates a release APK (`app-release.apk`) on successful main branch pushes.

##  Getting Started (Local Development)

### Running the Backend (Docker)
1. Navigate to the server directory:
   ```bash
   cd server
   ```
2. Build and start the containerized FastAPI server:
  ```bash
  docker compose up --build
  ```
  The API will be available at http://localhost:8000 and the Swagger UI at http://localhost:8000/docs.
### Running the Frontend (Flutter)
1. Navigate to the mobile app directory:
  ```bash
  cd flip_to_focus
  ```
2. Fetch dependencies:
  ```bash
  flutter pub get
  ```
3. Run the application on a connected Android device or emulator:
  ```bash
  flutter run
  ```
   
