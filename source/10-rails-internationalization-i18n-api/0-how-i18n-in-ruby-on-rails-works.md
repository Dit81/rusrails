# Как работает I18n в Ruby on Rails

Интернационализация - это сложная проблема. Естественные языки отличаются во многих отношениях (например, в правилах образования множественного числа), поэтому трудно предоставить инструменты, решающие сразу все проблемы. По этой причине Rails I18n API сфокусировано на:

* предоставления полной поддержки для английского и подобных ему языков
* легкой настраиваемости и полном расширении для других языков

Как часть этого решения, **каждая статичная строка в фреймворке Rails** - например, валидационные сообщения Active Record, форматы времени и даты - **стали интернационализированными**, поэтому _локализация_ приложения на Rails означает "переопределение" этих значений по умолчанию.

### Общая архитектура библиотеки

Таким образом, Ruby гем I18n разделен на две части:

* Публичный API фреймворка i18n - модуль Ruby с публичными методами, определяющими как работает библиотека
* Бэкенд по умолчанию (который специально называется _простым_ бэкендом), реализующий эти методы

Как у пользователя, у вас всегда будет доступ только к публичным методам модуля I18n, но полезно знать о возможностях бэкенда.

NOTE: Возможно (или даже желательно) поменять встроенный простой бэкенд на более мощный, который будет хранить данные перевода в реляционной базе данных, словаре GetText и тому подобном. Смотрите раздел [Использование различных бэкендов](/rails-internationalization-i18n-api/customize-your-i18n-setup).

### Публичный I18n API

Наиболее важными методами I18n API являются:

```ruby
translate # Ищет перевод текстов
localize  # Локализует объекты даты и времени в форматы локали
```

Имеются псевдонимы #t и #l, их можно использовать следующим образом:

```ruby
I18n.t 'store.title'
I18n.l Time.now
```

Также имеются методы чтения и записи для следующих атрибутов:

```ruby
load_path         # Анонсировать ваши пользовательские файлы с переводом
locale            # Получить и установить текущую локаль
default_locale    # Получить и установить локаль по умолчанию
exception_handler # Использовать иной exception_handler
backend           # Использовать иной бэкенд
```

Итак, давайте интернационализуем простое приложение на Rails с самого начала, в следующих главах!
