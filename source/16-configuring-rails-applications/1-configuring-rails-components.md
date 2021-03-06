# Конфигурирование компонентов Rails

В целом, работа по конфигурированию Rails означет как настройку компонентов Rails, так и настройку самого Rails. Конфигурационный файл `config/application.rb` и конфигурационные файлы конкретных сред (такие как `config/environments/production.rb`) позволяют определить различные настройки, которые можно придать всем компонентам.

Например, по умолчанию файл `config/application.rb` включает эту настройку:

```ruby
config.filter_parameters += [:password]
```

Это настройка для самого Rails. Если хотите передать настройки для отдельных компонентов Rails, это так же осуществляется через объект `config` в `config/application.rb`:

```ruby
config.active_record.schema_format = :ruby
```

Rails будет использовать эту конкретную настройку для конфигурирования Active Record.

### Общие настройки Rails

Эти конфигурационные методы вызываются на объекте `Rails::Railtie`, таком как подкласс `Rails::Engine` или `Rails::Application`.

* `config.after_initialize` принимает блок, который будет запущен _после того_, как Rails закончит инициализацию приложения. Это включает инициализацию самого фреймворка, engine-ов и всех инициализаторов приложения из _config/initializers_. Отметьте, что этот блок _будет_ выполнен для рейк-тасков. Полезно для конфигурирования настроек, установленных другими инициализаторами:

    ```ruby
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags.delete 'div'
    end
    ```

* `config.asset_host` устанавливает хост для ресурсов (ассетов). Полезна, когда для хостинга ресурсов используются CDN, или когда вы хотите обойти встроенную в браузеры политику ограничения домена при использовании различных псевдонимов доменов. Укороченная версия `config.action_controller.asset_host`.

* `config.autoload_once_paths` принимает массив путей, по которым Rails будет загружать константы, не стирающиеся между запросами. Уместна, если `config.cache_classes` является false, что является в режиме development по умолчанию. В противном случае все автозагрузки происходят только раз. Все элементы этого массива также должны быть в `autoload_paths`. По умолчанию пустой массив.

* `config.autoload_paths` принимает массив путей, по которым Rails будет автоматически загружать константы.По умолчанию все директории в `app`.

* `config.cache_classes` контролирует, будут ли классы и модули приложения перезагружены при каждом запросе. По умолчанию false в режиме development и true в режимах test и production. Также может быть включено с помощью `threadsafe!`.

* `config.action_view.cache_template_loading` контролирует, будут ли шаблоны перезагружены при каждом запросе. Умолчания те же, что и для `config.cache_classes`.

* `config.cache_store` конфигурирует, какое хранилище кэша использовать для кэширования Rails. Опции включают один из символов `:memory_store`, `:file_store`, `:mem_cache_store`, `:null_store` или объекта, реализующего API кэша. По умолчанию `:file_store` если существует директория `tmp/cache`, а в ином случае `:memory_store`.

* `config.colorize_logging` определяет, использовать ли коды цвета ANSI при логировании информации. По умолчанию true.

* `config.consider_all_requests_local` это флажок. Если true, тогда любая ошибка вызовет детальную отладочную информацию, которая будет выгружена в отклик HTTP, и контроллер `Rails::Info` покажет контекст выполнения приложения в `/rails/info/properties`. по умолчанию true в режимах development и test, и false в режиме production. Для более детального контроля, установить ее в false и примените `local_request?` в контроллерах для определения, какие запросы должны предоставлять отладочную информацию при ошибках.

* `config.console` позволит установить класс, который будет использован как консоль при вызове `rails console`. Лучше всего запускать его в блоке `console`:

    ```ruby
    console do
      # этот блок вызывается только при запуске консоли,
      # поэтому можно безопасно поместить тут pry
      require "pry"
      config.console = Pry
    end
    ```

* `config.dependency_loading` это флажок, позволяющий отключить автозагрузку констант, если установить его false. Он работает только если `config.cache_classes` установлен в true, что является по умолчанию в режиме production. Этот флажок устанавливается в false `config.threadsafe!`.

* `config.eager_load` когда true, лениво загружает все зарегистрированные `config.eager_load_namespaces`. Они включают ваше приложение, engine-ы, фреймворки Rails и любые другие зарегистрированные пространства имен.

* `config.eager_load_namespaces` регистрирует пространства имен, которые лениво загружаются, когда `config.eager_load` равно true. Все пространства имен в этом списке должны отвечать на метод `eager_load!`.

