# Структурирование макетов (часть третья)

[>>>Первая часть](/layouts-and-rendering-in-rails/structuring-layouts)
<br />
[>>>Вторая часть](/layouts-and-rendering-in-rails/structuring-layouts-2)

### Использование партиалов

Частичные шаблоны - также называемые "партиалы" - являются еще одним подходом к разделению процесса рендеринга на более управляемые части. С партиалами можно перемещать код для рендеринга определенных кусков отклика в свои отдельные файлы.

#### Именование партиалов

Чтобы отрендерить партиал как часть вьюхи, используем метод `render` внутри вьюхи и включаем опцию `:partial`:

```ruby
<%= render "menu" %>
```

Это отрендерит файл, названный `_menu.html.erb` в этом месте при рендеринге вьюхи. Отметьте начальный символ подчеркивания: файлы партиалов начинаются со знака подчеркивания для отличия их от обычных вьюх, хотя в вызове они указаны без подчеркивания. Это справедливо даже тогда, когда партиалы вызываются из другой папки:

```ruby
<%= render "shared/menu" %>
```

Этот код затянет партиал из `app/views/shared/_menu.html.erb`.

#### Использование партиалов для упрощения вьюх

Партиалы могут использоваться как эквивалент подпрограмм: способ убрать подробности из вьюхи так, чтобы можно было легче понять, что там происходит. Например, у вас может быть такая вьюха:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

Здесь партиалы `_ad_banner.html.erb` и `_footer.html.erb` могут содержать контент, размещенный на многих страницах вашего приложения. Вам не нужно видеть подробностей этих разделов, когда вы сосредотачиваетесь на определенной странице.

TIP: Для содержимого, располагаемого на всех страницах вашего приложения, можете использовать партиалы прямо в макетах.

#### Макет партиалов

Партиал может использовать свой собственный файл макета, подобно тому, как вьюха может использовать макет. Например, можете вызвать подобный партиал:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Это найдет партиал с именем `_link_area.html.erb` и отрендерит его, используя макет `_graybar.html.erb`. Отметьте, что макеты для партиалов также начинаются с подчеркивания, как и обычные партиалы, и размещаются в той же папке с партиалами, которым они принадлежат (не в основной папке `layouts`).

Также отметьте, что явное указание `partial` необходимо, когда передаются дополнительные опции, такие как `layout`

#### Передача локальных переменных

В партиалы также можно передавать локальные переменные, что делает их более мощными и гибкими. Например, можете использовать такую технику для уменьшения дублирования между страницами new и edit, сохранив немного различающееся содержимое:

* `new.html.erb`

    ```erb
    <h1>New zone</h1>
    <%= error_messages_for :zone %>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```erb
    <h1>Editing zone</h1>
    <%= error_messages_for :zone %>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```erb
    <%= form_for(zone) do |f| %>
      <p>
        <b>Zone name</b><br />
        <%= f.text_field :name %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    ```

Хотя тот же самый партиал будет рендерен в обоих вьюхах, хелпер Action View submit возвратит “Create Zone” для экшна new и “Update Zone” для экшна edit.

Каждый партиал также имеет локальную переменную с именем, как у партиала (без подчеркивания). Можете передать объект в эту локальную переменную через опцию `:object`:

```erb
<%= render partial: "customer", object: @new_customer %>
```

В партиале `customer` переменная `customer` будет указывать на `@new_customer` из родительской вьюхи.

Если есть экземпляр модели для рендера в партиале, вы можете использовать краткий синтаксис:

```erb
<%= render @customer %>
```

Предположим, что переменная `@customer` содержит экземпляр модели `Customer`, это использует `_customer.html.erb` для ее рендера и передаст локальную переменную `customer` в партиал, к которой будет присвоена переменная экземпляра `@customer` в родительской вьюхе.

#### Рендеринг коллекций

Партиалы часто полезны для рендеринга коллекций. Когда коллекция передается в партиал через опцию `:collection`, партиал будет вставлен один раз для каждого члена коллекции:

