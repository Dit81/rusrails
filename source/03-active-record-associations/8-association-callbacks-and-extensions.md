# Подробная информация по колбэкам и расширениям связи

### Колбэки связи

Обычно колбэки прицепляются к жизненному циклу объектов Active Record, позволяя Вам работать с этими объектами в различных точках. Например, можете использовать колбэк `:before_save`, чтобы вызвать что-то перед тем, как объект будет сохранен.

Колбэки связи похожи на обычные колбэки, но они включаются событиями в жизненном цикле коллекции. Доступны четыре колбэка связи:

* `before_add`
* `after_add`
* `before_remove`
* `after_remove`

Колбэки связи объявляются с помощью добавления опций в объявление связи. Например:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders, before_add: :check_credit_limit

  def check_credit_limit(order)
    ...
  end
end
```

Rails передает добавляемый или удаляемый объект в колбэк.

Можете помещать колбэки в очередь на отдельное событие, передав их как массив:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(order)
    ...
  end

  def calculate_shipping_charges(order)
    ...
  end
end
```

Если колбэк `before_add` вызывает исключение, объект не будет добавлен в коллекцию. Подобным образом, если колбэк `before_remove` вызывает исключение, объект не убирается из коллекции.

### Расширения связи

Вы не ограничены функциональностью, которую Rails автоматически встраивает в выданные по связи объекты. Можете расширять эти объекты через анонимные модули, добавления новых методов поиска, создания и иных методов. Например:

```ruby
class Customer < ActiveRecord::Base
  has_many :orders do
    def find_by_order_prefix(order_number)
      find_by_region_id(order_number[0..2])
    end
  end
end
```

Если имеется расширение, которое должно быть распространено на несколько связей, можете использовать именнованный модуль расширения. Например:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Customer < ActiveRecord::Base
  has_many :orders, -> { extending FindRecentExtension }
end

class Supplier < ActiveRecord::Base
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

Расширения могут ссылаться на внутренние методы выданных по связи объектов, используя следующие три атрибута аксессора `proxy_association`:

* `proxy_association.owner` возвращает объект, в котором объявлена связь.
* `proxy_association.reflection` возвращает объект reflection, описывающий связь.
* `proxy_association.target` возвращает связанный объект для `belongs_to` или `has_one`, или коллекцию связанных объектов для `has_many` или `has_and_belongs_to_many`.
