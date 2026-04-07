# 🛫 Data Warehouse авиакомпании

[![dbt](https://img.shields.io/badge/dbt-1.8+-FF6849?style=flat-square)](https://www.getdbt.com/)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat-square)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-336791?style=flat-square)](https://www.postgresql.org/)

**Образовательный проект** на основе курса Stepik, демонстрирующий применение современного подхода **Data Vault 2.0** для построения масштабируемого хранилища данных авиакомпании.

## 📋 Оглавление

- [Описание проекта](#описание-проекта)
- [Архитектура данных](#архитектура-данных)
- [Установка и настройка](#установка-и-настройка)
- [Как запустить проект](#как-запустить-проект)
- [Структура проекта](#структура-проекта)
- [Примеры запросов](#примеры-запросов)
- [Полезные ресурсы](#полезные-ресурсы)

---

## 📖 Описание проекта

### Что это такое?

Это проект **Data Warehouse (хранилище данных)** для авиакомпании, построенный на фреймворке **dbt (data build tool)**. Проект преобразует сырые данные о полётах, пассажирах, самолётах и аэропортах в **чистые, структурированные таблицы**, готовые для анализа.

### Для чего нужен?

Проект помогает ответить на бизнес-вопросы:
- 🛫 Какие маршруты наиболее популярны?
- ✈️ Какова средняя загруженность самолётов?
- 📊 Какие аэропорты генерируют наибольший доход?
- 🔍 Как изменялись данные о рейсах со временем?

### Какие данные в проекте?

Проект работает с 8 основными сущностями:

| Сущность | Описание |
|----------|----------|
| **Aircrafts** | Модели самолётов, их характеристики |
| **Airports** | Информация об аэропортах (координаты, часовой пояс) |
| **Flights** | Расписание и фактические время вылета/прилёта |
| **Seats** | Конфигурация мест в каждом самолёте |
| **Bookings** | Бронирования пассажиров |
| **Tickets** | Билеты, связанные с бронированиями |
| **Ticket Flights** | Связь между билетами и рейсами |
| **Boarding Passes** | Посадочные талоны |

### Что такое Data Vault 2.0?

**Data Vault** — это методология проектирования хранилищ данных, которая фокусируется на:

1. **Гибкости** — легко добавлять новые источники данных
2. **Историчности** — сохранять все изменения данных со временем
3. **Масштабируемости** — простая структура для растущего объёма данных

Data Vault состоит из трёх основных типов таблиц:
- **Hubs** — уникальные ключи (например, ID самолёта)
- **Links** — отношения между сущностями (какой самолёт летит по какому маршруту)
- **Satellites** — атрибуты сущностей (название самолёта, количество мест и т.д.)

В этом проекте Data Vault таблицы **автоматически генерируются** пакетом `automate_dv`.

### Используемые пакеты

| Пакет | Версия | Назначение |
|-------|--------|-----------|
| **elementary** | 0.23.0 | 🔍 Контроль качества данных (дефолтные тесты) |
| **dbt_utils** | 1.3.3 | 🛠️ Утилиты и вспомогательные макросы |
| **codegen** | 0.14.0 | 🤖 Автоматическое создание YAML конфигов |
| **automate_dv** | 0.11.5 | 📦 Автоматизация построения Data Vault структур |

---

## 🏗️ Архитектура данных

Проект организован в **4 слоя**, каждый из которых выполняет свою функцию:

```
┌─────────────────────────────────────────────────┐
│   📊 MARTS (Витрины данных для аналитики)      │
│   Готовые таблицы для пользователей             │
└─────────────────────────────────────────────────┘
                        ↑
┌─────────────────────────────────────────────────┐
│   ⚙️ INTERMEDIATE (Промежуточный слой)         │
│   Агрегирование, вычисления, факт-таблицы       │
└─────────────────────────────────────────────────┘
                        ↑
┌─────────────────────────────────────────────────┐
│   🧹 STAGING (Очистка и нормализация)          │
│   Преобразование, валидация сырых данных         │
└─────────────────────────────────────────────────┘
                        ↑
┌─────────────────────────────────────────────────┐
│   📦 DATA VAULT (Исторические снимки)           │
│   Хранение полной истории изменений (automate_dv) │
└─────────────────────────────────────────────────┘
                        ↑
┌─────────────────────────────────────────────────┐
│   🗄️ RAW (Источник: PostgreSQL dwh_flight)     │
│   Исходные данные из источника                   │
└─────────────────────────────────────────────────┘
```

### Описание каждого слоя

#### 1️⃣ **Staging слой** (`/models/staging/`)
- **Назначение**: Очистка и стандартизация сырых данных
- **Правила**:
  - Один источник = одна staging модель (e.g., `stg_flights__flights.sql`)
  - Минимальные трансформации (переименование колонок, типы данных)
  - **Инкрементальный** материал с логикой `где дата >= последнее обновление`
- **Примеры**: `stg_flights__aircrafts`, `stg_flights__airports`, `stg_flights__flights`
- **Тесты**: Проверка не-null ключей, уникальність, валидность

#### 2️⃣ **Intermediate слой** (`/models/intermediate/`)
- **Назначение**: Подготовка данных для витрин (бизнес-логика, агрегирование)
- **Правила**:
  - Объединение данных с staging слоя
  - Создание вычисляемых колонок (например, возраст пассажира)
  - Может содержать факт-таблицы и dimensions
- **Примеры**: `fct_flights_bookings`, `fct_daily_flight_counts`
- **Особенность**: Видны в dbt docs, но не используются напрямую аналитиками

#### 3️⃣ **Marts слой** (`/models/marts/`)
- **Назначение**: Финальные таблицы, готовые для аналитиков и BI систем
- **Правила**:
  - Использует данные из intermediate слоя
  - Бизнес-ориентированные названия
  - Полная документация для пользователей
- **Примеры**: `dm_seats_occupied`, `fct_bookings_by_aircraft`
- **Специальность**: Оптимизированы для производительности и понимания

#### 4️⃣ **Data Vault слой** (`/models/Data_vault/`)
- **Назначение**: Хранение полной истории данных с версионированием
- **Структура** (автоматически генерируется через `automate_dv`):
  - `hub_aircrafts` — уникальные ключи самолётов
  - `sat_aircrafts_*` — атрибуты самолётов с историей изменений
  - `link_*` — связи между сущностями
- **Преимущества**: Можно проследить любое изменение, когда оно произошло и почему

---

## 🚀 Установка и настройка

### Требования

Убедитесь, что на вашем компьютере установлены:

- **Python 3.9+** — [скачать](https://www.python.org/downloads/)
- **PostgreSQL 13+** — [скачать](https://www.postgresql.org/download/)
- **Git** — [скачать](https://git-scm.com/)

Проверьте установку:

```bash
python --version      # Python 3.9+
psql --version        # PostgreSQL 13+
git --version         # Git 2.x+
```

### Пошаговая установка

#### 1. Клонирование репозитория

```bash
git clone <your-repo-url> dbt_stepik
cd dbt_stepik
```

#### 2. Создание виртуального окружения Python

Виртуальное окружение изолирует зависимости этого проекта от других Python проектов:

```bash
# Создание виртуального окружения
python -m venv venv

# Активация (macOS/Linux)
source venv/bin/activate

# Активация (Windows)
venv\Scripts\activate
```

Когда вы видите `(venv)` в начале строки — окружение активировано.

#### 3. Установка зависимостей Python

```bash
pip install --upgrade pip
pip install dbt-postgres
# или просто: pip install -r requirements.txt (если файл есть)
```

#### 4. Настройка подключения к PostgreSQL

dbt использует файл `profiles.yml` для подключения к базе данных. Создайте файл `~/.dbt/profiles.yml` (из терминала):

**На macOS/Linux:**
```bash
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml
```

**Содержимое `profiles.yml`:**

```yaml
dbt_stepik:
  outputs:
    dev:
      type: postgres
      host: localhost              # ваш хост БД (обычно localhost)
      user: postgres               # пользователь PostgreSQL
      password: your_password      # пароль postgSQL
      port: 5432                   # порт PostgreSQL (по умолчанию 5432)
      dbname: dwh_flight           # имя базы данных
      schema: dbt_dev              # схема, где будут созданы таблицы
      threads: 4                   # количество параллельных потоков
      keepalives_idle: 0
  target: dev                      # активный профиль
```

**Важно:**
- Замените `your_password` на реальный пароль
- `schema: dbt_dev` — это имя схемы в PostgreSQL, где dbt создаст модели
- Не коммитьте пароль в git! Добавьте `~/.dbt/profiles.yml` в `.gitignore`

#### 5. Установка dbt пакетов

```bash
dbt deps
```

Эта команда скачает все пакеты (elementary, dbt_utils, codegen, automate_dv) из `packages.yml`.

#### 6. Лучше всего — проверьте подключение

```bash
dbt debug
```

Вы должны увидеть ✅ после каждого чека, если всё настроено правильно.

---

## ▶️ Как запустить проект

### Основные dbt команды

| Команда | Что делает |
|---------|-----------|
| `dbt run` | Создаёт все модели в БД |
| `dbt test` | Запускает тесты качества данных |
| `dbt docs generate` | Генерирует документацию проекта |
| `dbt snapshot` | Создаёт снимки истории данных |
| `dbt seed` | Загружает данные из CSV файлов |
| `dbt freshness` | Проверяет свежесть исходных данных |

### Примеры выполнения

#### Запуск всех моделей

```bash
dbt run
```

**Вывод:**
```
Running with dbt=1.8.0
Found 23 models, 12 tests, 2 snapshots...
12:34:56 | 1 of 23 | creating table model dbt_dev.stg_flights__airports
12:34:57 | 2 of 23 | creating table model dbt_dev.stg_flights__aircrafts
...
12:35:30 | 23 of 23 | creating table model dbt_dev.dm_seats_occupied
Done. PASS   [23 rows]
```

#### Запуск конкретного слоя

```bash
# Только staging модели
dbt run --selector staging

# Только intermediate модели
dbt run --selector intermediate

# Только marts модели
dbt run --selector marts
```

#### Запуск конкретной модели

```bash
dbt run --select stg_flights__flights
```

#### Запуск моделей с зависимостями

```bash
# Запустить модель И все модели, которые зависят от неё (downstream)
dbt run --select stg_flights__flights+
```

#### Запуск снимков истории

```bash
dbt snapshot
```

**Создаёт снимки для отслеживания изменений в:**
- `snap_flights__aircrafts` — история изменения самолётов
- `snap_flights__seats` — история изменения конфигурации мест

#### Запуск тестов

```bash
# Все тесты
dbt test

# Только тесты для staging моделей
dbt test --selector staging

# Только специфический тест
dbt test --select stg_flights__flights
```

#### Генерация и просмотр документации

```bash
# Генерирует документацию
dbt docs generate

# Стартует локальный сервер на http://localhost:8000
dbt docs serve
```

Откройте браузер и перейдите на `http://localhost:8000` — вы увидите интерактивный граф моделей, их взаимосвязи и описания! 📊

### Полный цикл разработки

```bash
# 1. Загрузить пакеты
dbt deps

# 2. Создать моделй
dbt run

# 3. Запустить тесты
dbt test

# 4. Если всё ОК — генерируем документацию
dbt docs generate
dbt docs serve
```

---

## 📁 Структура проекта

```
dbt_stepik/
├── dbt_project.yml          # Конфигурация проекта
├── packages.yml             # Зависимости dbt пакетов
├── profiles.yml             # Подключение к БД (не коммитить!)
├── pyproject.toml           # Зависимости Python
├── selectors.yml            # Определение селекторов для групп моделей
│
├── models/                  # 📦 Все dbt модели
│   ├── staging/             # 🧹 Слой очистки данных
│   │   ├── flights/         # Staging модели для авиаперевозок
│   │   └── demo_src/        # Staging модели для другого источника
│   ├── intermediate/        # ⚙️ Промежуточный слой
│   │   └── flights/         # Факт-таблицы, агрегирование
│   ├── marts/               # 📊 Витрины для аналитики
│   │   └── flights/         # Готовые таблицы
│   └── Data_vault/          # 📦 Data Vault (automate_dv)
│       ├── raw_stage/       # Raw stage слой Data Vault
│       ├── raw_vault/       # Raw vault слой Data Vault
│       └── stage/           # Stage слой Data Vault
│
├── tests/                   # 🧪 Пользовательские тесты
│   ├── staging/             # Тесты для staging слоя
│   └── intermediate/        # Тесты для intermediate слоя
│
├── snapshots/               # 📸 Снимки истории (SCD)
│   ├── snap_flights__aircrafts.sql
│   └── snap_flights__seats.sql
│
├── seeds/                   # 📄 CSV данные для загрузки
│   └── staff.csv            # Справочник сотрудников
│
├── macros/                  # 🛠️ Пользовательские функции
│   ├── backup_table_before_build.sql  # Бэкап таблиц
│   ├── check_dependencies.sql         # Проверка зависимостей
│   ├── limit_data_dev.sql             # Ограничение данных для разработки
│   └── generic/             # Пользовательские тесты
│       └── airport_code_pattern.sql
│
├── analyses/                # 🔍 Аналитические запросы
│   └── flights_by_aircraft.sql   # Пример аналитического запроса
│
├── logs/                    # 📋 Логи выполнения dbt команд
│
├── target/                  # 🎯 Скомпилированный код (автогенерируется)
│   ├── compiled/            # SQL файлы после компиляции
│   ├── run/                 # Результаты выполнения
│   └── manifest.json        # Граф проекта
│
└── README.md                # 📖 Этот файл!
```

### Каждая директория — для чего?

**`/models/`** — Сердце проекта. Содержит все SQL файлы dbt моделей. Каждый файл = одна таблица или представление в БД.

**`/tests/`** — Проверки качества данных. Пример: "убедись, что в колонке aircraft_id нет NULL значений".

**`/snapshots/`** — Снимки данных на определённую дату. Помогает отследить изменения (медленно меняющееся измерение, SCD).

**`/seeds/`** — Маленькие справочные таблицы в формате CSV. Загружаются в БД с помощью `dbt seed`.

**`/macros/`** — Переиспользуемые куски кода (функции). Пример: макрос для проверки зависимостей.

**`/analyses/`** — SQL запросы, которые не создают таблицы. Используются для ad-hoc анализа.

**`target/`** — Автоматически генерируется. Содержит скомпилированный SQL и метаданные проекта.

---

## 📊 Примеры запросов

После успешного запуска `dbt run`, вы можете писать SQL запросы к созданным таблицам.

### Пример 1️⃣: Количество рейсов по аэропортам отправления

```sql
SELECT 
    ap.airport_name,
    COUNT(DISTINCT flight_id) as flight_count
FROM dbt_dev.stg_flights__flights f
JOIN dbt_dev.stg_flights__airports ap ON f.departure_airport_id = ap.airport_id
GROUP BY ap.airport_name
ORDER BY flight_count DESC
LIMIT 10;
```

**Результат:** Вы увидите топ-10 аэропортов по количеству рейсов.

---

### Пример 2️⃣: Средняя загруженность самолётов по типам

```sql
SELECT 
    ac.aircraft_model,
    COUNT(bp.boarding_pass_id) as total_boarded_passengers,
    COUNT(DISTINCT f.flight_id) as total_flights,
    ROUND(COUNT(bp.boarding_pass_id)::NUMERIC / COUNT(DISTINCT f.flight_id), 2) 
        as avg_passengers_per_flight
FROM dbt_dev.stg_flights__aircrafts ac
LEFT JOIN dbt_dev.stg_flights__flights f ON ac.aircraft_id = f.aircraft_id
LEFT JOIN dbt_dev.stg_flights__boarding_passes bp ON f.flight_id = bp.flight_id
GROUP BY ac.aircraft_model
ORDER BY avg_passengers_per_flight DESC;
```

**Результат:** Какие типы самолётов наиболее загружены — полезно для планирования.

---

### Пример 3️⃣: История изменений конфигурации мест (с использованием снимков)

```sql
SELECT 
    aircraft_id,
    seat_number,
    fare_class,
    dbt_valid_from,
    dbt_valid_to,
    CASE 
        WHEN dbt_valid_to IS NULL THEN 'Текущая'
        ELSE 'История'
    END as status
FROM dbt_dev.snap_flights__seats
WHERE aircraft_id = 1
ORDER BY aircraft_id, seat_number, dbt_valid_from DESC;
```

**Результат:** Полная история всех изменений конфигурации мест — когда изменилась класс сиденья и когда изменилось.

---

### Пример 4️⃣: Использование готовой витрины (marts)

```sql
SELECT 
    flight_id,
    seats_total,
    seats_occupied,
    seats_occupied::NUMERIC / seats_total * 100 as occupancy_percent
FROM dbt_dev.dm_seats_occupied
WHERE occupancy_percent > 80
ORDER BY occupancy_percent DESC;
```

**Результат:** Все рейсы с загруженностью более 80% — для анализа популярных маршрутов.

---

### Пример 5️⃣: Data Vault запрос — полная история одного самолёта

```sql
SELECT 
    h.aircraft_hkey,
    h.aircraft_id,
    s.aircraft_model,
    s.model_year,
    s.dbt_valid_from,
    s.dbt_valid_to
FROM dbt_dev.hub_aircrafts h
LEFT JOIN dbt_dev.sat_aircrafts_details s ON h.aircraft_hkey = s.aircraft_hkey
WHERE h.aircraft_id = 1
ORDER BY s.dbt_valid_from DESC;
```

**Результат:** Полная временная шкала всех изменений информации о самолёте, вплоть до мельчайших деталей.

---

## 🔗 Полезные ресурсы

### dbt Документация
- [Официальная документация dbt](https://docs.getdbt.com/) — полная справка
- [dbt Tutorial](https://docs.getdbt.com/docs/introduction) — пошаговое введение
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices) — рекомендации

### Data Vault
- [Data Vault 2.0 Guide](https://www.whitehouse.gov/) — практическое руководство
- [automate_dv документация](https://automate-dv.readthedocs.io/en-latest/) — документация пакета

### PostgreSQL
- [PostgreSQL Tutorial](https://www.postgresql.org/docs/current/tutorial.html) — начало работы
- [PostgreSQL SQL Commands](https://www.postgresql.org/docs/current/sql-commands.html) — справка по SQL

### Соседние пакеты
- [elementary](https://elementary-data.com/) — Data Quality & Observability
- [dbt_utils](https://github.com/dbt-labs/dbt-utils) — полезные макросы
- [codegen](https://github.com/dbt-labs/dbt-codegen) — генерация YAML

---

## 💡 Советы для новичков

### 📚 Как добавить новую модель?

1. **Создайте SQL файл** в `/models/staging/flights/st_your_model.sql`
2. **Напишите SELECT запрос**:
   ```sql
   SELECT
       id,
       name,
       created_at
   FROM {{ source('flights', 'your_source_table') }}
   ```
3. **Запустите модель**: `dbt run --select st_your_model`
4. **Проверьте результат** в PostgreSQL

### 🧪 Как добавить тест?

1. **Создайте файл** `/tests/staging/test_stg_your_model.sql`
2. **Напишите SQL проверку**:
   ```sql
   SELECT * FROM {{ ref('stg_your_model') }}
   WHERE id IS NULL
   ```
   Если SELECT вернёт строки — тест не пройдёт ✗
3. **Запустите тест**: `dbt test`

### 🧹 Как отладить модель?

```bash
# Используйте compile для компиляции без выполнения
dbt compile --select your_model

# Откройте target/compiled/dbt_stepik/models/...
# Там найдёте финальный SQL
```

### 🐛 Если dbt run выдаёт ошибку?

1. Посмотрите логи:
   ```bash
   less logs/dbt.log  # или `tail -100 logs/dbt.log`
   ```
2. Проверьте подключение:
   ```bash
   dbt debug
   ```
3. Запустите конкретное модель с доп. информацией:
   ```bash
   dbt run --select your_model --debug
   ```

---

## 📝 Контрибьютинг

Нашли ошибку? Хотите улучшить проект?

1. **Fork репозиторий**
2. **Создайте ветку**: `git checkout -b feature/your-improvement`
3. **Внесите изменения**
4. **Запустите тесты**: `dbt test`
5. **Отправьте Pull Request** 🎉

---

## 📞 Нужна помощь?

- 💬 Вопросы по dbt? [dbt Slack Community](https://www.getdbt.com/community/join-the-community)
- 🐛 Баг? Создайте Issue в этом репозитории
- 📧 Прямое сообщение — добавьте контакт

---

**Успехов в изучении dbt и Data Engineering! 🚀**

*Last updated: 2026-04-03*
