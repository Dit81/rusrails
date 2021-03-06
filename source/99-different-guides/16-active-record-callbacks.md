# Колбэки Active Record

Это руководство обучит вас как вмешаться в жизненный цикл ваших объектов Active Record.

После прочтения этого руководства вы узнаете:

* О жизненном цикле объектов Active Record
* Как создавать методы колбэков, отвечающих на события в жизненном цикле объекта
* Как создавать специальные классы, инкапсулирующих обычное поведение для ваших колбэков

Жизненный цикл объекта
----------------------

В результате обычных операций приложения на Rails, объекты могут быть созданы, обновлены и уничтожены. Active Record дает возможность вмешаться в этот жизненный цикл объекта, таким образом, вы можете контролировать свое приложение и его данные.

Валидации позволяют вам быть уверенными, что только валидные данные хранятся в вашей базе данных. Колбэки позволяют вам переключать логику до или после изменения состояния объекта.

Обзор колбэков
--------------

Колбэки это методы, которые вызываются в определенные моменты жизненного цикла объекта. С колбэками возможно написать код, который будет запущен, когда объект Active Record создается, сохраняется, обновляется, удаляется, проходит валидацию или загружается из базы данных.

### Регистрация колбэков

Для того, чтобы использовать доступные колбэки, их нужно зарегистрировать. Можно реализовать колбэки как обычные методы, а затем использовать макро-методы класса для их регистрации как колбэков.

```ruby
class User < ActiveRecord::Base
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  protected
  def ensure_login_has_a_value
    if login.nil?
      self.login = email unless email.blank?
    end
  end
end
```

Макро-методы класса также могут получать блок. Их можно использовать, если код внутри блока такой короткий, что помещается в одну строку.

```ruby
class User < ActiveRecord::Base
  validates :login, :email, presence: true

  before_create do |user|
    user.name = user.login.capitalize if user.name.blank?
  end
end
```

Колбэки также могут быть зарегистрированы на выполнение при определенных событиях жизненного цикла:

```ruby
class User < ActiveRecord::Base
  before_validation :normalize_name, on: :create

  # :on также принимает массив
  after_validation :set_location, on: [ :create, :update ]

  protected
  def normalize_name
    self.name = self.name.downcase.titleize
  end

  def set_location
    self.location = LocationService.query(self)
  end
end
```

Считается хорошей практикой объявлять методы колбэков как protected или private. Если их оставить public, они могут быть вызваны извне модели и нарушить принципы инкапсуляции объекта.

Доступные колбэки
-----------------

Вот список всех доступных колбэков Active Record, перечисленных в том порядке, в котором они вызываются в течение соответственных операций:

### Создание объекта

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`

### Обновление объекта

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`

### Уничтожение объекта

* `before_destroy`
* `around_destroy`
* `after_destroy`

WARNING. `after_save` запускается и при создании, и при обновлении, но всегда _после_ более специфичных колбэков `after_create` и `after_update`, не зависимо от порядка, в котором запускаются макро-вызовы.

### `after_initialize` и `after_find`

Колбэк `after_initialize` вызывается всякий раз, когда возникает экземпляр объекта Active Record, или непосредственно при использовании `new`, или когда запись загружается из базы данных. Он необходим, чтобы избежать необходимости непосредственно переопределять метод Active Record `initialize`.

Колбэк `after_find` будет вызван всякий раз, когда Active Record загружает запись из базы данных. `after_find` вызывается перед `after_initialize`, если они оба определены.

У колбэков `after_initialize` и `after_find` нет пары `before_*`, но они могут быть зарегистрированы подобно другим колбэкам Active Record.

```ruby
class User < ActiveRecord::Base
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
  end
end

>> User.new
You have initialized an object!
=> #<User id: nil>

>> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

Запуск колбэков
---------------

Следующие методы запускают колбэки:

* `create`
* `create!`
* `decrement!`
* `destroy`
* `destroy!`
* `destroy_all`
* `increment!`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Дополнительно, колбэк `after_find` запускается следующими поисковыми методами:

* `all`
* `first`
* `find`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

Колбэк `after_initialize` запускается всякий раз, когда инициализируется новый объект класса.

NOTE: Методы `find_by_*` и `find_by_*!` это динамические методы поиска, создаваемые автоматически для каждого атрибута. Изучите подробнее их в [разделе Динамический поиск](/active-record-query-interface/dynamic-finders)

Пропуск колбэков
----------------

Подобно валидациям, также возможно пропустить колбэки. Однако, эти методы нужно использовать осторожно, поскольку важные бизнес-правила и логика приложения могут содержаться в колбэках. Пропуск их без понимания возможных последствий может привести к невалидным данным.

* `decrement`
* `decrement_counter`
* `delete`
* `delete_all`
* `increment`
* `increment_counter`
* `toggle`
* `touch`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`

Прерывание выполнения
---------------------

Как только  вы зарегистрировали новые колбэки в своих моделях, они будут поставлены в очередь на выполнение. Эта очередь включает все валидации вашей модели, зарегистрированные колбэки и операции с базой данных для выполнения.

Вся цепочка колбэков упаковывается в операцию. Если любой метод _before_ колбэков возвращает `false` или вызывает исключение, выполняемая цепочка прерывается и запускается ROLLBACK; Колбэки _after_ могут достичь этого, только вызвав исключение.