* `config.eager_load_paths` принимает массив путей, из которых Rails будет нетерпеливо загружать при загрузке, если включено кэширование классов. По умолчанию каждая папка в директории `app` приложения.

* `config.encoding` настраивает кодировку приложения. По умолчанию UTF-8.

* `config.exceptions_app` устанавливает приложение по обработке исключений, вызываемое промежуточной программой ShowException, когда происходит исключение. По умолчанию `ActionDispatch::PublicExceptions.new(Rails.public_path)`.

* `config.file_watcher` класс, используемый для обнаружения обновлений файлов в файловой системе, когда `config.reload_classes_only_on_change` равно true. Должен соответствовать `ActiveSupport::FileUpdateChecker` API.

* `config.filter_parameters` используется для фильтрации параметров, которые не должны быть показаны в логах, такие как пароли или номера кредитных карт.

* `config.force_ssl` принуждает все запросы быть под протоколом HTTPS, используя промежуточную программу `ActionDispatch::SSL`.

* `config.log_level` определяет многословие логгера Rails.Эта опция по умолчанию `:debug` для всех режимов, кроме production, для которого по умолчанию `:info`.

* `config.log_tags` принимает список методов, на которые отвечает объект `request`. С помощью этого становится просто тегировать строки лога отладочной информацией, такой как поддомен и id запроса - очень полезно для отладки многопользовательского приложения.

* `config.logger` принимает логгер, соответствующий интерфейсу Log4r или класса Ruby по умолчанию `Logger`. По умолчанию экземпляр `ActiveSupport::Logger`, с автоматическим приглушением в режиме production.

* `config.middleware` позволяет настроить промежуточные программы приложения. Это подробнее раскрывается в разделе "Конфигурирование промежуточных программ":#configuring-middleware ниже.

* `config.reload_classes_only_on_change` включает или отключает перезагрузку классов только при изменении отслеживаемых файлов. По умолчанию отслеживает все по путям автозагрузки и установлена true. Если `config.cache_classes` установлена true, Эта опция игнорируется.

* `config.secret_key_base` используется для определения ключа, позволяющего сессиям приложения быть верифицированными по известному ключу безопасности, чтобы избежать подделки. Приложения получают `config.secret_key_base` установленным в случайный ключ в `config/initializers/secret_token.rb`.

* `config.serve_static_assets` конфигурирует сам Rails на обслуживание статичных ресурсов. По умолчанию true, но в среде production выключается, так как серверные программы (т.е. Nginx или Apache), используемое для запуска приложения, должно обслуживать статичные ресурс вместо него. В отличие от установки по умолчанию, установите ее в true при запуске (абсолютно не рекомендуется!) или тестировании вашего приложения в режиме production с использованием WEBrick. В противном случае нельзя воспользоваться кэшированием страниц и запросами файлов, существующих обычно в директории public, что в любом случае испортит ваше приложение на Rails.

* `config.session_store` обычно настраивается в `config/initializers/session_store.rb` и определяет, какой класс использовать для хранения сессии. Возможные значения `:cookie_store`, которое по умолчанию, `:mem_cache_store` и `:disabled`. Последнее говорит Rails не связываться с сессиями. Произвольные хранилища сессии также могут быть определены:

    ```ruby
    config.session_store :my_custom_store
    ```

    Это произвольное хранилище должно быть определено как `ActionDispatch::Session::MyCustomStore`.

* `config.time_zone` устанавливает временную зону по умолчанию для приложения и включает понимание временных зон для Active Record.

* `config.beginning_of_week` устанавливает начало недели по умолчанию для приложения. Принимает символ валидного дня недели (т.е. `:monday`).

* `config.whiny_nils` включает или отключает предупреждения когда вызывается определенный набор методов у `nil` и он не отвечает на них. По умолчанию true в средах development и test.

### Настройка ресурсов (ассетов)

* `config.assets.enabled` это флажок, контролирующий, будет ли включен файлопровод (asset pipeline). Это явно устанавливается в `config/application.rb`.

* `config.assets.compress` это флажок, включающий компрессию компилируемых ресурсов. Он явно указан true в `config/production.rb`.

* `config.assets.css_compressor` определяет используемый компрессор CSS. По умолчанию установлен `sass-rails`. Единственное альтернативное значение в настоящий момент это `:yui`, использующее гем `yui-compressor`.

