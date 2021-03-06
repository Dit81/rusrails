# Фильтры

Фильтры - это методы, которые запускаются до, после или "вокруг" экшна контроллера.

Фильтры наследуются, поэтому, если вы установите фильтр в `ApplicationController`, он будет запущен в каждом контроллере вашего приложения.

Фильтры "before" могут прерывать цикл запроса. Обычный фильтр "before" это, например, тот, который требует, чтобы пользователь был авторизован для запуска экшна. Метод фильтра можно определить следующим образом:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url # прерывает цикл запроса
    end
  end

  # метод logged_in? просто возвращает true если пользователь авторизован,
  # и false в противном случае. Это так называемый "booleanizing"
  # к методу current_user, который мы создали ранее, применили двойной !
  # оператор. Отметьте, что это не обычно для Ruby и не рекомендуется, если
  # Вы действительно не хотите конвертировать что-либо в true или false.
  def logged_in?
    !!current_user
  end
end
```

Метод просто записывает сообщение об ошибке во flash и перенаправляет на форму авторизации, если пользователь не авторизовался. Если фильтр "before" рендерит или перенаправляет, экшн не запустится. Если есть дополнительные фильтры в очереди, они также прекращаются.

В этом примере фильтр добавлен в `ApplicationController`, и поэтому все контроллеры в приложении наследуют его. Это приводит к тому, что всё в приложении требует, чтобы пользователь был авторизован, чтобы пользоваться им. По понятным причинам (пользователь не сможет зарегистрироваться в первую очередь!), не все контроллеры или экшны должны требовать его. Вы можете не допустить запуск этого фильтра перед определенными экшнами с помощью `skip_before_action`:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Теперь, экшны `LoginsController` `new` и `create` будут работать как раньше, без требования к пользователю быть зарегистрированным. Опция `:only` используется для пропуска фильтра только для этих экшнов, также есть опция `:except`, которая работает наоборот. Эти опции могут также использоваться при добавлении фильтров, поэтому можете добавить фильтр, который запускается только для выбранных экшнов в первую очередь.

### Последующие фильтры и охватывающие фильтры

В дополнение к фильтрам "before", можете запустить фильтры после того, как экшн был запущен, или и до, и после.

Фильтр "after" подобен "before", но, поскольку экшн уже был запущен, у него есть доступ к данным отклика, которые будут отосланы клиенту. Очевидно, фильтр "after" не сможет остановить экшн от запуска.

Фильтры "around" ответственны за запуск экшна с помощью yield, подобно тому, как работают промежуточные программы Rack.

```ruby
class ChangesController < ActionController::Base
  around_action :wrap_in_transaction, only: :show

  private

  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      begin
        yield
      ensure
        raise ActiveRecord::Rollback
      end
    end
  end
end
```

Отметьте, что фильтры "around" также оборачивают рендеринг. В частности, если в вышеуказанном примере вьюха сама начнет считывать из базы данных (например через скоуп), она это осуществит внутри транзакции, предоставив, таким образом, данные для предварительного просмотра.

Можно не вызывать yield и создать отклик самостоятельно, в этом случае экшн не будет запущен.

### Другие способы использования фильтров

Хотя наиболее распространенный способ использование фильтров - это создание private методов и использование *_action для их добавления, есть два других способа делать то же самое.

Первый - это использовать блок прямо в методах *_action. Блок получает контроллер как аргумент, и вышеупомянутый фильтр `require_login` может быть переписан с использованием блока:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    redirect_to new_login_url unless controller.send(:logged_in?)
  end
end
```

Отметьте, что фильтр в этом случае использует метод `send`, так как `logged_in?` является private, и фильтр не запустится в области видимости контроллера. Это не рекомендуемый способ применения такого особого фильтра, но в простых задачах он может быть полезен.

Второй способ - это использовать класс (фактически, подойдет любой объект, реагирующий правильными методами) для управления фильтрацией. Это полезно для более сложных задач, которые не могут быть осуществлены предыдущими двумя способами по причине трудности читаемости и повторного использования. Как пример, можете переписать фильтр авторизации снова, использовав класс:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.filter(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "You must be logged in"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Опять же, это - не идеальный пример для этого фильтра, поскольку он не запускается в области видимости контроллера, а получает контроллер как аргумент. Класс фильтра имеет метод класса `filter`, который запускается до или после эшна, в зависимости от того, определен ли он предварительным или последующим фильтром. Классы, используемые как охватывающие фильтры, могут также использовать тот же метод `filter`, и они будет запущены тем же образом. Метод должен иметь `yield` для исполнения экшна. Альтернативно, он может иметь методы и `before`, и `after`, которые запускаются до и после экшна.
