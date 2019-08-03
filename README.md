# ElixirAwesome

## Задание 

У языка Elixir, как и у многих других 1 , существует свой «awesome list»: h4cc/awesome-
elixir. Однако, библиотеки, будучи добавленными в него, устаревают, перестают
поддерживаться или, не набрав заметной популярности, начинают уступать своим
аналогам.
Для наглядного отображения состояния библиотек в awesome list для Elixir вам
предлагается реализовать web-приложение, удовлетворяющее следующим
требованиям:

* Приложение написано на языке Elixir с использованием фреймворка Phoenix.
* Приложение состоит из единственной заглавной страницы: /.
* На этой странице отображена информация о библиотеках Elixir, полученная из 
репозитария awesome list-а https://github.com/h4cc/awesome-elixir.
* Эта информация обновляется ежедневно.   

К описанию каждой библиотеки добавлена следующая информация:
* число ее звезд на Github;
* число дней, прошедших со времени последнего коммита в её репозиторий на
Github.

Страница принимает параметр min_stars: /?min_stars=50.
При указании этого параметра на странице выводятся только те библиотеки, у которых
не менее min_stars звезд.
Если в каком-то разделе не оказалось библиотек после фильтрации по min_stars, то
весь раздел не отображается.
Код должен быть покрыт тестами.
Инструкции по запуску должны находиться в README.
Пример функциональности того, что должно получиться: http://awesome-elixir.ru/

## Подготовка проекта к работе

**Подготовка Backend**

1. mix deps.get
2. mix do ecto.create ecto.migrate
3. Поместить `dev.custom.exs` в папку конфигурации (Смотри пункт "Обход ограничения на колчество запросов")

**Подготовка Frontend**

* cd assets
* npm i

**(!)** Обход ограничения на колчество запросов

В этой задаче есть один подводным камень: нужно сделать порядка 2400 запросов к API GitHub.
Есть ограничение на количество запросов с одного IP адреса https://developer.github.com/v3/#rate-limiting
Если пользователь не авторизованный, то 60 запросов, если авторизованный - 5000.
Поэтому необходимо добавить свои авторизационные данные в папку конфигураций в файл: `dev.custom.exs` в виде:

```elixir
use Mix.Config

config :elixir_awesome, :github_credentials,
  username: "<username>",
  password: "<password>"
```

Используется базовая авторизация.

## Работа проекта

### LiveView

Этого не было в задании, но я решил использовать LiveView чтобы реализовать наглядное отображение процесса обновления библиотек

1. Из корня проекта запустить сервер `mix phx.server`
2. Зайти на главную страницу проекта `http://localhost:4000/main_page_live`
3. Нажать кнопку `Start refreshing` http://joxi.ru/4Akqo3wSo9lQym Отмечена цифрой `1` 
4. Наблюдать как количество обновлённых бибилотек увеличивается http://joxi.ru/p27P98eUKR8O6A
5. Есть возможность фильтровать по минимальному количеству звёзд http://joxi.ru/4Akqo3wSo9lQym (Отмечена цифрой `2`) можно кнопками
6. Данные по библиотекам обновляются Concurrency воркерами. Общее количество запросов ~2400 всё это выполняется приблизительно за 3 минуты 
7. Обновление автоматически запускается в 00:00 в UTC+0. Запускает его `ElixirAwesome.External.RefreshDataScheduler`

P.S. В самом конце загрузки несколько воркеров зависают на какое-то время. Но в конечном итоге отвисают и интерфейс переходит в изначальное состояние.

### Обычная HTML страница

Перед запуском стоит очистить базу, чтобы увидеть как меняется количество загруженных библиотек ``

1. Из корня проекта запустить сервер `mix phx.server`
2. Зайти на главную страницу проекта `http://localhost:4000/`
3. Нажать кнопку `Start refreshing` http://joxi.ru/4Akqo3wSo9lQym (Отмечена цифрой `1`) 
4. Наблюдать как количество обновлённых бибилотек увеличивается http://joxi.ru/p27P98eUKR8O6A (Для этого необходимо обновить страницу)
5. Есть возможность фильтровать по минимальному количеству звёзд http://joxi.ru/4Akqo3wSo9lQym (Отмечена цифрой `2`) можно кнопками а можно просто передавать в качестве URL параметра
6. Данные по библиотекам обновляются Concurrency воркерами. Общее количество запросов ~2400 всё это выполняется приблизительно за 3 минуты 
7. Обновление автоматически запускается в 00:00 в UTC+0. Запускает его `ElixirAwesome.External.RefreshDataScheduler`

Кроме этого можно зайти на страницу `http://localhost:4000/main_page_live` она абсолютно идентична за исключением того, что
когда запускается обновление библиотек можно динамически наблюдать

## План действий (100%):

* + Сверстать страницу с моком данных и фильтрацией по звёздам
* + Реализовать автоматический запрос по крону обновления данных
* + Написать тесты на всё (Написанно не на всё, но на большую часть. На всё, что важно.)
* + (Опционально) Реализовать страницу с LiveView, возможностью динамически подгрузать данные по репозиториям.

## Детали

* Загрузка данных по библиотекам осуществляется асинхронно
* Интервал загрузки задаётся в настройках приложения
* Загрузка осуществляется по CRON
* Для осуществления HTTP запросов используется HTTPoison
* Получение данных из GitHub осуществляется с помощью REST API https://developer.github.com/v3/
* Для стилей используется Bootstrap


##Измерения

Данные о библиотеках запрашиваются конкурирующими воркерами. Это было сделано намерено, чтобы уменшить время скачивания.

Количество библиотек: ~1340
Время скачивания 1 воркером: ~ 24 минут
Время скачивания 10 воркерами: ~ 3 минут

Очевидно что конкурирующие воркеры осуществляют операцию существенно быстрее. 
