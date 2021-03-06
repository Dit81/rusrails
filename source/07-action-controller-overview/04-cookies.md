# Куки

Ваше приложение может хранить небольшое количество данных у клиента - в так называемых куки - которое будет сохранено между запросами и даже сессиями. Rails обеспечивает простой доступ к куки посредством метода `cookies`, который - очень похоже на `session` - работает как хэш:

```ruby
class CommentsController < ApplicationController
  def new
    # Автозаполнение имени комментатора, если оно хранится в куки.
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # Запоминаем имя комментатора.
        cookies[:commenter_name] = @comment.author
      else
        # Удаляем из куки имя комментатора, если оно есть.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Отметьте, что если для удаления сессии устанавливался ключ в `nil`, то для удаления значения куки следует использовать `cookies.delete(:key)`.
