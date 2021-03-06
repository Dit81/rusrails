# Удаление комментариев

Другой важной особенностью блога является возможность удаления спама. Чтобы сделать это, нужно вставить некоторую ссылку во вьюхе и экшн `DELETE` в `CommentsController`.

Поэтому сначала добавим ссылку для удаления в партиал `app/views/comments/_comment.html.erb`:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>

<p>
  <%= link_to 'Destroy Comment', [comment.post, comment],
               method: :delete,
               data: { confirm: 'Are you sure?' } %>
</p>
```

Нажатие этой новой ссылки "Destroy Comment" запустит `DELETE /posts/:post_id/comments/:id` в нашем `CommentsController`, который затем будет использоваться для нахождения комментария, который мы хотим удалить, поэтому давайте добавим экшн destroy в наш контроллер (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.create(params[:comment])
    redirect_to post_path(@post)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post)
  end

end
```

Экшн `destroy` найдет публикацию, которую мы просматриваем, обнаружит комментарий в коллекции `@post.comments` и затем уберет его из базы данных и вернет нас обратно на просмотр публикации.

### Удаление связанных объектов

Если удаляете публикацию, связанные с ней комментарии также должны быть удалены. В ином случае они будут просто занимать место в базе данных. Rails позволяет использовать опцию `dependent` на связи для достижения этого. Измените модель Post, `app/models/post.rb`, следующим образом:

```ruby
class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  validates :title, presence: true,
                    length: { minimum: 5 }
  [...]
end
```
