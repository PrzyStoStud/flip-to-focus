# Product Analysis & Backlog

## 1. Uzasadnienie platformy mobilnej (Mobile Justification)
Aplikacja **musi** być rozwiązaniem mobilnym, ponieważ jej główna mechanika opiera się na fizycznej interakcji z urządzeniem. 
* **Sensory sprzętowe:** Wykorzystujemy natywny akcelerometr (oś Z) wbudowany w smartfon, aby wykryć odłożenie telefonu ekranem do dołu. Aplikacja desktopowa lub webowa nie ma dostępu do takich danych przestrzennych w naturalnym środowisku użytkownika.
* **Kontekst użycia:** Smartfon jest głównym rozpraszaczem podczas nauki. Fizyczne "odcięcie" użytkownika od ekranu pełnego powiadomień to główny cel biznesowy aplikacji, niemożliwy do zrealizowania za pomocą programu na komputerze PC.

## 2. Product Backlog (15 User Stories)
Poniżej znajduje się pełny zestaw User Stories definiujący wymagania dla wersji MVP oraz kluczowych funkcji wspierających, zarządzany poprzez zakładkę Issues:

**Autoryzacja i Bezpieczeństwo:**
* **US-01:** Jako nowy użytkownik chcę założyć konto używając adresu email, aby móc bezpiecznie przechowywać swoje postępy w nauce.
* **US-02:** Jako powracający użytkownik chcę móc się zalogować, aby odzyskać dostęp do mojego profilu i punktów.
* **US-03:** Jako system chcę, aby tokeny dostępowe (JWT) wygasały po 30 minutach braku aktywności, aby zapewnić bezpieczeństwo danych użytkownika.

**Konfiguracja i UI:**
* **US-04:** Jako użytkownik chcę móc wybrać czas trwania sesji skupienia (15, 25 lub 60 minut), aby dostosować technikę Pomodoro do moich aktualnych zadań.
* **US-05:** Jako użytkownik chcę otrzymać czytelny komunikat z prośbą o wyłączenie optymalizacji baterii, aby system nie ubijał timera działającego w tle.
* **US-06:** Jako użytkownik chcę widzieć wskaźnik ładowania (loader) podczas łączenia z API, aby wiedzieć, że aplikacja nie uległa zawieszeniu.

**Mechanika Timera i Sensory (Core MVP):**
* **US-07:** Jako aplikacja chcę monitorować odczyty z akcelerometru (oś Z), aby automatycznie uruchomić odliczanie timera w momencie płaskiego odłożenia telefonu.
* **US-08:** Jako użytkownik chcę, aby jakiekolwiek podniesienie telefonu przed końcem czasu natychmiast przerywało sesję, aby wymusić na mnie fizyczne odcięcie od ekranu.
* **US-09:** Jako użytkownik chcę poczuć wibrację po upływie wyznaczonego czasu, aby wiedzieć, że mogę podnieść telefon bez utraty punktów.
* **US-10:** Jako użytkownik chcę zobaczyć ekran gratulacyjny po udanej sesji, aby otrzymać pozytywne wzmocnienie psychologiczne.

**Grywalizacja i Profil:**
* **US-11:** Jako system chcę automatycznie przeliczać ukończony czas na punkty, aby nagradzać użytkownika za jego skupienie.
* **US-12:** Jako użytkownik chcę widzieć całkowitą sumę swoich punktów w zakładce profilu, aby śledzić swój długoterminowy postęp.
* **US-13:** Jako użytkownik chcę mieć dostęp do historii moich ostatnich sesji (zarówno udanych, jak i przerwanych), aby analizować swoją produktywność.

**Obsługa Offline (Tryb samolotowy / Brak sieci):**
* **US-14:** Jako użytkownik przebywający poza zasięgiem internetu chcę, aby moje ukończone sesje były zapisywane w pamięci lokalnej urządzenia, abym nie tracił punktów za naukę w trybie offline.
* **US-15:** Jako aplikacja chcę automatycznie synchronizować lokalnie zapisane punkty z backendem przy najbliższym udanym połączeniu z siecią, aby zachować spójność bazy danych.