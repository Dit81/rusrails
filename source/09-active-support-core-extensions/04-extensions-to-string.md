# Расширения для String

### Безопасность вывода

#### Мотивация

Вставка данных в шаблоны HTML требует дополнительной заботы. Например, нельзя просто вставить `@review.title` на страницу HTML. С одной стороны, если заголовок рецензии "Flanagan & Matz rules!" результат не будет правильным, поскольку амперсанд был экранирован как "&amp;amp;". К тому же, в зависимости от вашего приложения может быть большая дыра в безопасности, поскольку пользователи могут внедрить злонамеренный HTML, устанавливающий специально изготовленный заголовок рецензии. Посмотрите подробную информацию о рисках в [раздел о межсайтовом скриптинге в Руководстве по безопасности](/ruby-on-rails-security-guide/injection#cross-site-scripting-xss).

#### Безопасные строки

В Active Support есть концепция <i>(html) безопасных</i> строк. Безопасная строка - это та, которая помечена как подлежащая вставке в HTML как есть. Ей доверяется, независимо от того, была она экранирована или нет.

Строки рассматриваются как <i>небезопасные</i> по умолчанию:

```ruby
"".html_safe? # => false
```

Можно получить безопасную строку из заданной с помощью метода `html_safe`:

```ruby
s = "".html_safe
s.html_safe? # => true
```

Важно понять, что `html_safe` не выполняет какого бы то не было экранирования, это всего лишь утверждение:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

Вы ответственны за обеспечение вызова `html_safe` на подходящей строке.

При присоединении к безопасной строке или с помощью `concat`/`<<`, или с помощью `+`, результат будет безопасной строкой. Небезопасные аргументы экранируются:

```ruby
"".html_safe + "<" # => "&lt;"
```

Безопасные аргументы непосредственно присоединяются:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Эти методы не должны использоваться в обычных вьюхах. Небезопасные значения автоматически экранируются:

```erb
<%= @review.title %> <%# прекрасно, экранируется, если нужно %>
```

Чтобы вставить что-либо дословно, используйте хелпер `raw` вместо вызова `html_safe`:

```erb
<%= raw @cms.current_template %> <%# вставляет @cms.current_template как есть %>
```

или эквивалентно используйте `<%==`:

```erb
<%== @cms.current_template %> <%# вставляет @cms.current_template как есть %>
```

Хелпер `raw` вызывает за вас хелпер `html_safe`:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE: Определено в `active_support/core_ext/string/output_safety.rb`.

#### Преобразование

Как правило, за исключением разве что соединения, объясненного выше, любой метод, который может изменить строку, даст вам небезопасную строку. Это `donwcase`, `gsub`, `strip`, `chomp`, `underscore` и т.д.

В случае встроенного преобразования, такого как `gsub!`, получатель сам становится небезопасным.

INFO: Бит безопасности всегда теряется, независимо от того, изменило ли что-то преобразование или нет.

#### Конверсия и принуждение

Вызов `to_s` на безопасной строке возвратит безопасную строку, но принуждение с помощью `to_str` возвратит небезопасную строку.

#### Копирование

Вызов `dup` или `clone` на безопасной строке создаст безопасные строки.

### `squish`

Метод `String#squish` отсекает начальные и конечные пробелы и заменяет каждый ряд пробелов единственным пробелом:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Также имеется разрушительная версия `String#squish!`.

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### `truncate`

Метод `truncate` возвращает копию получателя, сокращенную после заданной `длины`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

Многоточие может быть настроено с помощью опции `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Отметьте, что сокращение берет в счет длину строки omission.

Передайте `:separator` для сокращения строки по естественным разрывам:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

Опция `:separator` может быть регулярным выражением:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

В вышеуказанных примерах "dear" обрезается сначала, а затем `:separator` предотвращает это.

NOTE: Определено в `active_support/core_ext/string/filters.rb`.

### `inquiry`

Метод `inquiry` конвертирует строку в объект `StringInquirer`, позволяя красивые проверки.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

### `starts_with?` и `ends_with?`

Active Support определяет псевдонимы `String#start_with?` и `String#end_with?` (в связи с особенностями английской морфологии, изменяет глаголы в форму 3 лица):

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE: Определены в `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

Метод `strip_heredoc` обрезает отступы в heredoc-ах.

Для примера в

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

пользователь увидит используемое сообщение, выровненное по левому краю.

Технически это выглядит как выделение красной строки в отдельную строку и удаление всех впереди идущих пробелов.

NOTE: Определено в `active_support/core_ext/string/strip.rb`.

### `indent`

Устанавливает отступы строчкам получателя:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

Второй аргумент, `indent_string`, определяет, какую строку использовать для отступа. По умолчанию `nil`, что сообщает методу самому догадаться на основе первой строчки с отступом, а если такой нет, то использовать пробел.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Хотя `indent_string` обычно один пробел или табуляция, он может быть любой строкой.

Третий аргумент, `indent_empty_lines`, это флажок, указывающий, должен ли быть отступ для пустых строчек. По умолчанию false.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

Метод `indent!` делает отступы в той же строке.

### Доступ

#### `at(position)`

Возвращает символ строки на позиции `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `from(position)`

Возвращает подстроку строки, начинающуюся с позиции `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => "" если < 1.9, nil в 1.9
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `to(position)`

Возвращает подстроку строки с начала до позиции `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `first(limit = 1)`

Вызов `str.first(n)` эквивалентен `str.to(n-1)`, если `n` > 0, и возвращает пустую строку для `n` == 0.

NOTE: Определено в `active_support/core_ext/string/access.rb`.

#### `last(limit = 1)`

Вызов `str.last(n)` эквивалентен `str.from(-n)`, если `n` > 0, и возвращает пустую строку для `n` == 0.

NOTE: Определено в `active_support/core_ext/string/access.rb`.

### Изменения слов

#### `pluralize`

Метод `pluralize` возвращает множественное число его получателя:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Как показывает предыдущий пример, Active Support знает некоторые неправильные множественные числа и неисчислимые существительные. Встроенные правила могут быть расширены в `config/initializers/inflections.rb`. Этот файл создается командой `rails` и имеет инструкции в комментариях.

`pluralize` также может принимать опциональный параметр `count`. Если `count == 1`, будет возвращена единственная форма. Для остальных значений `count` будет возвращена множественная форма:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record использует этот метод для вычисления имени таблицы по умолчанию, соответствующей модели:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(class_name = base_class.name)
  table_name = class_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `singularize`

Противоположность `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

Связи вычисляют имя соответствующего связанного класса по умолчанию используя этот метод:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `camelize`

Метод `camelize` возвращает его получателя в стиле CamelCase:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Как правило, об этом методе думают, как о преобразующем пути в классы Ruby или имена модулей, где слэши разделяют пространства имен:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Например, Action Pack использует этот метод для загрузки класса, предоставляющего определенное хранилище сессии:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` принимает необязательный аргумент, он может быть `:upper` (по умолчанию) или `:lower`. С последним первая буква остается прописной:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Это удобно для вычисления имен методов в языке, следующем такому соглашению, например JavaScript.

INFO: Как правило можно рассматривать `camelize` как противоположность `underscore`, хотя имеются случаи, когда это не так: `"SSLError".underscore.camelize` возвратит `"SslError"`. Для поддержки случаев, подобного этому, Active Support предлагает определить акронимы в `config/initializers/inflections.rb`

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize #=> "SSLError"
```

`camelize` имеет псевдоним `camelcase`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `underscore`

Метод `underscore` идет обратным путем, от CamelCase к путям:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Также преобразует "::" обратно в "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

и понимает строки, начинающиеся с прописной буквы:

```ruby
"visualEffect".underscore # => "visual_effect"
```

хотя `underscore` не принимает никакие аргументы.

Автозагрузка классов и модулей Rails использует `underscore` для вывода относительного пути без расширения файла, определяющего заданную отсутствующую константу:

```ruby
# active_support/dependencies.rb
def load_missing_constant(from_mod, const_name)
  ...
  qualified_name = qualified_name_for from_mod, const_name
  path_suffix = qualified_name.underscore
  ...
end
```

INFO: Как правило, рассматривайте `underscore` как противоположность `camelize`, хотя имеются случаи, когда это не так. Например, `"SSLError".underscore.camelize` возвратит `"SslError"`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `titleize`

Метод `titleize` озаглавит слова в получателе:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` имеет псевдоним `titlecase`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `dasherize`

Метод `dasherize` заменяет подчеркивания в получателе дефисами:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

Сериализатор XML моделей использует этот метод для форматирования имен узлов:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `demodulize`

Для заданной строки с полным именем константы, `demodulize` возвращает само имя константы, то есть правой части этого:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
```

Active Record к примеру, использует этот метод для вычисления имени столбца кэширования счетчика:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `deconstantize`

У заданной строки с полным выражением ссылки на константу `deconstantize` убирает самый правый сегмент, в основном оставляя имя контейнера константы:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

Например, Active Support использует этот метод в `Module#qualified_const_set`:

```ruby
def qualified_const_set(path, value)
  QualifiedConstUtils.raise_if_absolute(path)

  const_name = path.demodulize
  mod_name = path.deconstantize
  mod = mod_name.empty? ? self : qualified_const_get(mod_name)
  mod.const_set(const_name, value)
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `parameterize`

Метод `parameterize` нормализует получателя способом, который может использоваться в красивых URL.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Фактически результирующая строка оборачивается в экземпляр `ActiveSupport::Multibyte::Chars`.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `tableize`

Метод `tableize` - это `underscore` следующий за `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

Как правило, `tableize` возвращает имя таблицы, соответствующей заданной модели для простых случаев. В действительности фактическое применение в Active Record не является прямым `tableize`, так как он также демодулизирует имя класса и проверяет несколько опций, которые могут повлиять на возвращаемую строку.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `classify`

Метод `classify` является противоположностью `tableize`. Он выдает имя класса, соответствующего имени таблицы:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

Метод понимает правильные имена таблицы:

```ruby
"highrise_production.companies".classify # => "Company"
```

Отметьте, что `classify` возвращает имя класса как строку. Можете получить фактический объект класса, вызвав `constantize` на ней, как объяснено далее.

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `constantize`

Метод `constantize` решает выражение, ссылающееся на константу, в его получателе:

```ruby
"Fixnum".constantize # => Fixnum

module M
  X = 1
end
"M::X".constantize # => 1
```

Если строка определяет неизвестную константу, или ее содержимое даже не является валидным именем константы, `constantize` вызывает `NameError`.

Анализ имени константы с помощью `constantize` начинается всегда с верхнего уровня `Object`, даже если нет предшествующих "::".

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

Таким образом, в общем случае это не эквивалентно тому, что Ruby сделал бы в том же месте, когда вычислял настоящую константу.

Тестовые случаи рассыльщика получают тестируемый рассыльщик из имени класса теста, используя `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.sub(/Test$/, '').constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `humanize`

Метод `humanize` дает осмысленное имя для отображения имени атрибута. Для этого он заменяет подчеркивания пробелами, убирает любой суффикс "_id" и озаглавливает первое слово:

```ruby
"name".humanize           # => "Name"
"author_id".humanize      # => "Author"
"comments_count".humanize # => "Comments count"
```

Метод хелпера `full_messages` использует `humanize` как резервный способ для включения имен атрибутов:

```ruby
def full_messages
  full_messages = []

  each do |attribute, messages|
    ...
    attr_name = attribute.to_s.gsub('.', '_').humanize
    attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
    ...
  end

  full_messages
end
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

#### `foreign_key`

Метод `foreign_key` дает имя столбца внешнего ключа из имени класса. Для этого он демодулизирует, подчеркивает и добавляет "_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

Передайте аргуемент false, если не хотите подчеркивание в "_id":

```ruby
"User".foreign_key(false) # => "userid"
```

Связи используют этот метод для вывода внешних ключей, например `has_one` и `has_many` делают так:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: Определено в `active_support/core_ext/string/inflections.rb`.

### Конвертирование

#### `to_date`, `to_time`, `to_datetime`

Методы `to_date`, `to_time` и `to_datetime` - в основном удобные обертки около `Date._parse`:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => Tue Jul 27 23:37:00 UTC 2010
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 `0000
```

`to_time` получает необязательный аргумент `:utc` или `:local`, для указания, в какой временной зоне вы хотите время:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => Tue Jul 27 23:42:00 UTC 2010
"2010-07-27 23:42:00".to_time(:local) # => Tue Jul 27 23:42:00 `0200 2010
```

По умолчанию `:utc`.

Пожалуйста, обратитесь к документации по `Date._parse` для детальных подробностей.

INFO: Все три возвратят `nil` для пустых получателей.

NOTE: Определено в `active_support/core_ext/string/conversions.rb`.
