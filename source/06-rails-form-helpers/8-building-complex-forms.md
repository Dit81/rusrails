# Создание сложных форм

Многие приложения вырастают из пределов простых форм, редактирующих одиночные объекты. Например, при создании Person вы, возможно, захотите позволить пользователю (в той же самой форме) создать несколько записей адресов (домашний, рабочий и т.д.). Позже, редактируя этого человека, пользователю должно быть доступно добавление, удаление или правка адреса, если необходимо.

### Настройка модели

Active Record представляет поддержку на уровне модели с помощью метода `accepts_nested_attributes_for`:

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses

  attr_accessible :name, :addresses_attributes
end

class Address < ActiveRecord::Base
  belongs_to :person
  attr_accessible :kind, :street
end
```

Это создат метод `addresses_attributes=` в `Person`, позволяющий создавать, обновлять и (опционально) уничтожать адреса. При использовании `attr_accessible` или `attr_protected` необходимо пометить `addresses_attributes` как accessible, как и другие атрибуты `Person` и `Address`, которым следует быть массово назначаемыми.

### Создание формы

Следующая форма позволяет пользователю создать `Person` и связанные с ним адреса.

```html+erb
<%= form_for @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Когда связь принимает вложенные атрибуты, `fields_for` рендерит свой блок для каждого элемента связи. В частности, если у person нет адресов, он ничего не рендерит. Обычным паттерном для контроллера является построение одного или более пустых дочерних элементов, чтобы как минимум один набор полей был показан пользователю. Следующий пример покажет 3 набора полей адресов в форме нового person.

```ruby
def new
  @person = Person.new
  3.times { @person.addresses.build}
end
```

`fields_for` вкладывает form builder, именующий параметры в формате, ожидаемом акцессором, созданным с помощью `accepts_nested_attributes_for`. К примеру, при создании пользователя с 2 адресами, отправленные параметры будут выглядеть так

```ruby
{
    :person => {
        :name => 'John Doe',
        :addresses_attributes => {
            '0' => {
                :kind  => 'Home',
                :street => '221b Baker Street',
            },
            '1' => {
                :kind => 'Office',
                :street => '31 Spooner Street'
            }
        }
    }
}
```

Ключи хэша `:addresses_attributes` не важны, они всего лишь должны быть различными для каждого адреса.

Если связанный объект уже сохранен, `fields_for` автоматически создает скрытое поле с `id` сохраненной записи. Это можно отключить, передав `include_id: false` в `fields_for`. Это может быть желаемым, если автоматически созданное поле размещается туда, где тег input не имеет валидного HTML, или при использовании ORM, когда дочерние элементы не имеют id.

### Контроллер

Для использования вложенных атрибутов не нужно писать какой-либо специфичный для контроллера код. Создавайте или обновляйте записи так, как для обычной формы.

### Удаление объектов

Можно позволить пользователям удалять связанные объекты, передав `allow_destroy: true` в `accepts_nested_attributes_for`

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

Если хэш атрибутов для объекта содержит ключ `_destroy` со значением '1' или 'true', тогда объект будет уничтожен. Эта форма позволяет пользователям удалять адреса:

```html+erb
<%= form_for @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

### Предотвращение пустых записей

Часто полезно игнорировать наборы полей, которые пользователь не заполнял. Этим можно управлять, передав `:reject_if` proc в `accepts_nested_attributes_for`. Этот proc будет вызван для каждого хэша атрибутов, отправляемого формой. Если proc возвращает `false`, тогда Active Record не создаст связанный объеккт для этого хэша. Следующий пример пытается создать адрес, если установлен атрибут `kind`.

```ruby
class Person < ActiveRecord::Base
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda {|attributes| attributes['kind'].blank?}
end
```

Вместо этого для удобства можно передать символ `:all_blank`, который создаст proc, который отвергнет записи, когда все атрибуты пустые, за исключением любого значения для `_destroy`.

### Добавление полей на лету

Вместо рендеринга нескольких наборов полей, можно сделать их добавление только когда пользователь нажимает на кнопку 'Добавить новый элемент'. Rails не предоставляет какой-либо встроенной поддержки для этого. При создании новых наборов полей, следует убедиться, что ключ связанного массива уникальный - наиболее распространенным выбором является текущий javascript date (миллисекунды после epoch).
