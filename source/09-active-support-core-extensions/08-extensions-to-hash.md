# Расширения для Hash

### Конверсия

#### `to_xml`

Метод `to_xml` возвращает строку, содержащую представление XML его получателя:

```ruby
{"foo" => 1, "bar" => 2}.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

Для этого метод в цикле проходит пары и создает узлы, зависимые от _value_. Для заданной пары `key`, `value`:

* Если `value` - хэш, происходит рекурсивный вызов с `key` как `:root`.
* Если `value` - массив, происходит рекурсивный вызов с `key` как `:root` и `key` в единственном числе как `:children`.
* Если `value` - вызываемый объект, он должен ожидать один или два аргумента. В зависимости от ситуации, вызываемый объект вызывается с помощью хэша `options` в качестве первого аргумента с `key` как `:root`, и `key` в единственном числе в качестве второго аргумента. Возвращенное значение становится новым узлом.
* Если `value` откликается на `to_xml`, метод вызывается с `key` как `:root`.
* В иных случаях, создается узел с `key` в качестве тега, со строковым представлением `value` в качестве текстового узла. Если `value` является `nil`, добавляется атрибут "nil", установленный в "true". Кроме случаев, когда существует опция `:skip_types` со значением true, добавляется атрибут "type", соответствующий следующему преобразованию:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Fixnum"     => "integer",
  "Bignum"     => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

По умолчанию корневым узлом является "hash", но это настраивается с помощью опции `:root`.

По умолчанию билдер XML является новым экземпляром `Builder::XmlMarkup`. Можно настроить свой собственный билдер с помощью опции `:builder`. Метод также принимает опции, такие как `:dasherize` со товарищи, они перенаправляются в билдер.

NOTE: Определено в `active_support/core_ext/hash/conversions.rb`.

### Объединение

В Ruby имеется встроенный метод `Hash#merge`, объединяющий два хэша:

```ruby
{a: 1, b: 1}.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support определяет больше способов объединения хэшей, которые могут быть полезными.

#### `reverse_merge` и `reverse_merge!`

В случае коллизии, в `merge` побеждает ключ в хэше аргумента. Можно компактно предоставить хэш опций со значением по умолчанию с помощью такой идиомы:

```ruby
options = {length: 30, omission: "..."}.merge(options)
```

Active Support определяет `reverse_merge` в случае, если нужна альтернативная запись:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

И восклицательная версия `reverse_merge!`, выполняющая объединение на месте:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

WARNING. Обратите внимание, что `reverse_merge!` может изменить хэш в вызывающем методе, что может как быть, так и не быть хорошей идеей.

NOTE: Определено в `active_support/core_ext/hash/reverse_merge.rb`.

#### `reverse_update`

Метод `reverse_update` это псевдоним для `reverse_merge!`, описанного выше.

WARNING. Отметьте, что у `reverse_update` нет восклицательного знака.

NOTE: Определено в `active_support/core_ext/hash/reverse_merge.rb`.

#### `deep_merge` и `deep_merge!`

Как видите в предыдущем примере, если ключ обнаруживается в обоих хэшах, один из аргументов побеждает.

Active Support определяет `Hash#deep_merge`. В углубленном объединении, если обнаруживается ключ в обоих хэшах, и их значения также хэши, то их _merge_ становиться значением в результирующем хэше:

```ruby
{a: {b: 1}}.deep_merge(a: {c: 2})
# => {:a=>{:b=>1, :c=>2}}
```

Метод `deep_merge!` выполняет углубленное объединение на месте.

NOTE: Определено в `active_support/core_ext/hash/deep_merge.rb`.

### "Глубокое" дублирование

Метод `Hash.deep_dup` дублирует себя и все ключи и значения внутри рекурсивно с помощью метода ActiveSupport `Object#deep_dup`. Он работает так же, как `Enumerator#each_with_object`, посылая метод `deep_dup` в каждую пару внутри.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: Определено в `active_support/core_ext/hash/deep_dup.rb`.

### Определение различий

Метод `diff` возвращает хэш, представляющий разницу между получателем и аргументом, с помощью следующей логики:

* Пары `key`, `value`, существующие в обоих хэшах, не принадлежат хэшу различий.
* Если оба хэша имеют `key`, но с разными значениями, побеждает пара в получателе.
* Остальное просто объединяется.

```ruby
{a: 1}.diff(a: 1)
# => {}, первое правило

{a: 1}.diff(a: 2)
# => {:a=>1}, второе правило

{a: 1}.diff(b: 2)
# => {:a=>1, :b=>2}, третье правило

{a: 1, b: 2, c: 3}.diff(b: 1, c: 3, d: 4)
# => {:a=>1, :b=>2, :d=>4}, все правила

{}.diff({})        # => {}
{a: 1}.diff({})    # => {:a=>1}
{}.diff(a: 1)      # => {:a=>1}
```

Важным свойством этого хэша различий является то, что можно получить оригинальный хэш, применив `diff` дважды:

```ruby
hash.diff(hash2).diff(hash2) == hash
```

Хэши различий могут быть полезны, к примеру, для сообщений об ошибке, относящихся к ожидаемым хэшам опций.

NOTE: Определено в `active_support/core_ext/hash/diff.rb`.

### Работа с ключами

#### `except` и `except!`

Метод `except` возвращает хэш с убранными ключами, содержащимися в перечне аргументов, если они существуют:

```ruby
{a: 1, b: 2}.except(:a) # => {:b=>2}
```

Если получатель откликается на `convert_key`, метод вызывается на каждом из аргументов. Это позволяет `except` хорошо обращаться с хэшами с индифферентым доступом, например:

```ruby
{a: 1}.with_indifferent_access.except(:a)  # => {}
{a: 1}.with_indifferent_access.except("a") # => {}
```

Также имеется восклицательный вариант `except!`, который убирает ключи в самом получателе.

NOTE: Определено в `active_support/core_ext/hash/except.rb`.

#### `transform_keys` и `transform_keys!`

Метод `transform_keys` принимает блок и возвращает хэш, в котором к каждому из ключей получателя были применены операции в блоке:

```ruby
{nil => nil, 1 => 1, a: :a}.transform_keys{ |key| key.to_s.upcase }
# => {"" => nil, "A" => :a, "1" => 1}
```

Результат в случае коллизии неопределен:

```ruby
{"a" => 1, a: 2}.transform_keys{ |key| key.to_s.upcase }
# => {"A" => 2}, в моем тесте, хотя на этот результат не стоит полагаться
```

Этот метод можеет помочь, к примеру, при создании специальных преобразований. Например, `stringify_keys` и `symbolize_keys` используют `transform_keys` для выполнения преобразований ключей:

```ruby
def stringify_keys
  transform_keys{ |key| key.to_s }
end
...
def symbolize_keys
  transform_keys{ |key| key.to_sym rescue key }
end
```

Также имеется восклицательный вариант `transform_keys!` применяющий операции в блоке к самому получателю.

Кроме этого, можно использовать `deep_transform_keys` и `deep_transform_keys!` для выполнения операции в блоке ко всем ключам в заданном хэше и всех хэшах, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_transform_keys{ |key| key.to_s.upcase }
# => {""=>nil, "1"=>1, "NESTED"=>{"A"=>3, "5"=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `stringify_keys` и `stringify_keys!`

Метод `stringify_keys` возвращает хэш, в котором ключи получателя приведены к строке. Это выполняется с помощью применения к ним `to_s`:

```ruby
{nil => nil, 1 => 1, a: :a}.stringify_keys
# => {"" => nil, "a" => :a, "1" => 1}
```

Результат в случае коллизии неопределен:

```ruby
{"a" => 1, a: 2}.stringify_keys
# => {"a" => 2}, в моем тесте, хотя на этот результат нельзя полагаться
```

