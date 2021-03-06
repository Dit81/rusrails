# Опции поиска

(ordering) Сортировка
----------

Чтобы получить записи из базы данных в определенном порядке, можете использовать метод `order`.

Например, если вы получаете ряд записей и хотите упорядочить их в порядке возрастания поля `created_at` в таблице:

```ruby
Client.order("created_at")
```

Также можете определить `ASC` или `DESC`:

```ruby
Client.order("created_at DESC")
# ИЛИ
Client.order("created_at ASC")
```

Или сортировку по нескольким полям:

```ruby
Client.order("orders_count ASC, created_at DESC")
# или
Client.order("orders_count ASC", "created_at DESC")
```

Если хотите вызвать `order` несколько раз, т.е. в различном контексте, новый порядок будет предшествовать предыдущему

```ruby
Client.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM clients ORDER BY created_at DESC, orders_count ASC
```

Выбор определенных полей
------------------------

По умолчанию `Model.find` выбирает все множество полей результата, используя `select *`.

Чтобы выбрать подмножество полей из всего множества, можете определить его, используя метод `select`.

Например, чтобы выбрать только столбцы `viewable_by` и `locked`:

```ruby
Client.select("viewable_by, locked")
```

Используемый для этого запрос SQL будет иметь подобный вид:

```sql
SELECT viewable_by, locked FROM clients
```

Будьте осторожны, поскольку это также означает, что будет инициализирован объект модели только с теми полями, которые вы выбрали. Если вы попытаетесь обратиться к полям, которых нет в инициализированной записи, то получите:

```bash
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Где `<attribute>` это атрибут, который был запрошен. Метод `id` не вызывает `ActiveRecord::MissingAttributeError`, поэтому будьте аккуратны при работе со связями, так как они нуждаются в методе `id` для правильной работы.

Если хотите вытащить только по одной записи для каждого уникального значения в определенном поле, можно использовать `uniq`:

```ruby
Client.select(:name).uniq
```

Это создаст такой SQL:

```sql
SELECT DISTINCT name FROM clients
```

Также можно убрать ограничение уникальности:

```ruby
query = Client.select(:name).uniq
# => Возвратит уникальные имена

query.uniq(false)
# => Возвратит все имена, даже если есть дубликаты
```

Ограничение и смещение
----------------------

Чтобы применить `LIMIT` к SQL, запущенному с помощью `Model.find`, нужно определить `LIMIT`, используя методы `limit` и `offset` на relation.

Используйте limit для определения количества записей, которые будут получены, и offset - для числа записей, которые будут пропущены до начала возврата записей. Например:

```ruby
Client.limit(5)
```

возвратит максимум 5 клиентов, и, поскольку не определено смещение, будут возвращены первые 5 клиентов в таблице. Запускаемый SQL будет выглядеть подобным образом:

```sql
SELECT * FROM clients LIMIT 5
```

Добавление `offset` к этому

```ruby
Client.limit(5).offset(30)
```

Возвратит максимум 5 клиентов, начиная с 31-го. SQL выглядит так:

```sql
SELECT * FROM clients LIMIT 5 OFFSET 30
```

Группировка
-----------

Чтобы применить условие `GROUP BY` к `SQL`, можете определить метод `group` в поисковом запросе.

Например, если хотите найти коллекцию дат, в которые были созданы заказы:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

Это даст вам отдельный объект `Order` для каждой даты, в которой были заказы в базе данных.

SQL, который будет выполнен, будет выглядеть так:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

Владение
--------

SQL использует условие `HAVING` для определения условий для полей, указанных в `GROUP BY`. Условие `HAVING`, определенное в SQL, запускается в `Model.find` с использованием опции `:having` для поиска.

Например:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)").having("sum(price) > ?", 100)
```

SQL, который будет выполнен, выглядит так:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
HAVING sum(price) > 100
```

Это возвратит отдельные объекты order для каждого дня, но только те, которые заказаны более чем на 100$ в день.

Переопределяющие условия
------------------------

### `except`

Можете указать определенные условия, которые будут исключены, используя метод `except`. Например:

```ruby
Post.where('id > 10').limit(20).order('id asc').except(:order)
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id > 10 LIMIT 20
```

### `only`

Также можете переопределить условия, используя метод `only`. Например:

```ruby
Post.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id > 10 ORDER BY id DESC
```

### `reorder`

Метод `reorder` переопределяет сортировку скоупа по умолчанию. Например:

```ruby
class Post < ActiveRecord::Base
  ..
  ..
  has_many :comments, order: 'posted_at DESC'
end

Post.find(10).comments.reorder('name')
```

SQL, который будет выполнен:

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY name
```