* `index.html.erb`

    ```erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```erb
    <p>Product Name: <%= product.name %></p>
    ```

Когда партиал вызывается с коллекцией во множественном числе, то каждый отдельный экземпляр партиала имеет доступ к члену коллекции, подлежащей рендеру, через переменную с именем партиала. В нашем случает партиал `_product`, и в партиале `_product` можете обращаться к `product` для получения экземпляра, который рендерится.

Имеется также сокращение для этого. Предположив, что `@posts` является коллекцией экземпляров `post`, вы можете просто сделать так в `index.html.erb` и получить аналогичный результат:

```html+erb
<h1>Products</h1>
<%= render @products %>
```

Что приведет к такому же результату.

Rails определяет имя партиала, изучая имя модели в коллекции. Фактически можете даже создать неоднородную коллекцию и рендерить таким образом, и Rails подберет подходящий партиал для каждого члена коллекции:

* `index.html.erb`

    ```erb
    <h1>Contacts</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```erb
    <p>Customer: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```erb
    <p>Employee: <%= employee.name %></p>
    ```

В этом случае Rails использует партиалы customer или employee по мере необходимости для каждого члена коллекции.

В случае, если коллекция пустая, `render` возвратит nil, поэтому очень просто предоставить альтернативное содержимое.

```erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### Локальные переменные

Чтобы использовать пользовательские имена локальных переменных в партиале, определите опцию `:as` в вызове партиала:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

С этим изменением можете получить доступ к экземпляру коллекции `@products` через локальную переменную `item` в партиале.

Также можно передавать произвольные локальные переменные в любой партиал, который Вы рендерите с помощью опции `locals: {}`:

```erb
<%= render partial: "products", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

Отрендерит партиал `_products.html.erb` один на каждый экземпляр `product` в переменной экземпляра `@products`, передав экземпляр в партиал как локальную переменную по имени `item`, и для каждого партиала сделает доступной локальную переменную `title` со значением `Products Page`.

TIP: Rails также создает доступную переменную счетчика в партиале, вызываемом коллекцией, названную по имени члена коллекции с добавленным `_counter`. Например, если рендерите `@products`, в партиале можете обратиться к `product_counter`, который говорит, сколько раз партиал был рендерен. Это не работает в сочетании с опцией `as: :value`.

Также можете определить второй партиал, который будет отрендерен между экземплярами главного партиала, используя опцию `:spacer_template`:

#### Промежуточные шаблоны

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails отрендерит партиал `_product_ruler` (без переданных в него данных) между каждой парой партиалов `_product`.

#### Макеты партиалов коллекций

При рендеренге коллекций также возможно использовать опцию `:layout`:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

Макет будет отрендерен вместе с партиалом для каждого элемента коллекции. Переменные текущего объекта и object_counter также будут доступны в макете тем же образом, как и в партиале.

### Использование вложенных макетов

Возможно, ваше приложение потребует макет, немного отличающийся от обычного макета приложения, для поддержки одного определенного контроллера. Вместо повторения главного макета и редактирования его, можете выполнить это с помощью вложенных макетов (иногда называемых подшаблонами). Вот пример:

Предположим, имеется макет `ApplicationController`:

* `app/views/layouts/application.html.erb`

    ```erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Top menu items here</div>
      <div id="menu">Menu items here</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

На страницах, создаваемых NewsController, вы хотите спрятать верхнее меню и добавить правое меню:

* `app/views/layouts/news.html.erb`

    ```erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Right menu items here</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

Вот и все. Вьюхи News будут использовать новый макет, прячущий верхнее меню и добавляющий новое правое меню в "content" div.

Имеется несколько способов получить похожие результаты с различными подшаблонными схемами, используя эту технику. Отметьте, что нет ограничений на уровень вложенности. Можно использовать метод `ActionView::render` через `render template: 'layouts/news'`, чтобы основать новый макет на основе макета News. Если думаете, что не будете подшаблонить макет `News`, можете заменить строку `content_for?(:news_content) ? yield(:news_content) : yield` простым `yield`.
