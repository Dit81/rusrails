# Расширения для Date

### Вычисления

NOTE: Все следующие методы определены в `active_support/core_ext/date/calculations.rb`.

INFO: В следующих методах вычисления имеют крайний случай октября 1582 года, когда дней с 5 по 14 просто не существовало. Это руководство не документирует поведение около этих дней для краткости, достаточно сказать, что они делают то, что от них следует ожидать. Скажем, `Date.new(1582, 10, 4).tomorrow` возвратит `Date.new(1582, 10, 15)`, и так далее. Смотрите `test/core_ext/date_ext_test.rb` в тестовом наборе Active Support, чтобы понять ожидаемое поведение.

#### `Date.current`

Active Support определяет `Date.current` как сегодняшний день в текущей временной зоне. Он похож на `Date.today`, за исключением того, что он учитывает временную зону пользователя, если она определена. Он также определяет `Date.yesterday` и `Date.tomorrow`, и условия экземпляра `past?`, `today?` и `future?`, все они зависят относительно `Date.current`.

#### Именнованные даты

##### `prev_year`, `next_year`

В Ruby 1.9 `prev_year` и `next_year` возвращают дату с тем же днем/месяцем в предыдущем или следующем году:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_year              # => Fri, 08 May 2009
d.next_year              # => Sun, 08 May 2011
```

Если датой является 29 февраля високосного года, возвратится 28-е:

```ruby
d = Date.new(2000, 2, 29) # => Tue, 29 Feb 2000
d.prev_year               # => Sun, 28 Feb 1999
d.next_year               # => Wed, 28 Feb 2001
```

У `prev_year` есть псевдоним `last_year`.

##### `prev_month`, `next_month`

В Ruby 1.9 `prev_month` и `next_month` возвращает дату с тем же днем в предыдущем или следующем месяце:

```ruby
d = Date.new(2010, 5, 8) # => Sat, 08 May 2010
d.prev_month             # => Thu, 08 Apr 2010
d.next_month             # => Tue, 08 Jun 2010
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Date.new(2000, 5, 31).prev_month # => Sun, 30 Apr 2000
Date.new(2000, 3, 31).prev_month # => Tue, 29 Feb 2000
Date.new(2000, 5, 31).next_month # => Fri, 30 Jun 2000
Date.new(2000, 1, 31).next_month # => Tue, 29 Feb 2000
```

У `prev_month` есть псевдоним `last_month`.

##### `prev_quarter`, `next_quarter`

Похожи на `prev_month` и `next_month`. Возращают дату с тем же днем в предыдущим или следующем квартале:

```ruby
t = Time.local(2010, 5, 8) # => Sat, 08 May 2010
t.prev_quarter             # => Mon, 08 Feb 2010
t.next_quarter             # => Sun, 08 Aug 2010
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => Sun, 30 Apr 2000
Time.local(2000, 5, 31).prev_quarter  # => Tue, 29 Feb 2000
Time.local(2000, 10, 31).prev_quarter # => Mon, 30 Oct 2000
Time.local(2000, 11, 31).next_quarter # => Wed, 28 Feb 2001
```

`prev_quarter` имеет псевдоним `last_quarter`.

##### `beginning_of_week`, `end_of_week`

Методы `beginning_of_week` и `end_of_week` возвращают даты для начала и конца недели соответственно. Предполагается, что неделя начинается с понедельника, но это может быть изменено переданным аргументом, установив локально для треда `Date.beginning_of_week` или `config.beginning_of_week`.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

У `beginning_of_week` есть псевдоним `at_beginning_of_week`, а у `end_of_week` есть псевдоним `at_end_of_week`.

##### `monday`, `sunday`

Методы `monday` и `sunday` возвращают даты для прошлого понедельника или следующего воскресенья, соответственно.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

##### `prev_week`, `next_week`

`next_week` принимает символ с днем недели на английском (по умолчанию локальный для треда `Date.beginning_of_week`, или`config.beginning_of_week` или `:monday`) и возвращает дату, соответствующую этому дню на следующей неделе:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

`prev_week` работает аналогично:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

У `prev_week` есть псевдоним `last_week`.

И `next_week`, и `prev_week` работают так, как нужно, когда установлен `Date.beginning_of_week` или `config.beginning_of_week`.

##### `beginning_of_month`, `end_of_month`

Методы `beginning_of_month` и `end_of_month` возвращают даты для начала и конца месяца:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

У `beginning_of_month` есть псевдоним `at_beginning_of_month`, а у `end_of_month` есть псевдоним `at_end_of_month`.

##### `beginning_of_quarter`, `end_of_quarter`

Методы `beginning_of_quarter` и `end_of_quarter` возвращают даты начала и конца квартала календарного года получателя:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

У `beginning_of_quarter` есть псевдоним `at_beginning_of_quarter`, а у `end_of_quarter` есть псевдоним `at_end_of_quarter`.

##### `beginning_of_year`, `end_of_year`

Методы `beginning_of_year` и `end_of_year` возвращают даты начала и конца года:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

У `beginning_of_year` есть псевдоним `at_beginning_of_year`, а у `end_of_year` есть псевдоним `at_end_of_year`.

#### Другие вычисления дат

##### `years_ago`, `years_since`

Метод `years_ago` получает число лет и возвращает ту же дату, но на столько лет назад:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

`years_since` перемещает вперед по времени:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

Если такая дата не найдена, возвращается последний день соответствующего месяца:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

##### `months_ago`, `months_since`

Методы `months_ago` и `months_since` работают аналогично, но для месяцев:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

Если такой день не существует, возвращается последний день соответствующего месяца:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

##### `weeks_ago`

Метод `weeks_ago` работает аналогично для недель:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

##### `advance`

Более обычным способом перепрыгнуть на другие дни является `advance`. Этот метод получает хэш с ключами `:years`, `:months`, `:weeks`, `:days`, и возвращает дату, передвинутую на столько, сколько указывают существующие ключи:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Отметьте в предыдущем примере, что приросты могут быть отрицательными.

Для выполнения вычисления метод сначала приращивает года, затем месяцы, затем недели, и наконец дни. Порядок важен применительно к концам месяцев. Скажем, к примеру, мы в конце февраля 2010 и хотим переместиться на один месяц и один день вперед.

Метод `advance` передвигает сначала на один месяц, и затем на один день, результат такой:

```ruby
Date.new(2010, 2, 28).advance(months: 1, days: 1)
# => Sun, 29 Mar 2010
```

Если бы мы делали по другому, результат тоже был бы другой:

```ruby
Date.new(2010, 2, 28).advance(days: 1).advance(months: 1)
# => Thu, 01 Apr 2010
```

#### Изменяющиеся компоненты

Метод `change` позволяет получить новую дату, которая идентична получателю, за исключением заданного года, месяца или дня:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

Метод не толерантен к несуществующим датам, если изменение невалидно, вызывается `ArgumentError`:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

#### Длительности

Длительности могут добавляться и вычитаться из дат:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d ` 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

