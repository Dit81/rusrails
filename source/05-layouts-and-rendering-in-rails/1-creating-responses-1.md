# Создание откликов (часть первая)

С точки зрения контроллера есть три способа создать отклик HTTP:

* Вызвать `render` для создания полного отклика, возвращаемого браузеру
* Вызвать `redirect_to` для передачи браузеру кода переадресации HTTP
* Вызвать `head` для создания отклика, включающего только заголовки HTTP, возвращаемого браузеру

Мы раскроем каждый из этих методов по очереди. Но сначала немного о самой простой вещи, которую может делать контроллер для создания отклика: не делать ничего.

### Рендеринг по умолчанию: соглашение над конфигурацией в действии

Вы уже слышали, что Rails содействует принципу "convention over configuration". Рендеринг по умолчанию - прекрасный пример этого. По умолчанию контроллеры в Rails автоматически рендерят вьюхи с именами, соответствующими экшну. Например, если есть такой код в вашем классе `BooksController`:

```ruby
class BooksController < ApplicationController
end
```

И следующее в файле маршрутов:

```ruby
resources :books
```

И у вас имеется файл вьюхи `app/views/books/index.html.erb`:

```ruby
<h1>Books are coming soon!</h1>
```

Rails автоматически отрендерит `app/views/books/index.html.erb` при переходе на адрес `/books`, и вы увидите на экране надпись "Books are coming soon!"

Однако это сообщение минимально полезно, поэтому вскоре вы создадите модель `Book` и добавите экшн index в `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Снова отметьте, что у нас соглашения превыше конфигурации в том, что отсутствует избыточный рендер в конце этого экшна index. Правило в том, что не нужно что-то избыточно рендерить в конце экшна контроллера, rails будет искать шаблон `action_name.html.erb` по пути вьюх контроллера и отрендерит его, поэтому в нашем случае Rails отрендерит файл `app/views/books/index.html.erb`.

Итак, в нашей вьюхе мы хотим отобразить свойства всех книг, это делается с помощью шаблона ERB, подобного следующему:

```html+erb
<h1>Listing Books</h1>

<table>
  <tr>
    <th>Title</th>
    <th>Summary</th>
    <th></th>
    <th></th>
    <th></th>
  </tr>

<% @books.each do |book| %>
  <tr>
    <td><%= book.title %></td>
    <td><%= book.content %></td>
    <td><%= link_to "Show", book %></td>
    <td><%= link_to "Edit", edit_book_path(book) %></td>
    <td><%= link_to "Remove", book, method: :delete, data: { confirm: "Are you sure?" } %></td>
  </tr>
<% end %>
</table>

<br />

<%= link_to "New book", new_book_path %>
```

NOTE: Фактически рендеринг осуществляется подклассами `ActionView::TemplateHandlers`. Мы не будем углубляться в этот процесс, но важно знать, что расширение файла вьюхи контролирует выбор обработчика шаблона. Начиная с Rails 2, стандартные расширения это `.erb` для ERB (HTML со встроенным Ruby) и `.builder` для Builder (генератор XML).

### Использование `render`

Во многих случаях метод `ActionController::Base#render` выполняет большую работу по рендерингу содержимого Вашего приложения для использования в браузере. Имеются различные способы настройки возможностей `render`. Вы можете рендерить вьюху по умолчанию для шаблона Rails, или определенный шаблон, или файл, или встроенный код, или совсем ничего. Можно рендерить текст, JSON или XML. Также можно определить тип содержимого или статус HTTP отрендеренного отклика.

TIP: Если хотите увидеть точные результаты вызова `render` без необходимости смотреть его в браузере, можете вызвать `render_to_string`. Этот метод принимает те же самые опции, что и `render`, но возвращает строку вместо отклика для браузера.

#### Не рендерим ничего

Самое простое, что мы можем сделать с `render` это не рендерить ничего:

```ruby
render nothing: true
```

Если взглянуть на отклик, используя cURL, увидим следующее:

```bash
$ curl -i 127.0.0.1:3000/books
HTTP/1.1 200 OK
Connection: close
Date: Sun, 24 Jan 2010 09:25:18 GMT
Transfer-Encoding: chunked
Content-Type: */*; charset=utf-8
X-Runtime: 0.014297
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache


 $
```

Мы видим пустой отклик (нет данных после строки `Cache-Control`), но Rails установил отклик 200 OK, поэтому запрос был успешным. Можете установить опцию `:status`, чтобы изменить этот отклик. Пустой рендеринг полезен для запросов AJAX, когда все, что вы хотите вернуть браузеру, - это подтверждение того, что запрос был выполнен.

TIP: Возможно следует использовать метод `head`, который рассмотрим во второй части этой главы, вместо `render :nothing`. Это придаст дополнительную гибкость и сделает явным то, что генерируются только заголовки HTTP.

#### Рендеринг вьюхи экшна

Если хотите отрендерить вьюху, соответствующую другому шаблону этого же контроллера, можно использовать `render` с именем вьюхи:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(params[:book])
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Если вызов `update` проваливается, вызов экшна `update` в этом контроллере отрендерит шаблон `edit.html.erb`, принадлежащий тому же контроллеру.

Если хотите, можете использовать символ вместо строки для определения экшна для рендеринга:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(params[:book])
    redirect_to(@book)
  else
    render :edit
  end
