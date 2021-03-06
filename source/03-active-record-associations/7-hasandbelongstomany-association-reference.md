# Подробная информация по связи has_and_belongs_to_many

Связь `has_and_belongs_to_many` создает отношение один-ко-многим с другой моделью. В терминах базы данных это связывает два класса через промежуточную соединительную таблицу, которая включает внешние ключи, относящиеся к каждому классу.

### Добавляемые методы

Когда объявляете связь `has_and_belongs_to_many`, объявляющий класс автоматически получает 14 методов, относящихся к связи:

* `collection(force_reload = false)`
* `collection<<(object, ...)`
* `collection.delete(object, ...)`
* `collection.destroy(object, ...)`
* `collection=objects`
* `collection_singular_ids`
* `collection_singular_ids=ids`
* `collection.clear`
* `collection.empty?`
* `collection.size`
* `collection.find(...)`
* `collection.where(...)`
* `collection.exists?(...)`
* `collection.build(attributes = {})`
* `collection.create(attributes = {})`

Во всех этих методах `collection` заменяется символом, переданным как первый аргумент в `has_and_belongs_to_many`, а `collection_singular` заменяется версией в единственном числе этого символа. Например, имеем объявление:

```ruby
class Part < ActiveRecord::Base
  has_and_belongs_to_many :assemblies
end
```

Каждый экземпляр модели part будет иметь эти методы:

```ruby
assemblies(force_reload = false)
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=objects
assembly_ids
assembly_ids=ids
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
```

#### Дополнительные методы столбцов

Если соединительная таблица для связи `has_and_belongs_to_many` имеет дополнительные столбцы, кроме двух внешних ключей, эти столбцы будут добавлены как атрибуты к записям, получаемым посредством связи. Записи, возвращаемые с дополнительными атрибутами, будут всегда только для чтения, поскольку Rails не может сохранить значения этих атрибутов.

WARNING: Использование дополнительных атрибутов в соединительной таблице в связи has_and_belongs_to_many устарело. Если требуется этот тип сложного поведения таблицы, соединяющей две модели в отношениях многие-ко-многим, следует использовать связь `has_many :through` вместо `has_and_belongs_to_many`.

#### `collection(force_reload = false)`

Метод `collection` возвращает массив всех связанных объектов. Если нет связанных объектов, он возвращает пустой массив.

```ruby
@assemblies = @part.assemblies
```

#### `collection<<(object, ...)`

Метод `collection&lt;&lt;` добавляет один или более объектов в коллекцию, создавая записи в соединительной таблице.

```ruby
@part.assemblies << @assembly1
```

NOTE: Этот метод - просто синоним к `collection.concat` и `collection.push`.

#### `collection.delete(object, ...)`

Метод `collection.delete` убирает один или более объектов из коллекции, удаляя записи в соединительной таблице. Это не уничтожает объекты.

```ruby
@part.assemblies.delete(@assembly1)
```

WARNING: Это не запустит колбэки на соединительных записях.

##### `collection.destroy(object, ...)`

Метод `collection.destroy` убирает один или более объектов из коллекции. запуская `destroy` на каждой записи в соединительной таблице, включая запуск колбэков. Это не уничтожает объекты.

```ruby
@part.assemblies.destroy(@assembly1)
```

#### `collection=objects`

Метод `collection=` делает коллекцию содержащей только представленные объекты, добавляя и удаляя по мере необходимости.

#### `collection_singular_ids`

Метод `collection_singular_ids` возвращает массив id объектов в коллекции.

```ruby
@assembly_ids = @part.assembly_ids
```

#### `collection_singular_ids=ids`

Метод `collection_singular_ids=` делает коллекцию содержащей только объекты, идентифицированные представленными значениями первичного ключа, добавляя и удаляя по мере необходимости.

#### `collection.clear`

Метод `collection.clear` убирает каждый объект из коллекции, удаляя строки из соединительной таблицы. Это не уничтожает связанные объекты.

#### `collection.empty?`

Метод `collection.empty?` возвращает `true`, если коллекция не содержит каких-либо связанных объектов.

```ruby
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```

#### `collection.size`

Метод `collection.size` возвращает количество объектов в коллекции.

```ruby
@assembly_count = @part.assemblies.size
```

#### `collection.find(...)`

Метод `collection.find` ищет объекты в коллекции. Он использует тот же синтаксис и опции, что и `ActiveRecord::Base.find`. Он также добавляет дополнительное условие, что объект должен быть в коллекции.

```ruby
@assembly = @part.assemblies.find(1)
```

#### `collection.where(...)`

Метод `collection.where` ищет объекты в коллекции, основываясь на переданных условиях, но объекты загружаются лениво, что означает, что база данных запрашивается только когда происходит доступ к объекту(-там). Он также добавляет дополнительное условие, что объект должен быть в коллекции.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```

#### `collection.exists?(...)`

Метод `collection.exists?` проверяет, существует ли в коллекции объект, отвечающий представленным условиям. Он использует тот же синтаксис и опции, что и `ActiveRecord::Base.exists?`.

#### `collection.build(attributes = {})`

Метод `collection.build` возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, и будет создана связь через соединительную таблицу, но связанный объект _не_ будет пока сохранен.

```ruby
@assembly = @part.assemblies.build({assembly_name: "Transmission housing"})
```

#### `collection.create(attributes = {})`

Метод `collection.create` возвращает один или более объектов связанного типа. Эти объекты будут экземплярами с переданными атрибутами, будет создана связь через соединительную таблицу, и, если он пройдет валидации, определенные в связанной модели, связанный объект _будет_ сохранен.

```ruby
@assembly = @part.assemblies.create({assembly_name: "Transmission housing"})
```

### Опции для `has_and_belongs_to_many`

Хотя Rails использует разумные значения по умолчанию, работающие во многих ситуациях, бывают случаи, когда хочется изменить поведение связи `has_and_belongs_to_many`. Такая настройка легко выполнима с помощью передачи опции при создании связи. Например, эта связь использует две такие опции:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, uniq: true,
                                       read_only: true
end
```

