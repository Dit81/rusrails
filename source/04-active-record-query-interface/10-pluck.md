# pluck

`pluck` может быть использован для запроса отдельного столбца или нескольких столбцов из таблицы, лежащей в основе модели. Он принимает имя столбца как аргумент и возвращает массив значений определенного столбца соответствующего типа данных.

```ruby
Client.where(active: true).pluck(:id)
# SELECT id FROM clients WHERE active = 1
# => [1, 2, 3]

Client.uniq.pluck(:role)
# SELECT DISTINCT role FROM clients
# => ['admin', 'member', 'guest']

Client.pluck(:id, :name)
# SELECT clients.id, clients.name FROM clients
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
```

`pluck` позволяет заменить такой код

```ruby
Client.select(:id).map { |c| c.id }
# или
Client.select(:id).map(&:id)
# или
Client.select(:id).map { |c| [c.id, c.name] }
```

на

```ruby
Client.pluck(:id)
# или
Client.pluck(:id, :name)
```

## `ids`

`ids` может быть использован для сбора всех ID для relation, используя первичный ключ таблицы.

```ruby
Person.ids
# SELECT id FROM people
```

```ruby
class Person < ActiveRecord::Base
  self.primary_key = "person_id"
end

Person.ids
# SELECT person_id FROM people
```
