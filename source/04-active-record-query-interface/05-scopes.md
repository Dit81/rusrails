# Скоупы

Скоупинг позволяет определить часто используемые запросы, к которым можно обращаться как к вызовам метода в связанных объектах или моделях. С помощью этих скоупов можно использовать каждый ранее раскрытый метод, такой как `where`, `joins` и `includes`. Все методы скоупов возвращают объект `ActiveRecord::Relation`, который позволяет вызывать следующие методы (такие как другие скоупы).

Для определения простого скоупа мы используем метод `scope` внутри класса, передав запрос, который хотим запустить при вызове скоупа:

```ruby
class Post < ActiveRecord::Base
  scope :published, -> { where(published: true) }
end
```

Это в точности то же самое, что определение метода класса, и то, что именно вы используете, является вопросом профессионального предпочтения:

```ruby
class Post < ActiveRecord::Base
  def self.published
    where(published: true)
  end
end
```

Скоупы также сцепляются с другими скоупами:

```ruby
class Post < ActiveRecord::Base
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

Для вызова этого скоупа `published`, можно вызвать его либо на классе:

```ruby
Post.published # => [published posts]
```

Либо на связи, состоящей из объектов `Post`:

```ruby
category = Category.first
category.posts.published # => [published posts belonging to this category]
```

### Передача аргумента

Скоуп может принимать аргументы:

```ruby
class Post < ActiveRecord::Base
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

Это можно использовать так:

```ruby
Post.created_before(Time.zone.now)
```

Однако, это всего лишь дублирование функциональности, которая должна быть предоставлена методом класса.

```ruby
class Post < ActiveRecord::Base
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

Использование метода класса - более предпочтительный способ принятию аргументов скоупом. Эти методы также будут доступны на связанных объектах:

```ruby
category.posts.created_before(time)
```

### Применение скоупа по умолчанию

Если хотите, чтобы скоуп был применен ко всем запросам к модели, можно использовать метод `default_scope` в самой модели.

```ruby
class Client < ActiveRecord::Base
  default_scope { where("removed_at IS NULL") }
end
```

Когды запросы для этой модели будут выполняться, запрос SQL теперь будет выглядеть примерно так:

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

Если необходимо сделать более сложные вещи со скоупом по умолчанию, альтернативно его можно определить как метод класса:

```ruby
class Client < ActiveRecord::Base
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

### Удаление всех скоупов

Если хотите удалить скоупы по какой-то причине, можете использовать метод `unscoped`. Это особенно полезно, если в модели определен `default_scope`, и он не должен быть применен для конкретно этого запроса.

```ruby
Client.unscoped.all
```

Этот метод удаляет все скоупы и выполняет обычный запрос к таблице.

Отметьте, что сцепление `unscoped` со `scope` не работает. В этих случаях рекомендовано использовать блочную форму `unscoped`:

```ruby
Client.unscoped {
  Client.created_before(Time.zome.now)
}
```