Связь `has_and_belongs_to_many` поддерживает эти опции:

* `:association_foreign_key`
* `:autosave`
* `:class_name`
* `:foreign_key`
* `:join_table`
* `:validate`

#### `:association_foreign_key`

По соглашению Rails предполагает, что столбец в соединительной таблице, используемый для хранения внешнего ключа, указываемого на другую модель, является именем этой модели с добавленным суффиксом `_id`. Опция `:association_foreign_key` позволяет установить имя внешнего ключа явно:

TIP: Опции `:foreign_key` и `:association_foreign_key` полезны при настройке самоприсоединения многие-ко-многим. Например:

```ruby
class User < ActiveRecord::Base
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

#### `:autosave`

Если установить опцию `:autosave` в `true`, Rails сохранит любые загруженные члены и уничтожит члены, помеченные для уничтожения, всякий раз, когда Вы сохраните родительский объектt.

#### `:class_name`

Если имя другой модели не может быть произведено из имени связи, можете использовать опцию `:class_name` для предоставления имени модели. Например, если часть имеет много узлов, но фактическое имя модели, содержащей узлы - это `Gadget`, можете установить это следующим образом:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```

#### `:foreign_key`

По соглашению Rails предполагает, что столбец в соединительной таблице, используемый для хранения внешнего ключа, указываемого на эту модель, имеет имя модели с добавленным суффиксом `_id`. Опция `:foreign_key` позволяет установить имя внешнего ключа явно:

```ruby
class User < ActiveRecord::Base
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```

#### `:join_table`

Если имя соединительной таблицы по умолчанию, основанное на алфавитном порядке, - это не то, что вам нужно, используйте опцию `:join_table`, чтобы переопределить его.

#### `:validate`

Если установите опцию `:validate` в `false`, тогда связанные объекты не будут проходить валидацию всякий раз, когда вы сохраняете этот объект. По умолчанию она равна `true`: связанные объекты проходят валидацию, когда этот объект сохраняется.

### Скоупы для `has_and_belongs_to_many`

Иногда хочется настроить запрос, используемый `has_many`. Такая настройка может быть достигнута с помощью блока скоупа. Например:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Внутри блока скоупа можно использовать любые стандартные [методы запросов](/active-record-query-interface). Далее обсудим следующие из них:

* `where`
* `extending`
* `group`
* `includes`
* `limit`
* `offset`
* `order`
* `readonly`
* `select`
* `uniq`

#### `where`

Метод `where` позволяет определить условия, которым должен отвечать связанный объект.

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Также можно задать условия хэшем:

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

При использовании опции `where` хэшем, при создание записи через эту связь будет автоматически применен скоуп с использованием хэша. В этом случае при использовании `@parts.assemblies.create` или `@parts.assemblies.build` будут созданы заказы, в которых столбец `factory` будет иметь значение `Seattle`.

#### `extending`

Метод `extending` определяет именнованый модуль для расширения прокси связи. Расширения связей подробно обсуждаются [позже в этом руководстве](/active-record-associations/association-callbacks-and-extensions).

#### `group`

Метод `group` доставляет имя атрибута, по которому группируется результирующий набор, используя выражение `GROUP BY` в поисковом SQL.

```ruby
class Parts < ActiveRecord::Base
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```

#### `includes`

Можете использовать метод `include` для определения связей второго порядка, которые должны быть нетерпеливо загружены, когда эта связь используется.

#### `limit`

Метод `limit` позволяет ограничить общее количество объектов, которые будут выбраны через связь.

```ruby
class Customer < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```

#### `offset`

Метод `offset` позволяет определить начальное смещение для выбора объектов через связь. Например, `-> { offset(11) }` пропустит первые 11 записей.

#### `order`

Метод `order` предписывает порядок, в котором связанные объекты будут получены (в синтаксисе SQL, используемом в условии `ORDER BY`).

```ruby
class Customer < ActiveRecord::Base
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```

#### `readonly`

При использовании метода `:readonly`, связанные объекты будут доступны только для чтения, когда получены посредством связи.

#### `select`

Метод `select` позволяет переопределить SQL условие `SELECT`, которое используется для получения данных о связанном объекте. По умолчанию Rails получает все столбцы.

#### `uniq`

Используйте метод `uniq`, чтобы убирать дубликаты из коллекции. Это полезно в сочетании с опцией `:through`.

### Когда сохраняются объекты?

Когда вы назначаете объект связью `has_and_belongs_to_many` этот объект автоматически сохраняется (в порядке обновления соединительной таблицы). Если назначаете несколько объектов в одном выражении, они все будут сохранены.

Если одно из этих сохранений проваливается из-за ошибок валидации, тогда выражение назначения возвращает `false`, a само назначение отменяется.

Если родительский объект (который объявляет связь `has_and_belongs_to_many`) является несохраненным (то есть `new_record?` возвращает `true`) тогда дочерние объекты не сохраняются при добавлении. Все несохраненные члены связи сохранятся автоматически, когда сохранится родительский объект.

Если вы хотите назначить объект связью `has_and_belongs_to_many` без сохранения объекта, используйте метод `collection.build`.