* `config.assets.js_compressor` определяет используемый компрессор JavaScript. Возможные варианты `:closure`, `:uglifier` и `:yui` требуют использование гемов `closure-compiler`, `uglifier` или `yui-compressor` соответственно.

* `config.assets.paths` содержит пути, используемые для поиска ресурсов. Присоединение путей к этой конфигурационной опции приведет к тому, что
эти пути будут использованы в поиске ресурсов.

* `config.assets.precompile` позволяет определить дополнительные ресурсы (иные, чем `application.css` и `application.js`), которые будут предварительно компилированы при запуске `rake assets:precompile`.

* `config.assets.prefix` определяет префикс из которого будут обслуживаться ресурсы. По умолчанию `/assets`.

* `config.assets.digest` включает использование меток MD5 в именах файлов. Установлено по умолчанию `true` в `production.rb`.

* `config.assets.debug` отключает слияние и сжатие ресурсов. Установлено по умолчанию `true` в `development.rb`.

* `config.assets.cache_store` определяет хранилище кэша, которое будет использовать Sprockets. По умолчанию это файловое хранилище Rails.

* `config.assets.version` опциональная строка, используемая при генерации хеша MD5. Может быть изменена для принудительной рекомпиляции всех файлов.

* `config.assets.compile` - булево значение, используемое для включения компиляции Sprockets на лету в production.

* `config.assets.logger` accepts a logger conforming to the interface of Log4r or the default Ruby `Logger` class. Defaults to the same configured at `config.logger`. Setting `config.assets.logger` to false will turn off served assets logging.

### Конфигурирование генераторов

Rails позволяет изменить, какие генераторы следует использовать, с помощью метода `config.generators`. Этот метод принимает блок:

```ruby
config.generators do |g|
  g.orm :active_record
  g.test_framework :test_unit
end
```

Полный перечень методов, которые можно использовать в этом блоке, следующий:

* `assets` позволяет создавать ресурсы при построении скаффолда. По умолчнию `true`.

* `force_plural` позволяет имена моделей во множественном числе. По умолчанию `false`.

* `helper` определяет, генерировать ли хелперы. По умолчанию `true`.

* `integration_tool` определяет используемый интеграционный инструмент. По умолчанию `nil`.

* `javascripts` включает в генераторах хук для файлов Javascript. Используется в Rails при запуске генератора `scaffold`. По умолчанию `true`.

* `javascript_engine` конфигурирует используемый движок (например, coffee) при создании ресурсов. По умолчанию `nil`.

* `orm` определяет используемую orm. По умолчанию `false` и используется Active Record.

* `performance_tool` определяет используемый инструмент оценки производительности. По умолчанию `nil`.

* `resource_controller` определяет используемый генератор для создания контроллера при использовании `rails generate resource`. По умолчанию `:controller`.

* `scaffold_controller`, отличающийся от `resource_controller`, определяет используемый генератор для создания _скаффолдингового_ контроллера при использовании `rails generate scaffold`. По умолчанию `:scaffold_controller`.

* `stylesheets` включает в генераторах хук для таблиц стилей. Используется в Rails при запуске генератора `scaffold` , но этот хук также может использоваться в других генераторах. По умолчанию `true`.

* `stylesheet_engine` конфигурирует используемый при создании ресурсов движок CSS (например, sass). По умолчанию `:css`.

* `test_framework` определяет используемый тестовый фреймворк. По умолчанию `false`, и используется Test::Unit.

* `template_engine` определяет используемый движок шаблонов, такой как ERB или Haml. По умолчанию `:erb`.

### Конфигурирование промежуточных программ (middleware)

Каждое приложение Rails имеет стандартный набор промежуточных программ, используемых в следующем порядке в среде development:

* `ActionDispatch::SSL` принуждает каждый запрос быть под протоколом HTTPS. Будет доступно, если `config.force_ssl` установлена `true`. Передаваемые сюда опции могут быть настроены с помощью `config.ssl_options`.

* `ActionDispatch::Static` используется для обслуживания статичных ресурсов (ассетов). Отключено если `config.serve_static_assets` равна `true`.

* `Rack::Lock` оборачивает приложение в mutex, таким образом оно может быть вызвано только в одном треде одновременно. Включено только если `config.cache_classes_` установлена как `false`.

