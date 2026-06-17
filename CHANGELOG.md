# Changelog

## [1.0.0] - Wydanie Produkcyjne (MVP)
- **Feat:** Wdrożono pełny przepływ logowania i autoryzacji opartej na tokenach JWT (FastAPI).
- **Feat:** Podpięto natywny akcelerometr osi Z do uruchamiania i przerywania timera.
- **Feat:** Wdrożono obsługę pamięci lokalnej (Offline Storage) dla sesji wykonanych bez internetu.
- **DevOps:** Skonfigurowano GitHub Actions do automatycznego budowania plików APK oraz testowania kodu (mypy, ruff, pytest, flutter test).

## [0.5.0] - Wersja Beta (Wewnętrzne testy)
- **Feat:** Wdrożono szkielet aplikacji w technologii Flutter.
- **Feat:** Dodano ekrany wyboru czasu (15, 25, 60 minut) oraz ekran profilu.
- **Fix:** Poprawiono czułość sensora, zapobiegając przypadkowemu przerywaniu sesji.


## [0.1.0] - Inicjalizacja
- Inicjalizacja repozytorium monolitycznego (folder `server` oraz `flip_to_focus`).
- Ustawienie konfiguracji Docker Compose dla środowiska lokalnego bazy SQLite.