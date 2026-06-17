# Prototype and MVP Scope

## 1. Mobile-First Justification
FlipToFocus **cannot be a desktop application**. The core mechanics rely entirely on the smartphone's spatial orientation (Z-axis accelerometer) and the physical action of putting the device away. 

## 2. MVP Features (Current Scope)
* **Native Sensors:** Accelerometer integration to detect the face-down state.
* **Offline-First:** Local storage saving session points when the network is unavailable.
* **Core Loop:** 15, 25, and 60-minute Pomodoro timers.
* **Backend Integration:** REST API (FastAPI) for secure JWT authentication and data persistence.

## 3. Future Enhancements (Post-MVP)
* **Social Leaderboards:** Real-time competition with friends.
* **Push Notifications:** Reminders to start a study session based on a schedule.
* **Advanced Analytics:** Weekly productivity charts.