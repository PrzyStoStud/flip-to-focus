# Checklista Testów Akceptacyjnych (UAT)

Poniższa checklista służy do manualnej weryfikacji aplikacji przed każdym wydaniem produkcyjnym.

### Autoryzacja i Profil
- [x] Podanie prawidłowych danych logowania poprawnie autoryzuje użytkownika i przekierowuje na ekran główny.
- [x] Próba logowania na nieistniejące konto wyrzuca odpowiedni komunikat błędu.
- [x] Ekran profilu poprawnie zaciąga i wyświetla sumę punktów z backendu.

### Mechanika Timera i Sensory
- [x] Wybranie opcji "15 minut" poprawnie ustawia zmienną timera na 900 sekund.
- [x] Odłożenie telefonu ekranem do dołu płasko na biurku automatycznie odpala timer.
- [x] Podniesienie telefonu w trakcie trwania sesji natychmiast ją przerywa i wyświetla ekran porażki.
- [x] Odczekanie pełnego czasu sesji w pozycji "ekranem w dół" wyświetla ekran sukcesu i dodaje punkty.

### Obsługa Offline
- [x] Ukończenie sesji przy wyłączonym Wi-Fi/LTE poprawnie zapisuje punkty w lokalnej bazie.
- [x] Aplikacja po odzyskaniu połączenia z siecią przesyła zaległe punkty na serwer.