* `ActiveSupport::Cache::Strategy::LocalCache` служит простым кэшем в памяти. Этот кэш не является тредобезопасным и предназначен только как временное хранилище кэша для отдельного треда.

* `Rack::Runtime` устанавливает заголовок `X-Runtime`, содержащия время (в секундах), затраченное на выполнение запроса.

* `Rails::Rack::Logger` пишет в лог, что начался запрос. После выполнения запроса сбрасывает логи.

* `ActionDispatch::ShowExceptions` ловит исключения, возвращаемые приложением, и рендерит прекрасные страницы исключения, если запрос локальный или если `config.consider_all_requests_local` установлена `true`. Если `config.action_dispatch.show_exceptions` установлена `false`, исключения будут вызваны не смотря ни на что.

* `ActionDispatch::RequestId` создает уникальный заголовок X-Request-Id, доступный для отклика, и включает метод `ActionDispatch::Request#uuid`.

* `ActionDispatch::RemoteIp` проверяет на атаки с ложных IP и получает валидный `client_ip` из заголовков запроса. Конфигурируется с помощью настроек `config.action_dispatch.ip_spoofing_check` и `config.action_dispatch.trusted_proxies`.

* `Rack::Sendfile` перехватывает отклики, чьи тела были обслужены файлом, и заменяет их специфичным для сервером заголовком X-Sendfile. Конфигурируется с помощью `config.action_dispatch.x_sendfile_header`.

* `ActionDispatch::Callbacks` запускает подготовленные колбэки до обслуживания запроса.

* `ActiveRecord::ConnectionAdapters::ConnectionManagement` очищает активные соединения до каждого запроса, за исключением случая, когда ключ `rack.test` в окрежении запроса установлен `true`.

* `ActiveRecord::QueryCache` кэширует все запросы SELECT, созданные в запросе. Если имел место INSERT или UPDATE, то кэш очищается.

* `ActionDispatch::Cookies` устанавливает куки для каждого запроса.

* `ActionDispatch::Session::CookieStore` ответственно за хранение сессии в куки. Для этого может использоваться альтернативная промежуточная программа, при изменении `config.action_controller.session_store` на альтернативное значение. Кроме того, переданные туда опции могут быть сконфигурированы `config.action_controller.session_options`.

* `ActionDispatch::Flash` настраивает ключи `flash`. Доступно только если у `config.action_controller.session_store` установленно значение.

* `ActionDispatch::ParamsParser` парсит параметры запроса в `params`.

* `Rack::MethodOverride` позволяет методу быть переопределенным, если установлен `params[:_method]`. Это промежуточная программа, поддерживающая типы методов HTTP PATCH, PUT и DELETE.

* `ActionDispatch::Head` преобразует запросы HEAD в запросы GET и обслуживает их соответствующим образом.

* `ActionDispatch::BestStandardsSupport` включает "best standards support", таким образом IE8 корректно рендерит некоторые элементы.

Кроме этих полезных промежуточных программ можно добавить свои, используя метод `config.middleware.use`:

```ruby
config.middleware.use Magical::Unicorns
```

Это поместит промежуточную программу `Magical::Unicorns` в конец стека. Можно использовать `insert_before`, если желаете добавить промежуточную программу перед другой.

```ruby
config.middleware.insert_before ActionDispatch::Head, Magical::Unicorns
```

Также есть `insert_after`, который вставляет промежуточную программу после другой:

```ruby
config.middleware.insert_after ActionDispatch::Head, Magical::Unicorns
```

Промежуточные программы также могут быть полностью переставлены и заменены другими:

```ruby
config.middleware.swap ActionDispatch::BestStandardsSupport, Magical::Unicorns
```

Они также могут быть убраны из стека полностью:

```ruby
config.middleware.delete ActionDispatch::BestStandardsSupport
```

### Конфигурирование i18n

* `config.i18n.default_locale` устанавливает локаль по умолчанию для приложения, используемого для интернационализации. По умолчанию `:en`.

* `config.i18n.load_path` устанавливает путь, используемый Rails для поиска файлов локали. По умолчанию `config/locales/*.{yml,rb}`.

### Конфигурирование Active Record

`config.active_record` включает ряд конфигурационных опций:

* `config.active_record.logger` принимает логгер, соответствующий интерфейсу Log4r или дефолтного класса Ruby 1.8.x Logger, который затем передается на любые новые сделанные соединения с базой данных. Можете получить этот логгер, вызвав `logger` или на любом классе модели ActiveRecord, или на экземпляре модели ActiveRecord. Установите его в nil, чтобы отключить логирование.

