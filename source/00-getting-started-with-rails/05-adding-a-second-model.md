# Добавляем вторую модель

Настало время добавить вторую модель в приложение. Вторая модель будет управлять комментариями на публикации блога.

### Генерируем модель

Мы намереваемся использовать тот же генератор, что мы использовали ранее при создании модели `Post`. В этот раз мы создадим модель `Comment`, содержащую комментарии к публикации. Запустите следующую команду в терминале:

```bash
$ rails generate model Comment commenter:string body:text post:references
```

Эта команда создаст четыре файла:

| Файл                                        | Назначение |
|---------------------------------------------|------------|
|db/migrate/20100207235629_create_comments.rb | Миграция для создания таблицы comments в вашей базе данных (ваше имя файла будет включать другую временную метку) |
| app/models/comment.rb                       | Модель Comment |
| test/models/comment_test.rb                 | Каркас для тестирования модели комментариев |
| test/fixtures/comments.yml                  | Образцы комментариев для использования в тестировании |

Сначала взглянем на `app/models/comment.rb`:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end
```

Это очень похоже на модель `post.rb`, которую мы видели ранее. Разница в строке `belongs_to :post`, которая устанавливает _связь_ Active Record. Вы ознакомитесь со связями в следующем разделе руководства.

В дополнение к модели, Rails также сделал миграцию для создания соответствующей таблицы базы данных:

```ruby
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :post

      t.timestamps
    end

    add_index :comments, :post_id
  end
end
```

Строка `t.references` устанавливает столбец внешнего ключа для связи между двумя моделями. А строка `add_index` настраивает индексирование для этого столбца связи. Далее запускаем миграцию:

```bash
$ rake db:migrate
```

Rails достаточно сообразителен, чтобы запускать только те миграции, которые еще не были запущены для текущей базы данных, в нашем случае Вы увидите:

```bash
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0008s
-- add_index(:comments, :post_id)
   -> 0.0003s
==  CreateComments: migrated (0.0012s) ========================================
```

### Связываем модели

Связи Active Record позволяют Вам легко объявлять отношения между двумя моделями. В случае с комментариями и публикациями, Вы можете описать отношения следующим образом:

* Каждый комментарий принадлежит одной публикации.
* Одна публикация может иметь много комментариев.

Фактически, это очень близко к синтаксису, который использует Rails для объявления этой связи. Вы уже видели строку кода в модели `Comment` (app/models/comment.rb), которая делает каждый комментарий принадлежащим публикации:

```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end
```

Вам нужно отредактировать `app/models/post.rb`, добавив другую сторону связи:

```ruby
class Post < ActiveRecord::Base
  has_many :comments
  validates :title, presence: true,
                    length: { minimum: 5 }
  [...]
end
```

Эти два объявления автоматически делают доступным большое количество возможностей. Например, если у вас есть переменная экземпляра `@post`, содержащая публикацию, вы можете получить все комментарии, принадлежащие этой публикации, в массиве, вызвав `@post.comments`.

TIP: Более подробно о связях Active Record смотрите руководство [Связи Active Record](/active-record-associations).

### Добавляем маршрут для комментариев

Как в случае с контроллером `welcome`, нам нужно добавить маршрут, чтобы Rails знал, по какому адресу мы хотим пройти, чтобы увидеть `комментарии`. Снова откройте файл `config/routes.rb` и отредактируйте его следующим образом:

```ruby
resources :posts do
  resources :comments
end
```

Это создаст `comments` как _вложенный ресурс_ в `posts`. Это другая сторона захвата иерархических отношений, существующих между публикациями и комментариями.

TIP: Более подробно о роутинге написано в руководстве [Роутинг в Rails](/rails-routing).

### Генерируем контроллер

Имея модель, обратим свое внимание на создание соответствующего контроллера. Снова будем использовать то же генератор, что использовали прежде:

```bash
$ rails generate controller Comments
```

Создадутся шесть файлов и пустая директория:

| Файл/Директория                              | Назначение                                |
|--------------------------------------------- |-------------------------------------------|
| app/controllers/comments_controller.rb       | Контроллер Comments                       |
| app/views/comments/                          | Вьюхи контроллера хранятся здесь          |
| test/controllers/comments_controller_test.rb | Тест для контроллера                      |
| app/helpers/comments_helper.rb               | Хелпер для вьюх                           |
| test/unit/helpers/comments_helper_test.rb    | Юнит-тесты для хелпера                    |
| app/assets/javascripts/comment.js.coffee     | CoffeeScript для контроллера              |
| app/assets/stylesheets/comment.css.scss      | Каскадная таблица стилей для контроллера  |

Как и в любом другом блоге, наши читатели будут создавать свои комментарии сразу после прочтения публикации, и после добавления комментария они будут направляться обратно на страницу отображения публикации и видеть, что их комментарий уже отражен. В связи с этим, наш `CommentsController` служит как средство создания комментариев и удаления спама, если будет.

Сначала мы расширим шаблон Post show (`app/views/posts/show.html.erb`), чтобы он позволял добавить новый комментарий:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @post.text %>
</p>

<h2>Add a comment:</h2>
<%= form_for([@post, @post.comments.build]) do |f| %>
  <p>
    <%= f.label :commenter %><br />
    <%= f.text_field :commenter %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>

<%= link_to 'Edit Post', edit_post_path(@post) %> |
<%= link_to 'Back to Posts', posts_path %>
```

Это добавит форму на страницу отображения публикации, создающую новый комментарий при вызове экшна `create` в `CommentsController`. Тут вызов `form_for` использует массив, что создаст вложенный маршрут, такой как `/posts/1/comments`.

Давайте напишем `create` в `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(params[:comment])
    redirect_to post_path(@post)
  end
end
```

Тут все немного сложнее, чем вы видели в контроллере для публикаций. Это побочный эффект вложения, которое вы настроили. Каждый запрос к комментарию отслеживает публикацию, к которой комментарий присоединен, таким образом сначала решаем вопрос с получением публикации, вызвав `find` на модели `Post`.

Кроме того, код пользуется преимуществом некоторых методов, доступных для связей. Мы используем метод `create` на `@post.comments`, чтобы создать и сохранить комментарий. Это автоматически связывает комментарий так, что он принадлежит к определенной публикации.

Как только мы создали новый комментарий, мы возвращаем пользователя обратно на оригинальную публикацию, используя хелпер `post_path(@post)`. Как мы уже видели, он вызывает экшн `show` в `PostsController`, который, в свою очередь, рендерит шаблон `show.html.erb`. В этом месте мы хотим отображать комментарии, поэтому давайте добавим следующее в `app/views/posts/show.html.erb`.

```html+erb
<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @post.text %>
</p>

<h2>Comments</h2>
<% @post.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_for([@post, @post.comments.build]) do |f| %>
  <p>
    <%= f.label :commenter %><br />
    <%= f.text_field :commenter %>
  </p>
  <p>
    <%= f.label :body %><br />
    <%= f.text_area :body %>
  </p>
  <p>
    <%= f.submit %>
  </p>
<% end %>

<%= link_to 'Edit Post', edit_post_path(@post) %> |
<%= link_to 'Back to Posts', posts_path %>
```

Теперь в вашем блоге можно добавлять публикации и комментарии и отображать их в нужных местах.

![Публикация с комментариями](/assets/guides/getting_started/post_with_comments.png)
