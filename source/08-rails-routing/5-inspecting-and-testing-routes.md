# Осмотр и тестирование маршрутов

Rails предлагает инструменты для осмотра и тестирования маршрутов.

### Список существующих маршрутов

Чтобы получить полный список всех доступных маршрутов вашего приложения, посетите `http://localhost:3000/rails/info/routes` в браузере, в то время как ваш сервер запущен в режиме **development**.
Команда `rake routes`, запущенная в терминале, выдаст тот же результат.

Оба метода напечатают все ваши маршруты, в том же порядке, что они появляются в `routes.rb`. Для каждого маршрута вы увидите:

* Имя маршрута (если имеется)
* Используемый метод HTTP (если маршрут реагирует не на все методы)
* Шаблон URL
* Параметры роутинга для этого маршрута

Например, вот небольшая часть результата команды `rake routes` для маршрута RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Можете ограничить перечень маршрутами, ведущими к определенному контроллеру, установкой переменной среды `CONTROLLER`:

```bash
$ CONTROLLER=users rake routes
```

TIP: Результат команды `rake routes` более читаемый, если у вас в окне терминала прокрутка, а не перенос строк.

### Тестирование маршрутов

Маршруты должны быть включены в вашу стратегию тестирования (так же, как и остальное в вашем приложении). Rails предлагает три "встроенных оператора контроля":http://api.rubyonrails.org/classes/ActionController/Assertions/RoutingAssertions.html, разработанных для того, чтобы сделать тестирование маршрутов проще:

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### Оператор контроля `assert_generates`

Используйте `assert_generates` чтобы убедиться в том, что определенный набор опций создает конкретный путь. Можете использовать его с маршрутами по умолчанию или своими маршрутами. Например:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### Оператор контроля `assert_recognizes`

Оператор контроля `assert_recognizes` - это противоположность `assert_generates`. Он убеждается, что Rails распознает предложенный путь и маршрутизирует его в конкретную точку в вашем приложении. Например:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Можете задать аргумент `:method`, чтобы определить метод HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### Оператор контроля `assert_routing`

Оператор контроля `assert_routing` проверяет маршрут с двух сторон: он тестирует, что путь генерирует опции, и что опции генерируют путь. Таким образом, он комбинирует функции `assert_generates` и `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