* `config.active_record.primary_key_prefix_type` позволяет настроить именование столбцов первичного ключа. По умолчанию Rails полагает, что столбцы первичного ключа именуются `id` (и эта конфигурационная опция не нуждается в установке). Есть два возможных варианта:
** `:table_name` сделает первичный ключ для класса Customer как `customerid`
** `:table_name_with_underscore` сделает первичный ключ для класса Customer как `customer_id`

* `config.active_record.table_name_prefix` позволяет установить глобальную строку, добавляемую в начало имен таблиц. Если установить ее равным `northwest_`, то класс Customer будет искать таблицу `northwest_customers`. По умолчанию это пустая строка.

* `config.active_record.table_name_suffix` позволяет установить глобальную строку, добавляемую в конец имен таблиц. Если установить ее равным `_northwest`, то класс Customer будет искать таблицу `customers_northwest`. По умолчанию это пустая строка.

* `config.active_record.pluralize_table_names` определяет, должен Rails искать имена таблиц базы данных в единственном или множественном числе. Если установлено `true` (по умолчанию), то класс Customer будет использовать таблицу `customers`. Если установить `false`, то класс Customers будет использовать таблицу `customer`.

* `config.active_record.default_timezone` определяет, использовать `Time.local` (если установлено `:local`) или `Time.utc` (если установлено `:utc`) для считывания даты и времени из базы данных. По умолчанию `:local`.

* `config.active_record.schema_format` регулирует формат для выгрузки схемы базы данных в файл. Опции следующие: `:ruby` (по умолчанию) для независимой от типа базы данных версии, зависимой от миграций, или `:sql` для набора (потенциально зависимого от типа БД) выражений SQL.

* `config.active_record.timestamped_migrations` регулирует, должны ли миграции нумероваться серийными номерами или временными метками. По умолчанию `true` для использования временных меток, которые более предпочтительны если над одним проектом работают несколько разработчиков.

* `config.active_record.lock_optimistically` регулирует, должен ли ActiveRecord использовать оптимистичную блокировку. По умолчанию `true`.

* `config.active_record.auto_explain_threshold_in_seconds` настраивает порог для автоматических EXPLAIN (`nil` отключает эту возможность). Запросы, превышающие порог, получат залогированным из план запроса. По умолчанию 0.5 в режиме development.

* +config.active_record.cache_timestamp_format+ управляет форматом значения временной метки в ключе кэширования. По умолчанию +:number+.

Адаптер MySQL добавляет дополнительную конфигурационную опцию:

* `ActiveRecord::ConnectionAdapters::MysqlAdapter.emulate_booleans` регулирует, должен ли ActiveRecord рассматривать все столбцы `tinyint(1)` в базе данных MySQL как boolean. По умолчанию `true`.

Дампер схемы добавляет дополнительную конфигурационную опцию:

* `ActiveRecord::SchemaDumper.ignore_tables` принимает массив таблиц, которые _не_ должны быть включены в любой создаваемый файл схемы. Эта настройка будет проигнорирована в любом случае, кроме `ActiveRecord::Base.schema_format == :ruby`.

### Конфигурирование Action Controller

`config.action_controller` включает несколько конфигурационных настроек:

* `config.action_controller.asset_host` устанавливает хост для ресурсов. Полезна, когда для хостинга ресурсов используются CDN, или когда вы хотите обойти встроенную в браузеры политику ограничения домена при использовании различных псевдонимов доменов.

* `config.action_controller.perform_caching` конфигурирует, должно ли приложение выполнять кэширование. Установлено false в режиме development, true в production.

* `config.action_controller.default_static_extension` конфигурирует расширение, используемое для кэшированных страниц. По умолчанию `.html`.

* `config.action_controller.default_charset` определяет кодировку по умолчанию для всех рендеров. По умолчанию "utf-8".

* `config.action_controller.logger` принимает логгер, соответствующий интерфейсу Log4r или дефолтного класса Ruby Logger, который затем используется для логирования информации от Action Controller. Установите его в nil, чтобы отключить логирование.

* `config.action_controller.request_forgery_protection_token` устанавливает имя параметра токена для RequestForgery. Вызов `protect_from_forgery` по умолчанию устанавливает его в `:authenticity_token`.