end
```

#### Рендеринг шаблона экшна из другого контроллера

Что, если вы хотите отрендерить шаблон из абсолютно другого контроллера? Это можно также сделать с `render`, который принимает полный путь шаблона для рендера (относительно `app/views`). Например, если запускаем код в `AdminProductsController` который находится в `app/controllers/admin`, можете отрендерить результат экшна в шаблон в `app/views/products` следующим образом:

```ruby
render "products/show"
```

Rails знает, что эта вьюха принадлежит другому контроллеру, поскольку содержит символ слэша в строке. Если хотите быть точными, можете использовать опцию `:template` (которая требовалась в Rails 2.2 и более ранних):

```ruby
render template: "products/show"
```

#### Рендеринг произвольного файла

Метод `render` также может использовать вьюху, которая расположена вне вашего приложения (возможно, вы совместно используете вьюхи двумя приложениями на Rails):

```ruby
render "/u/apps/warehouse_app/current/app/views/products/show"
```

Rails определяет, что это рендер файла по начальному символу слэша. Если хотите быть точным, можете использовать опцию `:file` (которая требовалась в Rails 2.2 и более ранних):

```ruby
render file: "/u/apps/warehouse_app/current/app/views/products/show"
```

Опция `:file` принимает абсолютный путь в файловой системе. Разумеется, вам необходимы права на просмотр того, что вы используете для рендера.

NOTE: По умолчанию файл рендериться без использования текущего макета. Если Вы хотите, чтобы Rails вложил файл в текущий макет, необходимо добавить опцию `layout: true`.

TIP: Если вы работаете под Microsoft Windows, то должны использовать опцию `:file` для рендера файла, потому что имена файлов Windows не имеют тот же формат, как имена файлов Unix.

#### Навороченность

Вышеописанные три метода рендера (рендеринг другого шаблона в контроллере, рендеринг шаблона в другом контроллере и рендеринг произвольного файла в файловой системе) на самом деле являются вариантами одного и того же экшна.

Фактически в методе BooksController, в экшне edit, в котором мы хотим отрендерить шаблон edit, если книга не была успешно обновлена, все нижеследующие вызовы отрендерят шаблон `edit.html.erb` в директории `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render "edit.html.erb"
render action: "edit"
render action: "edit.html.erb"
render "books/edit"
render "books/edit.html.erb"
render template: "books/edit"
render template: "books/edit.html.erb"
render "/path/to/rails/app/views/books/edit"
render "/path/to/rails/app/views/books/edit.html.erb"
render file: "/path/to/rails/app/views/books/edit"
render file: "/path/to/rails/app/views/books/edit.html.erb"
```

Какой из них вы будете использовать - это вопрос стиля и соглашений, но практическое правило заключается в использовании простейшего, которое имеет смысл для кода и написания.

#### Использование `render` с `:inline`

Метод `render` вполне может обойтись без вьюхи, если вы используете опцию `:inline` для поддержки ERB, как части вызова метода.  Это вполне валидно:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

WARNING: Должно быть серьезное основание для использования этой опции. Вкрапление ERB в контроллер нарушает MVC ориентированность Rails и создает трудности для других разработчиков в следовании логике вашего проекта. Вместо этого используйте отдельную erb-вьюху.

По умолчанию встроенный рендеринг использует ERb. Можете принудить использовать вместо этого Builder с помощью опции `:type`:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### Рендеринг текста

Вы можете послать простой текст - совсем без разметки - обратно браузеру с использованием опции `:text` в `render`:

```ruby
render text: "OK"
```

TIP: Рендеринг чистого текста наиболее полезен, когда вы делаете Ajax отклик, или отвечаете на запросы веб-сервиса, ожидающего что-то иное, чем HTML.

NOTE: По умолчанию при использовании опции `:text` текст рендерится без использования текущего макета. Если хотите, чтобы Rails вложил текст в текущий макет, необходимо добавить опцию `layout: true`

#### Рендеринг JSON

JSON - это формат данных javascript, используемый многими библиотеками Ajax. Rails имеет встроенную поддержку для конвертации объектов в JSON и рендеринга этого JSON браузеру:

```ruby
render json: @product
```

TIP: Не нужно вызывать `to_json` в объекте, который хотите рендерить. Если используется опция `:json`, `render` автоматически вызовет `to_json` за вас.

#### Рендеринг XML

Rails также имеет встроенную поддержку для конвертации объектов в XML и рендеринга этого XML для вызывающего:

```ruby
render xml: @product
```

TIP: Не нужно вызывать `to_xml` в объекте, который хотите рендерить. Если используется опция `:xml`, `render` автоматически вызовет `to_xml` за вас.

#### Рендеринг внешнего JavaScript

Rails может рендерить чистый JavaScript:

```ruby
render js: "alert('Hello Rails');"
```

Это пошлет указанную строку в браузер с типом MIME `text/javascript`.

#### Опции для `render`

Вызов метода `render` как правило принимает четыре опции:

* `:content_type`
* `:layout`
* `:status`
* `:location`

##### Опция `:content_type`

По умолчанию Rails укажет результатам операции рендеринга тип содержимого MIME `text/html` (или `application/json` если используется опция `:json`, или `application/xml` для опции `:xml`). Иногда бывает так, что вы хотите изменить это, и тогда можете настроить опцию `:content_type`:

```ruby
render file: filename, content_type: "application/rss"
```

##### Опция `:layout`

С большинством опций для `render`, отрендеренное содержимое отображается как часть текущего макета. Вы узнаете более подробно о макетах, и как их использовать, позже в этом руководстве.

Опция `:layout` нужна, чтобы сообщить Rails использовать определенный файл как макет для текущего экшна:

```ruby
render layout: "special_layout"
```

Также можно сообщить Rails рендерить вообще без макета:

```ruby
render layout: false
```

h6. Опция `:status`

Rails автоматически сгенерирует отклик с корректным кодом статуса HTML (в большинстве случаев равный `200 OK`). Опцию `:status` можно использовать, чтобы изменить это:

```ruby
render status: 500
render status: :forbidden
```

##### Опция `:location`

Опцию `:location` можно использовать, чтобы установить заголовок HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### Поиск макетов

Чтобы найти текущий макет, Rails сначала смотрит файл в `app/views/layouts` с именем, таким же, как имя контроллера. Например, рендеринг экшнов из класса `PhotosController` будет использовать `/app/views/layouts/photos.html.erb` (или `app/views/layouts/photos.builder`). Если такого макета нет, Rails будет использовать `/app/views/layouts/application.html.erb` или `/app/views/layouts/application.builder`. Если нет макета `.erb`, Rails будет использовать макет `.builder`, если таковой имеется. Rails также предоставляет несколько способов более точно назначить определенные макеты отдельным контроллерам и экшнам.

##### Определение макетов для контроллеров

Вы можете переопределить дефолтные соглашения по макетам в контроллере, используя объявление `layout`. Например:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

С этим объявлением все вьюхи, рендеренные контроллером products, будут использовать `app/views/layouts/inventory.html.erb` как макет.

Чтобы привязать определенный макет к приложению в целом, используйте объявление в классе `ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