Метод может быть полезным, к примеру, для простого принятия и символов, и строк как опций. Например, `ActionView::Helpers::FormHelper` определяет:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  ...
end
```

Вторая строка может безопасно обращаться к ключу "type" и позволяет пользователю передавать или `:type`, или "type".

Также имеется восклицательный вариант `stringify_keys!`, который приводит к строке ключи в самом получателе.

Кроме этого, можно использовать `deep_stringify_keys` и `deep_stringify_keys!` для приведения к строке всех ключей в заданном хэше и всех хэшах, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `symbolize_keys` и `symbolize_keys!`

Метод `symbolize_keys` возвращает хэш, в котором ключи получателя приведены к символам там, где это возможно. Это выполняется с помощью применения к ним `to_sym`:

```ruby
{nil => nil, 1 => 1, "a" => "a"}.symbolize_keys
# => {1=>1, nil=>nil, :a=>"a"}
```

WARNING. Отметьте в предыдущем примере, что только один ключ был приведен к символу.

Результат в случае коллизии неопределен:

```ruby
{"a" => 1, a: 2}.symbolize_keys
# => {:a=>2}, в моем тесте, хотя на этот результат нельзя полагаться
```

Метод может быть полезным, к примеру, для простого принятия и символов, и строк как опций. Например, `ActionController::UrlRewriter` определяет

```ruby
def rewrite_path(options)
  options = options.symbolize_keys
  options.update(options[:params].symbolize_keys) if options[:params]
  ...
end
```

Вторая строка может безопасно обращаться к ключу `:params` и позволяет пользователю передавать или `:params`, или "params".

Также имеется восклицательный вариант `symbolize_keys!`, который приводит к символу ключи в самом получателе.

Кроме этого, можно использовать `deep_symbolize_keys` и `deep_symbolize_keys!` для приведения к символам всех ключей в заданном хэше и всех хэшах, вложенных в него. Пример результата:

```ruby
{nil => nil, 1 => 1, "nested" => {"a" => 3, 5 => 5}}.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `to_options` и `to_options!`

Методы `to_options` и `to_options!` соответствующие псевдонимы `symbolize_keys` и `symbolize_keys!`.

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

#### `assert_valid_keys`

Метод `assert_valid_keys` получает определенное число аргументов и проверяет, имеет ли получатель хоть один ключ вне этого белого списка. Если имеет, вызывается `ArgumentError`.

```ruby
{a: 1}.assert_valid_keys(:a)  # passes
{a: 1}.assert_valid_keys("a") # ArgumentError
```

Active Record не принимает незнакомые опции при создании связей, к примеру. Он реализует такой контроль через `assert_valid_keys`.

NOTE: Определено в `active_support/core_ext/hash/keys.rb`.

### Вырезание (slicing)

В Ruby есть встроенная поддержка для вырезания строк или массивов. Active Support расширяет вырезание на хэши:

```ruby
{a: 1, b: 2, c: 3}.slice(:a, :c)
# => {:c=>3, :a=>1}

{a: 1, b: 2, c: 3}.slice(:b, :X)
# => {:b=>2} # несуществующие ключи игнорируются
```

Если получатель откликается на `convert_key`, ключи нормализуются:

```ruby
{a: 1, b: 2}.with_indifferent_access.slice("a")
# => {:a=>1}
```

NOTE. Вырезание может быть полезным для экранизации хэшей опций с помощью белого списка ключей.

Также есть `slice!`, который выполняет вырезание на месте, возвращая то, что было убрано:

```ruby
hash = {a: 1, b: 2}
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

Метод `extract!` возвращает тот же подкласс Hash, каким является получатель.

```ruby
hash = {a: 1, b: 2}.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: Определено в `active_support/core_ext/hash/slice.rb`.

### Извлечение

Метод `extract!` убирает и возвращает пары ключ/значение, соответствующие заданным ключам.

```ruby
hash = {:a => 1, :b => 2}
rest = hash.extract!(:a) # => {:a => 1}
hash                     # => {:b => 2}
```

NOTE: Определено в `active_support/core_ext/hash/slice.rb`.

### Индифферентный доступ

Метод `with_indifferent_access` возвращает `ActiveSupport::HashWithIndifferentAccess` его получателя:

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

NOTE: Определено в `active_support/core_ext/hash/indifferent_access.rb`.