Это переводится в вызовы `since` или `advance`. Для примера мы получем правильный прыжок в реформе календаря:

```ruby
Date.new(1582, 10, 4) ` 1.day
# => Fri, 15 Oct 1582
```

#### Временные метки

INFO: Следующие методы возвращают объект `Time`, если возможно, в противном случае `DateTime`. Если установлено, учитывается временная зона пользователя.

##### `beginning_of_day`, `end_of_day`

Метод `beginning_of_day` возвращает временную метку для начала дня (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

Метод `end_of_day` возвращает временную метку для конца дня (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

У `beginning_of_day` есть псевдонимы `at_beginning_of_day`, `midnight`, `at_midnight`.

##### `beginning_of_hour`, `end_of_hour`

Метод `beginning_of_hour` возвращает временную метку в начале часа (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

Метод `end_of_hour` возвращает временную метку в конце часа (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

У `beginning_of_hour` есть псевдоним `at_beginning_of_hour`.

INFO: `beginning_of_hour` и `end_of_hour` реализованы для `Time` и `DateTime`, но **не** для `Date`, так как у экземпляр `Date` не имеет смысла спрашивать о начале или окончании часа.

##### `ago`, `since`

Метод `ago` получает количество секунд как аргумент и возвращает временную метку, имеющую столько секунд до полуночи:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

Подобным образом `since` двигается вперед:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