В случае, если бы условие `reorder` не было бы использовано, запущенный SQL был бы:

```sql
SELECT * FROM posts WHERE id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

Метод `reverse_order` меняет направление условия сортировки, если оно определено:

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

SQL, который будет выполнен:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

Если условие сортировки не было определено в запросе, `reverse_order` сортирует по первичному ключу в обратном порядке:

```ruby
Client.where("orders_count > 10").reverse_order
```

SQL, который будет выполнен:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

Этот метод не принимает аргументы.

Нулевой Relation
----------------

Метод `none` возвращает сцепляемый relation без записей. Любые последующие условия, сцепленные с возвращенным relation, продолжат возвращать пустые relation. Это полезно в случаях, когда необходим сцепляемый отклик на метод или скоуп, который может вернуть пустые результаты.

```ruby
Post.none # returns an empty Relation and fires no queries.
```

```ruby
# От метода visible_posts ожидается, что он вернет Relation.
@posts = current_user.visible_posts.where(name: params[:name])

def visible_posts
  case role
  when 'Country Manager'
    Post.where(country: country)
  when 'Reviewer'
    Post.published
  when 'Bad User'
    Post.none # => если бы вернули [] или nil, код поломался бы в этом случае
  end
end
```

Объекты только для чтения
-------------------------

Active Record представляет метод `readonly` у relation для явного запрета изменения любого возвращаемого объекта. Любая попытка изменить объект только для чтения будет неудачной, вызвав исключение `ActiveRecord::ReadOnlyRecord`.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

Так как `client` явно указан как объект только для чтения, вызов вышеуказанного кода вызовет исключение `ActiveRecord::ReadOnlyRecord` при вызове `client.save` с обновленным значением `visits`.

Блокировка записей для обновления
---------------------------------

Блокировка полезна для предотвращения гонки условий при обновлении записей в базе данных и обеспечения атомарного обновления.

Active Record предоставляет два механизма блокировки:

* Оптимистичная блокировка
* Пессимистичная блокировка

### Оптимистичная блокировка

Оптимистичная блокировка позволяет нескольким пользователям обращаться к одной и той же записи для редактирования и предполагает минимум конфликтов с данными. Она осуществляется с помощью проверки, сделал ли другой процесс изменения в записи, с тех пор как она была открыта. Если это происходит, вызывается исключение `ActiveRecord::StaleObjectError`, и обновление игнорируется.

**Столбец оптимистичной блокировки**

Чтобы начать использовать оптимистичную блокировку, таблица должна иметь столбец, называющийся `lock_version`, с типом integer. Каждый раз, когда запись обновляется, Active Record увеличивает значение `lock_version`, и средства блокирования обеспечивают, что для записи, вызванной дважды, та, которая первая успеет будет сохранена, а для второй будет вызвано исключение `ActiveRecord::StaleObjectError`. Пример:

```ruby
c1 = Client.find(1)
c2 = Client.find(1)

c1.first_name = "Michael"
c1.save

c2.name = "should fail"
c2.save # Raises a ActiveRecord::StaleObjectError
```

Вы ответственны за разрешение конфликта с помощью обработки исключения и либо отката, либо объединения, либо применения бизнес-логики, необходимой для разрешения конфликта.

Это поведение может быть отключено, если установить `ActiveRecord::Base.lock_optimistically = false`.

Для переопределения имени столбца `lock_version`, `ActiveRecord::Base` предоставляет атрибут класса `locking_column`:

```ruby
class Client < ActiveRecord::Base
  self.locking_column = :lock_client_column
end
```

### Пессимистичная блокировка

Пессимистичная блокировка использует механизм блокировки, предоставленный лежащей в основе базой данных. Использование `lock` при построении relation применяет эксклюзивную блокировку на выделенные строки. Relation использует `lock` обычно упакованный внутри transaction для предотвращения условий взаимной блокировки (дедлока).

Например:

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save
end
```

Вышеописанная сессия осуществляет следующие SQL для бэкенда MySQL:

```sql
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

Можете передать чистый SQL в опцию `:lock` для разрешения различных типов блокировок. Например, MySQL имеет выражение, называющееся `LOCK IN SHARE MODE`, которым можно заблокировать запись, но разрешить другим запросам читать ее. Для указания этого выражения, просто передайте его как опцию блокировки:

```ruby
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
```

Если у вас уже имеется экземпляр модели, можно начать транзакцию и затребовать блокировку одновременно, используя следующий код:

```ruby
item = Item.first
item.with_lock do
  # Этот блок вызывается в транзакции,
  # элемент уже заблокирован.
  item.increment!(:views)
end
```
