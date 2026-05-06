<div align="center">
  <img src="docs/movie_search_assistant_icon.png" alt="Logo" width="120"/>
  <h1>Movie Search Assistant Bloc</h1>
  <p><em>Flutter-приложение для поиска фильмов, просмотра информации, создания личных коллекций </em></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Platform](https://img.shields.io/badge/Platform-Android%20|%20iOS-lightgrey?style=for-the-badge)](https://github.com)
  [![RuStore](https://img.shields.io/badge/RuStore-Скачать-blue?logo=android)](https://www.rustore.ru/catalog/app/com.example.movie_search_assistant_bloc)
  [![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)]()
</div>

---

## 🎬О проекте

**Movie Search Assistant Bloc** — это мобильное приложение, разработанное на Flutter, которое позволяет пользователям искать фильмы, просматривать подробную информацию о фильмах, создавать личные коллекции фильмов. 

**Примечание:**
**Movie Search Assistant Bloc** является переосмыслением мобильного приложения [Movie Search Assistant](https://github.com/VladislavGrom1/MovieSearchAssistant). Проект разрабатывался для освоения архитектурного подхода Clean Architecture Bloc и расширения функциональных возможностей проекта.

Ключевые нововведения по сравнению с версией проекта [Movie Search Assistant](https://github.com/VladislavGrom1/MovieSearchAssistant):

- Новая архитектура и применение `flutter_bloc` для реализации State-Management
- Возможность создавать собственные `коллекции`
- Сохранение фильмов в несколько `коллекций` одновременно
- Возможность устанавливать `отзыв` и `личный рейтинг` сохранённым фильмам
- `Индикатор`, сообщающий пользователю, что фильм уже сохранён в одну из `коллекций`
- Экспорт/импорт сохранённых данных в формате `.zip`
- Доработанная система кэширования изображений и очистки `кэша`
- Обновлённый `UI/UX` для более приятного опыта использования приложения
- Публикация приложения в `RuStore`

---

## 🎬Основные возможности

- 🔍 Поиск фильмов по ключевым словам
- 🎯 Фильтрация по жанру, году и стране
- 📊 Просмотр популярных коллекций (топы, сериалы и др.)
- 📄 Детальная информация о фильме (описание, рейтинг, изображения)
- ❤️ Создание личных коллекций
- 🎬 Локальное сохранение фильмов
- 💾 Сохранение пользовательского рейтинга и отзыва к фильмам
- 🔄 Импорт и экспорт коллекций (.zip)
- 📡 Работа без интернета (для сохранённых данных)

---

## 🎬Скриншоты

<div align="center">
  <img src="./docs/app_screens.png" width="100%" alt="App Screens"/>
</div>

---

## 🎬API

Приложение использует сторонний сервис:

👉 https://kinopoiskapiunofficial.tech

⚠️ Для использования всех возможностей мобильного приложения Movie Search Assistant необходимо получить API-ключ и ввести его в мобильном приложении:

1. Зарегистрируйтесь на сервисе https://kinopoiskapiunofficial.tech и в профиле получите свой API-ключ
2. Введите API-ключ после запуска приложения
3. Используйте все возможности мобильного приложения

**Важно:**
- Бесплатный лимит — 500 запросов
- Требуется интернет-соединение для поиска

---

## 🎬Экспорт / Импорт данных

Приложение поддерживает:

- Экспорт коллекций в `.zip`
- Импорт данных обратно в приложение

Это позволяет сохранять и переносить данные между устройствами.

---

## 🎬Установка и запуск

```bash
git clone https://github.com/VladislavGrom1/MovieSearchAssistantBloc.git
cd MovieSearchAssistantBloc
flutter pub get
flutter run
```