* `config.action_controller.allow_forgery_protection` включает или отключает защиту от CSRF. По умолчанию `false` в режиме тестирования и `true` в остальных режимах.

* `relative_url_root` может использоваться, что бы сообщить Rails, что вы развертываетеся в субдиректории. По умолчанию `ENV['RAILS_RELATIVE_URL_ROOT']`.

* `config.action_controller.permit_all_parameters` устанавливает все параметры для массового назначения как разрешенные по умолчанию. Значение по умолчанию `false`.

* `config.action_controller.raise_on_unpermitted_parameters` включает вызов исключения, если обнаружены параметры, которые не разрешены явно. Значение по умолчанию `true` в средах development и test, в противном случае `false`.

### Конфигурирование Action Dispatch

* `config.action_dispatch.session_store` устанавливает имя хранилища данных сессии. По умолчанию `:cookie_store`; другие валидные опции включают `:active_record_store`, `:mem_cache_store` или имя вашего собственного класса.

* `config.action_dispatch.default_headers` это хэш с заголовками HTTP, которые по умолчанию устанавливаются для каждого отклика. По умолчанию определены как:

    ```ruby
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-XSS-Protection' => '1; mode=block',
      'X-Content-Type-Options' => 'nosniff'
    }
    ```

* `config.action_dispatch.tld_length` устанавливает длину TLD (домена верхнего уровня) для приложения. По умолчанию `1`.

* `ActionDispatch::Callbacks.before` принимает блок кода для запуска до запроса.

* `ActionDispatch::Callbacks.to_prepare` принимает блок для запуска после `ActionDispatch::Callbacks.before`, но до запроса. Запускается для каждого запроса в режиме `development`, но лишь единожды в `production` или режиме с `cache_classes`, установленной `true`.

* `ActionDispatch::Callbacks.after` принимает блок кода для запуска после запроса.

### Конфигурирование Action View

`config.action_view` включает несколько конфигурационных настроек:

* `config.action_view.field_error_proc` предоставляет генератор HTML для отображения ошибок, приходящих от Active Record. По умолчанию:

    ```ruby
    Proc.new { |html_tag, instance| %Q(<div class="field_with_errors">#{html_tag}</div>).html_safe }
    ```

* `config.action_view.default_form_builder` говорит Rails, какой form builder использовать по умолчанию. По умолчанию это `ActionView::Helpers::FormBuilder`. Если хотите, чтобы после инициализации загружался ваш класс form builder (и, таким образом, перезагружался с каждым запросом в development), можно передать его как строку.

* `config.action_view.logger` принимает логгер, соответствующий интерфейсу Log4r или классу Ruby по умолчанию Logger, который затем используется для логирования информации от Action Mailer. Установите `nil` для отключения логирования.

