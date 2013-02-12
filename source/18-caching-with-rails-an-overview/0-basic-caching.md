# Основы кэширования

Это введение в три типа техники кэширования: кэширование страницы, экшна и фрагмента. По умолчанию Rails предоставляет кэширование фрагмента. Чтобы использовать кэширование страницы и экшна, нужно добавить `actionpack-page_caching` и `actionpack-action_caching` в свой Gemfile.

Перед тем, как начать, убедитесь, что `config.action_controller.perform_caching` установлен `true`, если запущен режим development. Этот флаг обычно устанавливается в соответствующем config/environments/*.rb. По умолчанию кэширование отключено для development и test и включено для production.

```ruby
config.action_controller.perform_caching = true
```

### Кэширование страницы

Кэширование страницы это механизм Rails, позволяющий запросу на сгенерированную страницу быть полностью обслуженным вебсервером (т.е. Apache или nginx) в принципе, без прохождения через стек Rails. Очевидно, это очень быстро. К сожалению, это не может быть применено к каждой ситуации (например, к страницам, требующим аутентификации), и, так как вебсервер фактически извлекает файл из файловой системы, придется иметь дело с вопросом времени хранения кэша.

INFO: Кэширование страниц было убрано из Rails 4. Обратитесь к [гему actionpack-page_caching](https://github.com/rails/actionpack-page_caching)

### Кэширование экшна

Кэширование страниц нельзя использовать для экшнов, имеющих предварительные фильтры, - например, для страниц, требующих аутентификации. И тут на помощь приходит кэширование экшна. Кэширование экшна работает как кэширование страницы, за исключением того, что входящий веб запрос затрагивает стек Rails, таким образом, до обслуживания кэша могут быть запущены предварительные (before) фильтры. Это позволит использовать аутентификацию и другие ограничения, и в то же время выводит результат из кэшированной копии.

INFO: Кэширование экшна было убрано из Rails 4. Обратитесь к [гему actionpack-action_caching](https://github.com/rails/actionpack-action_caching)

### Кэширование фрагмента

Жить было бы прекрасно, если бы мы могли закэшировать весь контент страницы или экшна и обслуживать с ним всех. К сожалению, динамические веб приложения обычно создают страницы с рядом компонентов, не все из которых имеют сходные характеристики кэширования. Для устранения таких динамически создаваемых страниц, где различные части страниц нуждаются в кэшировании и прекращаются по-разному, Rails предоставляет механизм, названный Кэширование фрагмента.

Кэширование фрагмента позволяет фрагменту логики вьюхи быть обернутым в блок кэша и обслуженным из хранилища кэша для последующего запроса.

Как пример, если хотите показать все заказы, размещенные на веб сайте, в реальном времени и не хотите кэшировать эту часть страницы, но хотите кэшировать часть страницы, отображающей все доступные продукты, можете использовать следующий кусок кода:

```ruby
<% Order.find_recent.each do |o| %>
  <%= o.buyer.name %> bought <%= o.product.name %>
<% end %>

<% cache do %>
  All available products:
  <% Product.all.each do |p| %>
    <%= link_to p.name, product_url(p) %>
  <% end %>
<% end %>
```

Блок cache в нашем примере будет привязан к вызвавшему его экшну и записан в тоже место, как кэш экшна, что означает, что если хотите кэшировать несколько фрагментов на экшн, следует предоставить `action_suffix` в вызове cache:

```ruby
<% cache(action: 'recent', action_suffix: 'all_products') do %>
  All available products:
```

Можете прекратить кэш, используя метод `expire_fragment`, подобно следующему:

```ruby
expire_fragment(controller: 'products', action: 'recent', action_suffix: 'all_products')
```

Если не хотите, чтобы блок cache привязывался к вызвавшему его экшну, можете также использовать глобально настроенные фрагменты, вызвав метод `cache` с ключом, следующим образом:

```ruby
<% cache('all_available_products') do %>
  All available products:
<% end %>
```

Этот фрагмент затем будет доступен во всех экшнах в `ProductsController` c использованием ключа, и может быть прекращен тем же образом:

```ruby
expire_fragment('all_available_products')
```

Если хотите избежать ручного прекращения фрагмента всякий раз, когда экшн обновляет продукт, можно определить метод хелпера:

```ruby
module ProductsHelper
  def cache_key_for_products
    count          = Product.count
    max_updated_at = Product.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "products/all-#{count}-#{max_updated_at}"
  end
end
```

Этот метод создает ключ кэша, зависящий от всех продуктов, и может быть использован во вьюхе:

```erb
<% cache(cache_key_for_products) do %>
  All available products:
<% end %>
```

В качестве ключа кэша можно использовать модель `ActiveRecord`:

```ruby
<% Product.all.each do |p| %>
  <% cache(p) do %>
    <%= link_to p.name, product_url(p) %>
  <% end %>
<% end %>
```

Для модели будет вызван метод `cache_key`, возвращающий строку наподобие `products/23-20130109142513`. Ключ кэша включает имя модели, id и, наконец, временную метку updated_at. Таким образом, он автоматически создаст новый фрагмент, когда продукт обновится, так как ключ изменится.

Можно также объединить две схемы, что называется "Russian Doll Caching":

```ruby
<% cache(cache_key_for_products) do %>
  All available products:
  <% Product.all.each do |p| %>
    <% cache(p) do %>
      <%= link_to p.name, product_url(p) %>
    <% end %>
  <% end %>
<% end %>
```

Это называется "Russian Doll Caching", так как оно вкладывает несколько фрагментов. Преимущество этого в том, что если обновится единственный продукт, все другие внутренние фрагменты будут использованы повторно при создании внешнего фрагмента.

### Кэширование SQL

Кэширование запроса это особенность Rails, кэширующая результат выборки по каждому запросу. Если Rails встретит тот же запрос (query) на протяжения текущего запроса (request), он использует кэшированный результат, вместо того, чтобы снова сделать запрос к базе данных.

Например:

```ruby
class ProductsController < ApplicationController

  def index
    # Запускаем поисковый запрос
    @products = Product.all

    ...

    # Снова запускаем тот же запрос
    @products = Product.all
  end

end
```