WARNING. Вызов произвольного исключения может прервать код, который предполагает, что `save` и тому подобное не будут провалены подобным образом. Исключение `ActiveRecord::Rollback` чуть точнее сообщает Active Record, что происходит откат. Он подхватывается изнутри, но не перевызывает исключение.

Колбэки для отношений
---------------------

Колбэки работают с отношениями между моделями, и даже могут быть определены ими. Представим пример, где пользователь имеет много публикаций. Публикации пользователя должны быть уничтожены, если уничтожается пользователь. Давайте добавим колбэк `after_destroy` в модель `User` через ее отношения с моделью `Post`.

```ruby
class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
end

class Post < ActiveRecord::Base
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Post destroyed'
  end
end

>> user = User.first
=> #<User id: 1>
>> user.posts.create!
=> #<Post id: 1, user_id: 1>
>> user.destroy
Post destroyed
=> #<User id: 1>
```

Условные колбэки
----------------

Как и в валидациях, возможно сделать вызов метода колбэка условным от удовлетворения заданного условия. Это осуществляется при использовании опций `:if` и `:unless`, которые могут принимать символ, строку, `Proc` или массив. Опцию `:if` следует использовать для определения, при каких условиях колбэк *должен* быть вызван. Если вы хотите определить условия, при которых колбэк *не должен* быть вызван, используйте опцию `:unless`.

### Использование `:if` и `:unless` с символом

Опции `:if` и `:unless` можно связать с символом, соответствующим имени метода условия, который будет вызван непосредственно перед вызовом колбэка. При использовании опции `:if`, колбэк не будет выполнен, если метод условия возвратит false; при использовании опции `:unless`, колбэк не будет выполнен, если метод условия возвратит true. Это самый распространенный вариант. При использовании такой формы регистрации, также возможно зарегистрировать несколько различных условий, которые будут вызваны для проверки, должен ли запуститься колбэк.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### Использование `:if` и `:unless` со строкой

Также возможно использование строки, которая будет вычислена с помощью `eval`, и, следовательно, должна содержать валидный код Ruby. Этот вариант следует использовать только тогда, когда строка представляет действительно короткое условие.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number, if: "paid_with_card?"
end
```

### Использование `:if` и `:unless` с `Proc`

Наконец, можно связать `:if` и `:unless` с объектом `Proc`. Этот вариант более всего подходит при написании коротких методов, обычно в одну строку.

```ruby
class Order < ActiveRecord::Base
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

### Составные условия для колбэков

При написании условных колбэков, возможно смешивание `:if` и `:unless` в одном объявлении колбэка.

```ruby
class Comment < ActiveRecord::Base
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.post.ignore_comments? }
end
```

Классы колбэков
---------------

Иногда написанные вами методы колбэков достаточно полезны для повторного использования в других моделях. Active Record делает возможным создавать классы, включающие методы колбэка, так, что становится очень легко использовать их повторно.

Вот пример, где создается класс с колбэком `after_destroy` для модели `PictureFile`:

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exists?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

При объявлении внутри класса, как выше, методы колбэка получают объект модели как параметр. Теперь можем использовать класс коллбэка в модели:

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks.new
end
```

Заметьте, что нам нужно создать экземпляр нового объекта `PictureFileCallbacks`, после того, как объявили наш колбэк как отдельный метод. Это особенно полезно, если колбэки используют состояние экземпляря объекта. Часто, однако, более подходящим является иметь его как метод класса.

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exists?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

Если метод колбэка объявляется таким образом, нет необходимости создавать экземпляр объекта `PictureFileCallbacks`.

```ruby
class PictureFile < ActiveRecord::Base
  after_destroy PictureFileCallbacks
end
```

Внутри своего колбэк-класса можно создать сколько угодно колбэков.

Транзакционные колбэки
----------------------

Имеются два дополнительных колбэка, которые включаются по завершению транзакции базы данных: `after_commit` и `after_rollback`. Эти колбэки очень покожи на колбэк `after_save`, за исключением того, что они не запускаются пока изменения в базе данных не будут подтверждены или обращены. Они наиболее полезны, когда вашим моделям active record необходимо взаимодействовать с внешними системами, не являющимися частью транзакции базы данных.

Рассмотрим, к примеру, предыдущий пример, где модели `PictureFile` необходимо удалить файл после того, как запись уничтожена. Если что-либо вызовет исключение после того, как был вызван колбэк `after_destroy`, и транзакция откатывается, файл будет удален и модель останется в противоречивом состоянии. Например, предположим, что `picture_file_2` в следующем коде не валидна, и метод `save!` вызовет ошибку.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Используя колбэк `after_commit`, можно учесть этот случай.

```ruby
class PictureFile < ActiveRecord::Base
  attr_accessor :delete_file

  after_destroy do |picture_file|
    picture_file.delete_file = picture_file.filepath
  end

  after_commit do |picture_file|
    if picture_file.delete_file && File.exist?(picture_file.delete_file)
      File.delete(picture_file.delete_file)
      picture_file.delete_file = nil
    end
  end
end
```

Колбэки `after_commit` и `after_rollback` гарантируют, что будут вызваны для всех созданных, обновленных или удаленных моделей внутри блока транзакции. Если какое-либо исключение вызовется в одном из этих колбэков, они будут проигнорированы, чтобы не препятствовать другим колбэкам. По сути, если код вашего колбэка может вызвать исключение, нужно для него вызвать rescue, и обработать его нужным образом в колбэке.