* `config.action_view.erb_trim_mode` задает режим обрезки, который будет использоваться ERB. По умолчанию `'-'`. Подробнее смотрите в [документации по ERB](http://www.ruby-doc.org/stdlib/libdoc/erb/rdoc/).

* `config.action_view.javascript_expansions` это хэш, содержащий расширения, используемые для тега включения JavaScript. По умолчанию это определено так:

    ```ruby
    config.action_view.javascript_expansions = { :defaults => %w(jquery jquery_ujs) }
    ```

    Однако, можно добавить к нему, чтобы определить что-то другое:

    ```ruby
    config.action_view.javascript_expansions[:prototype] = ['prototype', 'effects', 'dragdrop', 'controls']
    ```

    И обратиться во вьюхе с помощью следующего кода:

    ```ruby
    <%= javascript_include_tag :prototype %>
    ```

* `config.action_view.stylesheet_expansions` работает так же, как и `javascript_expansions`, но у него нет ключа default По ключам, определенным для этого хэша, можно обращаться во вьюхах так:

    ```ruby
    <%= stylesheet_link_tag :special %>
    ```

* `config.action_view.cache_asset_ids` Со включенным кэшем хелпер тегов ресурсов будет меньше нагружать файловую систему (реализация по умолчанию проверяет временную метку файловой системы). Однако, это препятствует модификации любого файла ресурса, пока сервер запущен.

* `config.action_view.embed_authenticity_token_in_remote_forms` позволяет установить поведение по умолчанию для `authenticity_token` в формах с `:remote => true`. По умолчанию установлен false, что означает, что remote формы не включают `authenticity_token`, что полезно при фрагментарном кэшировании формы. Remote формы получают аутентификацию из тега `meta`, поэтому встраивание бесполезно, если, конечно, вы не поддерживаете браузеры без JavaScript. В противном случае можно либо передать `:authenticity_token => true` как опцию для формы, либо установить эту настройку в `true`

* `config.action_view.prefix_partial_path_with_controller_namespace` определяет должны ли партиалы искаться в поддиректории шаблонов для контроллеров в пространсве имен, или нет. Например, рассмотрим контроллер с именем `Admin::PostsController`, который рендерит этот шаблон:

    ```erb
    <%= render @post %>
    ```

Настройка по умолчанию `true`, что использует партиал в `/admin/posts/_post.erb`. Установка значение в `false` будет рендерить `/posts/_post.erb`, что является тем же поведением, что и рендеринг из контроллера не в пространстве имен, такого как `PostsController`.

### Конфигурирование Action Mailer

Имеется несколько доступных настроек `ActionMailer::Base`:

* `config.action_mailer.logger` принимает логгер, соответствующий интерфейсу Log4r или класса Ruby по умолчанию Logger, который затем используется для логирования информации от Action Mailer. Установите его в nil, чтобы отключить логирование.

* `config.action_mailer.smtp_settings` позволяет детально сконфигурировать метод доставки <tt>:smtp</tt>. Она принимает хэш опций, который может включать любые из следующих:
    * `:address` - Позволяет использовать удаленный почтовый сервер. Просто измените его значение по умолчанию "localhost".
    * `:port` -  В случае, если ваш почтовый сервер не работает с портом 25, можете изменить это.
    * `:domain` - Если нужно определить домен HELO, это делается здесь.
    * `:user_name` - Если почтовый сервер требует аутентификацию, установите имя пользователя этой настройкой.
    * `:password` - Если почтовый сервер требует аутентификацию, установите пароль этой настройкой.
    * `:authentication` - Если почтовый сервер требует аутентификацию, здесь необходимо установить тип аутентификации. Это должен быть один из символов `:plain`, `:login`, `:cram_md5`.

* `config.action_mailer.sendmail_settings` Позволяет детально сконфигурировать метод доставки `sendmail`. Она принимает хэш опций, который может включать любые из этих опций:
    * `:location` - Размещение исполняемого файла sendmail. По умолчанию `/usr/sbin/sendmail`.
    * `:arguments` - Аргументы командной строки. По умолчанию `-i -t`.

* `config.action_mailer.raise_delivery_errors` определяет, должна ли вызываться ошибка, если доставка письма не может быть завершена. По умолчанию `true`.

* `config.action_mailer.delivery_method` определяет метод доставки. Допустимыми значениями являются `:smtp` (по умолчанию), `:sendmail` и `:test`.

* `config.action_mailer.perform_deliveries` определяет, должна ли почта фактически доставляться. По умолчанию `true`; удобно установить ее `false` при тестировании.

* `config.action_mailer.default_options` конфигурирует значения по умолчанию Action Mailer. Используется для установки таких опций, как `from` или`reply_to` для каждого рассыльщика. Эти значения по умолчанию следующие:

    ```ruby
    :mime_version => "1.0",
    :charset      => "UTF-8",
    :content_type => "text/plain",
    :parts_order  => [ "text/plain", "text/enriched", "text/html" ]
    ```

* `config.action_mailer.observers` регистрирует обсерверы, которые будут уведомлены при доставке почты.

    ```ruby
    config.action_mailer.observers = ["MailObserver"]
    ```

* `config.action_mailer.interceptors` регистрирует перехватчики, которые будут вызваны до того, как почта будет отослана.

    ```ruby
    config.action_mailer.interceptors = ["MailInterceptor"]
    ```

### Конфигурирование Active Support

Имеется несколько конфигурационных настроек для Active Support:

* `config.active_support.bare` включает или отключает загрузку `active_support/all` при загрузке Rails. По умолчанию `nil`, что означает, что `active_support/all` загружается.

* `config.active_support.escape_html_entities_in_json` включает или отключает экранирование сущностей HTML в сериализации JSON. По умолчанию `false`.

* `config.active_support.use_standard_json_time_format` включает или отключает сериализацию дат в формат ISO 8601. По умолчанию `true`.

* `ActiveSupport::Logger.silencer` устанавливают `false`, чтобы отключить возможность silence logging в блоке. По умолчанию `true`.

* `ActiveSupport::Cache::Store.logger` определяет логгер, используемый в операциях хранения кэша.

* `ActiveSupport::Deprecation.behavior` альтернативный сеттер для `config.active_support.deprecation`, конфигурирующий поведение предупреждений об устаревании в Rails.

* `ActiveSupport::Deprecation.silence` принимает блок, в котором все предупреждения об устаревании умалчиваются.

* `ActiveSupport::Deprecation.silenced` устанавливает, отображать ли предупреждения об устаревании.

* `ActiveSupport::Logger.silencer` устанавливают `false`, чтобы отключить возможность silence logging в блоке. По умолчанию `true`.

### Конфигурирование базы данных

Почти каждое приложение на Rails взаимодействует с базой данных. Какую базу данных использовать, определяется в конфигурационном файле `config/database.yml`. Если вы откроете этот файл в новом приложении на Rails, то увидите базу данных по умолчанию, настроенную на использование SQLite3. По умолчанию, файл содержит разделы для трех различных сред, в которых может быть запущен Rails:

* Среда `development` используется на вашем рабочем/локальном компьютере для того, чтобы вы могли взаимодействовать с приложением.
* Среда `test` используется при запуске автоматических тестов.
* Среда `production` используется, когда вы развертываете свое приложения во всемирной сети для использования.

TIP: Вам не нужно обновлять конфигурации баз данных вручную. Если взглянете на опции генератора приложения, то увидите, что одна из опций называется `--database`. Эта опция позволяет выбрать адаптер из списка наиболее часто используемых реляционных баз данных. Можно даже запускать генератор неоднократно: `cd .. && rails new blog —database=mysql`. После того, как подтвердите перезапись `config/database.yml`, ваше приложение станет использовать MySQL вместо SQLite. Подробные примеры распространенных соединений с базой данных указаны ниже.

#### Конфигурирование базы данных SQLite3

В Rails есть встроенная поддержка [SQLite3](http://www.sqlite.org), являющейся легким несерверным приложением по управлению базами данных. Хотя нагруженная среда production может перегрузить SQLite, она хорошо работает для разработки и тестирования. Rails при создании нового проекта использует базу данных SQLite, но Вы всегда можете изменить это позже.

Вот раздел дефолтного конфигурационного файла (`config/database.yml`) с информацией о соединении для среды development:

```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
  pool: 5
  timeout: 5000
```

NOTE: В этом руководстве мы используем базу данных SQLite3 для хранения данных, поскольку эта база данных работает с нулевыми настройками. Rails также поддерживает MySQL и PostgreSQL "из коробки", и имеет плагины для многих СУБД. Если вы уже используете базу данных в работе, в Rails скорее всего есть адаптер для нее.

#### Конфигурирование базы данных MySQL

Если Вы выбрали MySQL вместо SQLite3, ваш `config/database.yml` будет выглядеть немного по другому. Вот секция development:

```yaml
development:
  adapter: mysql2
  encoding: utf8
  database: blog_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
```

Если на вашем компьютере установленная MySQL имеет пользователя root с пустым паролем, эта конфигурация у вас заработает. В противном случае измените username и password в разделе `development` на правильные.

#### Конфигурирование базы данных PostgreSQL

Если Вы выбрали PostgreSQL, ваш `config/database.yml` будет модифицирован для использования базы данных PostgreSQL:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: blog_development
  pool: 5
  username: blog
  password:
```

Можно отключить Prepared Statements следующим образом:

```yaml
production:
  adapter: postgresql
  prepared_statements: false
```

#### Конфигурирование базы данных SQLite3 для платформы JRuby

Если вы выбрали SQLite3 и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот секция development:

```yaml
development:
  adapter: jdbcsqlite3
  database: db/development.sqlite3
```

#### Конфигурирование базы данных MySQL для платформы JRuby

Если вы выбрали MySQL и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот секция development:

```yaml
development:
  adapter: jdbcmysql
  database: blog_development
  username: root
  password:
```

#### Конфигурирование базы данных PostgreSQL для платформы JRuby

Наконец, если вы выбрали PostgreSQL и используете JRuby, ваш `config/database.yml` будет выглядеть немного по-другому. Вот секция development:

```yaml
development:
  adapter: jdbcpostgresql
  encoding: unicode
  database: blog_development
  username: blog
  password:
```

Измените username и password в секции `development` на правильные.
