# Строгие валидации

Также можно определить валидации строгими, чтобы они вызывали `ActiveModel::StrictValidationFailed`, когда объект невалиден.

```ruby
class Person < ActiveRecord::Base
  validates :name, presence: { strict: true }
end

Person.new.valid?  # => ActiveModel::StrictValidationFailed: Name can't be blank
```

Также возможно передать собственное исключение в опцию `:strict`

```ruby
class Person < ActiveRecord::Base
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

Person.new.valid?  # => TokenGenerationException: Token can't be blank
```