С этим объявлением каждая из вьюх во всем приложении будет использовать `app/views/layouts/main.html.erb` как макет.

##### Выбор макетов во время выполнения

Можете использовать символ для отсрочки выбора макета до тех пор, пока не будет произведен запрос:

```ruby
class ProductsController < ApplicationController
  layout "products_layout"

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end

end
```

Теперь, если текущий пользователь является специальным, он получит специальный макет при просмотре продукта.

Можете даже использовать вложенный метод, такой как Proc, для определения макета. Например, если передать объект Proc, то блок, переданный в Proc, будет передан в экземпляр `контроллера`, таким образом макет может быть определен, основываясь на текущем запросе:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Условные макеты

Макеты, определенные на уровне контроллера, поддерживают опции `:only` и `:except`. Эти опции принимают либо имя метода, либо массив имен методов, соответствующих именам методов в контроллере:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

С таким объявлением макет `product` будет использован везде, кроме методов `rss` и `index`.

##### Наследование макета

Объявления макетов участвуют в иерархии, и более определенное объявление макета всегда переопределяет более общие. Например:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `posts_controller.rb`

    ```ruby
    class PostsController < ApplicationController
    end
    ```

* `special_posts_controller.rb`

    ```ruby
    class SpecialPostsController < PostsController
      layout "special"
    end
    ```

* `old_posts_controller.rb`

    ```ruby
    class OldPostsController < SpecialPostsController
      layout false

      def show
        @post = Post.find(params[:id])
      end

      def index
        @old_posts = Post.older
        render layout: "old"
      end
      # ...
    end
    ```

В этом приложении:

* В целом, вьюхи будут рендериться в макет `main`
* `PostsController#index` будет использовать макет `main`
* `SpecialPostsController#index` будет использовать макет `special`
* `OldPostsController#show` не будет использовать макет совсем
* `OldPostsController#index` будет использовать макет `old`

#### Избегание ошибок двойного рендера

Рано или поздно, большинство разработчиков на Rails увидят сообщение об ошибке "Can only render or redirect once per action". Хоть такое и раздражает, это относительно просто правится. Обычно такое происходит в связи с фундаментальным непониманием метода работы `render`.

Например, вот некоторый код, который вызовет эту ошибку:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Если `@book.special?` определяется как `true`, Rails начинает процесс рендеринга, выгружая переменную `@book` во вьюху `special_show`. Но это _не_ остановит от выполнения остальной код в экшне `show`, и когда Rails достигнет конца экшна, он начнет рендерить вьюху `show` - и выдаст ошибку. Решение простое: убедитесь, что у вас есть только один вызов `render` или `redirect` за один проход. Еще может помочь такая вещь, как `and return`. Вот исправленная версия метода:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

Убедитесь, что используете `and return` вместо `&& return`, поскольку `&& return` не будет работать в связи с приоритетом операторов в языке Ruby.

Отметьте, что неявный рендер, выполняемый ActionController, определяет, был ли вызван `render` поэтому следующий код будет работать без проблем:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

Это отрендерит книгу с заданным `special?` с помощью шаблона `special_show`, в то время как остальные книги будут рендериться с дефолтным шаблоном `show`.

В [продолжении](/layouts-and-rendering-in-rails/creating-responses-2) будут раскрыты вопросы использования `redirect_to` и `head`
