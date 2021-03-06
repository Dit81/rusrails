# Rake

Rake означает Ruby Make, отдельная утилита Ruby, заменяющая утилиту Unix "make", и использующая файлы "Rakefile" и `.rake` для построения списка задач. В Rails Rake используется для обычных административных задач, особенно таких, которые зависят друг от друга.

Можно получить список доступных задач Rake, который часто зависит от вашей текущей директории, написав `rake --tasks`. У кажой задачи есть описание, помогающее найти то, что вам необходимо.

```bash
$ rake --tasks
rake about              # List versions of all Rails frameworks and the environment
rake assets:clean       # Remove compiled assets
rake assets:precompile  # Compile all the assets named in config.assets.precompile
rake db:create          # Create the database from config/database.yml for the current Rails.env
...
rake log:clear          # Truncates all *.log files in log/ to zero bytes
rake middleware         # Prints out your Rack middleware stack
...
rake tmp:clear          # Clear session, cache, and socket files from tmp/ (narrow w/ tmp:sessions:clear, tmp:cache:clear, tmp:sockets:clear)
rake tmp:create         # Creates tmp directories for sessions, cache, sockets, and pids
```

### `about`

`rake about` предоставляет информацию о номерах версий Ruby, RubyGems, Rails, подкомпонентов Rails, папке вашего приложения, имени текущей среды Rails, адаптере базы данных вашего приложения и версии схемы. Это полезно, когда нужно попросить помощь, проверить патч безопасности, который может повлиять на вас, или просто хотите узнать статистику о текущей инсталляции Rails.

```bash
$ rake about
About your application's environment
Ruby version              1.9.3 (x86_64-linux)
RubyGems version          1.3.6
Rack version              1.3
Rails version             4.0.0.beta
JavaScript Runtime        Node.js (V8)
Active Record version     4.0.0.beta
Action Pack version       4.0.0.beta
Action Mailer version     4.0.0.beta
Active Support version    4.0.0.beta
Middleware                ActionDispatch::Static, Rack::Lock, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions, ActionDispatch::RemoteIp, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActiveRecord::ConnectionAdapters::ConnectionManagement, ActiveRecord::QueryCache, ActionDispatch::Cookies, ActionDispatch::Session::EncryptedCookieStore, ActionDispatch::Flash, ActionDispatch::ParamsParser, Rack::Head, Rack::ConditionalGet, Rack::ETag, ActionDispatch::BestStandardsSupport
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20110805173523
```

### `assets`

Можно предварительно компилировать ресурсы (ассеты) в `app/assets`, используя `rake assets:precompile`, и удалять эти скомпилированные ресурсы, используя `rake assets:clean`.

### `db`

Самыми распространенными задачами пространства имен Rake `db:` являются `migrate` и `create`, но следует попробовать и остальные миграционные задачи rake (`up`, `down`, `redo`, `reset`). `rake db:version` полезна для решения проблем, показывая текущую версию базы данных.

Более подробно о миграциях написано в руководстве [Миграции](/rails-database-migrations).

### `doc`

В пространстве имен `doc:` имеются инструменты для создания документации для вашего приложения, документации API, руководств. Документация также может вырезаться, что полезно для сокращения вашего кода, если вы пишите приложения Rails для встраимовой платформы.

* `rake doc:app` создает документацию для вашего приложения в `doc/app`.
* `rake doc:guides` создает руководства Rails в `doc/guides`.
* `rake doc:rails` создает документацию по API Rails в `doc/api`.

### `notes`

`rake notes` ищет в вашем коде комментарии, начинающиеся с FIXME, OPTIMIZE или TODO. Поиск выполняется в файлах с разрешениями `.builder`, `.rb`, `.erb`, `.haml` и `.slim` для аннотаций как по умолчанию, так и произвольных.

```bash
$ rake notes
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/model/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

Если ищете определенную аннотацию, скажем FIXME, используйте `rake notes:fixme`. Отметьте, что имя аннотации использовано в нижнем регистре.

```bash
$ rake notes:fixme
(in /home/foobar/commandsapp)
app/controllers/admin/users_controller.rb:
  * [132] high priority for next deploy

app/model/school.rb:
  * [ 17]
```

Также можно использовать произвольные аннотации в своем коде и выводить их, используя `rake notes:custom`, определив аннотацию, используя переменную среды `ANNOTATION`.

```bash
$ rake notes:custom ANNOTATION=BUG
(in /home/foobar/commandsapp)
app/model/post.rb:
  * [ 23] Have to fix this one before pushing!
```

NOTE. При использовании определенных и произвольных аннотаций, имя аннотации (FIXME, BUG и т.д.) не отображается в строках результата.

По умолчанию `rake notes` будет искать в директориях `app`, `config`, `lib`, `script` и `test`. Если желаете искать в иных директориях, можно их предоставить как разделенный запятыми список в переменную среды `SOURCE_ANNOTATION_DIRECTORIES`.

```bash
$ export SOURCE_ANNOTATION_DIRECTORIES='rspec,vendor'
$ rake notes
(in /home/foobar/commandsapp)
app/model/user.rb:
  * [ 35] [FIXME] User should have a subscription at this point
rspec/model/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works
```

### `routes`

`rake routes` отобразит список всех определенных маршрутов, что полезно для отслеживания проблем с роутингом в вашем приложении, или предоставления хорошего обзора URL приложения, с которым вы пытаетесь ознакомиться.

### `test`

INFO: Хорошее описание юнит-тестирования в Rails дано в [Руководстве по тестированию приложений на Rails](/a-guide-to-testing-rails-applications)

Rails поставляется с набором тестов по имени `Test::Unit`. Rails сохраняет стабильность в связи с использованием тестов. Задачи, доступные в пространстве имен `test:` помогает с запуском различных тестов, которые вы, несомненно, напишите.

### `tmp`

Директория `Rails.root/tmp` является, как любая *nix директория /tmp, местом для временных файлов, таких как сессии (если вы используете файловое хранение), файлы id процессов и кэшированные экшны.

Задачи пространства имен `tmp:` поможет очистить директорию `Rails.root/tmp`:

* `rake tmp:cache:clear` очистит <tt>tmp/cache</tt>.
* `rake tmp:sessions:clear` очистит <tt>tmp/sessions</tt>.
* `rake tmp:sockets:clear` очистит <tt>tmp/sockets</tt>.
* `rake tmp:clear` очистит все три: кэша, сессий и сокетов.

### Прочее

* `rake stats` великолепно для обзора статистики вашего кода, отображает такие вещи, как KLOCs (тысячи строк кода) и ваш код для тестирования показателей.
* `rake secret` даст псевдо-случайный ключ для использования в качестве секретного ключа сессии.
* `rake time:zones:all` перечислит все временные зоны, о которых знает Rails.

### Пользовательские таски Rake

Пользовательские таски rake имеют расширение `.rake` и располагаются в`Rails.root/lib/tasks`.

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # Вся магия тут
  # Разрешен любой код Ruby
end
```

Чтобы передать аргументы в ваш таск rake:

```ruby
task :task_name, [:arg_1] => [:pre_1, :pre_2] do |t, args|
  # Здесь можно использовать args
end
```

Таски можно группировать, помещая их в пространства имен:

```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Серьезно, ничего
  end
end
```

Вызов тасков выглядит так:

```bash
rake task_name
rake "task_name[value 1]" # entire argument string should be quoted
rake db:nothing
```

NOTE: Если необходимо взаимодействовать с моделями приложения, выполнять запросы в базу данных и так далее, ваш таск должен зависеть от таска `environment`, который загрузит код вашего приложения.
