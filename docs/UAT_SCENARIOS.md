# User Acceptance Testing (UAT) Scenarios

| Test ID | Scenario | Steps to Reproduce | Expected Result | Status |
| :--- | :--- | :--- | :--- | :---: |
| **UAT-01** | Successful Registration | 1. Open app. <br> 2. Enter new email and password. <br> 3. Tap 'Register'. | User is created in the database and redirected to the login screen. | Pass |
| **UAT-02** | Timer Initiation | 1. Select 15 min mode. <br> 2. Place device face down on a flat surface. | The accelerometer detects the Z-axis change and automatically starts the countdown timer. | Pass |
| **UAT-03** | Interrupted Session | 1. Start a session. <br> 2. Pick up the phone after 10 seconds. | The session is instantly aborted, an error screen is shown, and 0 points are awarded. | Pass |
| **UAT-04** | Offline Saving | 1. Turn off Wi-Fi/Data. <br> 2. Complete a session. | Points are saved to local SQLite/SharedPreferences. A sync attempt is queued for the next online launch. | Pass |