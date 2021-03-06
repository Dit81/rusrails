# Отправка электронной почты

Этот раздел представляет пошаговое руководство по созданию рассыльщика и его вьюх.

### Пошаговое руководство по созданию рассыльщика

#### Создаем рассыльщик

```bash
$ rails generate mailer UserMailer
create  app/mailers/user_mailer.rb
invoke  erb
create    app/views/user_mailer
invoke  test_unit
create    test/mailers/user_mailer_test.rb
```

Таким образом мы получим рассыльщик, фикстуры и тесты.

#### Редактируем рассыльщик

`app/mailers/user_mailer.rb` содержит пустой рассыльщик:

```ruby
class UserMailer < ActionMailer::Base
  default from: 'from@example.com'
end
```

Давайте добавим метод, названный `welcome_email`, который будет посылать email на зарегистрированный адрес email пользователя:

```ruby
class UserMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: user.email, subject: 'Welcome to My Awesome Site')
  end

end
```

Вот краткое описание элементов, представленных в этом методе. Для полного списка всех доступных опций, обратитесь к [соответствующему разделу](#complete-list-of-action-mailer-user-settable-attributes).

* Хэш `default` - это хэш значений по умолчанию для любых рассылаемых вами email, в этом случае мы присваиваем заголовку `:from` значение для всех сообщений в этом классе, что может быть переопределено для отдельного письма
* `mail` - фактическое сообщение email, куда мы передаем заголовки `:to` и `:subject`.

Как и в контроллере, любые переменные экземпляра, определенные в методе, будут доступны для использования во вьюхе.

#### Создаем вьюху рассыльщика

Создадим файл, названный `welcome_email.html.erb` в `app/views/user_mailer/`. Это будет шаблоном, используемым для email, форматированным в HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Welcome to example.com, <%= @user.name %></h1>
    <p>
      You have successfully signed up to example.com,
      your username is: <%= @user.login %>.<br/>
    </p>
    <p>
      To login to the site, just follow this link: <%= @url %>.
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```

Также неплохо создать текстовую часть для этого email. Для этого создайте файл с именем `welcome_email.text.erb` в `app/views/user_mailer/`.

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```

Теперь при вызове метода `mail`, Action Mailer обнаружит два шаблона (text и HTML) и автоматически создаст `multipart/alternative` email.

#### Делаем так, что система отправляет письмо, когда пользователь регистрируется

Есть несколько способов сделать так: одни создают обсерверы Rails для отправки email, другие это делают внутри модели User. Однако, рассыльщики - это всего лишь другой способ отрендерить вьюху. Вместо рендеринга вьюхи и отсылки ее по протоколу HTTP, они всего лишь вместо этого отправляют ее по протоколам Email. Благодаря этому имеет смысл, чтобы контроллер сказал рассыльщику отослать письмо тогда, когда пользователь был успешно создан.

Настройка этого до безобразия проста.

Во первых, необходимо создать простой скаффолд `User`:

```bash
$ rails generate scaffold user name:string email:string login:string
$ rake db:migrate
```

Теперь, когда у нас есть модель user, с которой мы играем, надо всего лишь отредактировать `app/controllers/users_controller.rb`, чтобы поручить UserMailer доставлять email каждому вновь созданному пользователю, изменив экшн create и вставив вызов `UserMailer.welcome_email` сразу после того, как пользователь был успешно сохранен:

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # Tell the UserMailer to send a welcome Email after save
        UserMailer.welcome_email(@user).deliver

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

Это обеспечит более простую реализацию, не требующую регистрацию обсерверов и тому подобного.

Метод `welcome_email` возвращает объект <tt>Mail::Message</tt>, которому затем можно сказать `deliver`, чтобы он сам себя отослал.

### Автоматическое кодирование значений заголовка

Action Mailer теперь осуществляет автоматическое кодирование многобитных символов в заголовках и телах.

Если используете UTF-8 как набор символов, вам не нужно делать ничего особенного, просто отправьте данные в UTF-8 в поля адреса, темы, ключевых слов, имен файлов или тела письма, и Action Mailer автоматически закодирует их в подходящие для печати в случае поля заголовка или закодирует в Base64 любые части тела не в  US-ASCII.

Для более сложных примеров, таких, как определение альтернативных кодировок или самокодировок текста, обратитесь к библиотеке Mail.

### (complete-list-of-action-mailer-user-settable-attributes) Полный перечень методов Action Mailer

Имеется всего три метода, необходимых для рассылки почти любых сообщений email:

* `headers` - Определяет любой заголовок email. Можно передать хэш пар имен и значений полей заголовка, или можно вызвать `headers[:field_name] = 'value'`
* `attachments` - Позволяет добавить вложения в ваш email. Например, `attachments['file-name.jpg'] = File.read('file-name.jpg')`
* `mail` - Фактически отсылает сам email. Можете передать в headers хэш к методу mail как параметр, mail затем создаст email, или чистый текст, или multipart, в зависимости от определенных вами шаблонов email.

#### Произвольные заголовки

Определение произвольных заголовков простое, это можно сделать тремя способами:

* Определить поле заголовка как параметр в методе `mail`:

    ```ruby
    mail('X-Spam' => value)
    ```

* Передать в присвоении ключа в методе `headers`:

    ```ruby
    headers['X-Spam'] = value
    ```

* Передать хэш пар ключ-значение в методе `headers`:

    ```ruby
    headers {'X-Spam' => value, 'X-Special' => another_value}
    ```

TIP: Все заголовки `X-Value` в соответствии с RFC2822 могут появляться более одного раза. Если хотите удалить заголовок `X-Value`, присвойте ему значение `nil`.

#### Добавление вложений

Добавление вложений было упрощено в Action Mailer 3.0.

* Передайте имя файла и содержимое, и Action Mailer и гем Mail автоматически определят mime_type, установят кодировку и создадут вложение.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

NOTE: Mail автоматически кодирует вложение в Base64. Если хотите что-то иное, предварительно кодируйте свое содержимое и передайте в кодированном содержимом, и укажите кодировку в хэше в методе `attachments`.

* Передайте имя файла и определите заголовки и содержимое, и Action Mailer и Mail используют переданные вами настройки.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {mime_type: 'application/x-gzip',
                                   encoding: 'SpecialEncoding',
                                   content: encoded_content }
    ```

NOTE: Если указать кодировку, Mail будет полагать, что ваше содержимое уже кодировано в ней и не попытается кодировать в Base64.

#### Создание встроенных вложений

Action Mailer 3.0 создает встроенные вложения, которые вовлекали множество хаков в версиях до 3.0, более просто и обычно, так, как и должно было быть.

* Сначала, чтобы сказать Mail превратить вложения во встроенные вложения, надо всего лишь вызвать `#inline` на методе attachments в вашем рассыльщике:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Затем, во вьюхе можно просто сослаться на `attachments[]` как хэш и определить, какое вложение хотите отобразить, вызвав `url` на нем и затем передать результат в метод `image_tag`:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Так как это стандартный вызов `image_tag`, можно передать хэш опций после URL вложения, как это делается для любого другого изображения:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo',
                                                class: 'photos' %>
    ```

#### Рассылка Email нескольким получателям

Возможно отослать email одному и более получателям в одном письме (например, информируя всех админов о новой регистрации пользователя), настроив список адресов email в ключе `:to`. Перечень email может быть  массивом или отдельной строкой с адресами, разделенными запятыми.

```ruby
class AdminMailer < ActionMailer::Base
  default to: Proc.new { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```

Тот же формат может быть использован для назначения получателей копии (Cc:) и скрытой копии (Bcc:), при использовании ключей <tt>:cc</tt> и <tt>:bcc</tt> соответстенно.

#### Рассылка Email с именем

Иногда хочется показать имена людей вместо их электронных адресов, при получении ими email. Фокус в том, что формат адреса email следующий `"Name <email>"`.

```ruby
def welcome_email(user)
  @user = user
  email_with_name = "#{@user.name} <#{@user.email}>"
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
`end
```

### Вьюхи рассыльщика

Вьюхи рассыльщика расположены в директории `app/views/name_of_mailer_class`. Определенная вьюха рассыльщика известна классу, поскольку у нее имя такое же, как у метода рассыльщика. Так, в нашем примере, вьюха рассыльщика для метода `welcome_email` будет в `app/views/user_mailer/welcome_email.html.erb` для версии HTML и `welcome_email.text.erb` для обычной текстовой версии.

Чтобы изменить вьюху рассыльщика по умолчанию для вашего экшна, сделайте так:

```ruby
class UserMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: user.email,
         subject: 'Welcome to My Awesome Site',
         template_path: 'notifications',
         template_name: 'another')
  end

end
```

В этом случае он будет искать шаблон в `app/views/notifications` с именем `another`. Также можно определить массив путей для `template_path`, и они будут искаться в указанном порядке.

Если желаете большей гибкости, также возможно передать блок и рендерить определенный шаблон или даже рендерить вложенный код или текст без использования файла шаблона:

```ruby
class UserMailer < ActionMailer::Base
  default from: 'notifications@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render text: 'Render text' }
    end
  end

end
```

Это отрендерит шаблон 'another_template.html.erb' для HTML части и использует 'Render text' для текстовой части. Команда render та же самая, что используется в Action Controller, поэтому можете использовать те же опции, такие как `:text`, `:inline` и т.д.

### Макеты Action Mailer

Как и во вьюхах контроллера, можно также иметь макеты рассыльщика. Имя макета должно быть таким же, как у вашего рассыльщика, таким как `user_mailer.html.erb` и `user_mailer.text.erb`, чтобы автоматически распознаваться вашим рассыльщиком как макет.

Чтобы задействовать другой файл, просто используйте:

```ruby
class UserMailer < ActionMailer::Base
  layout 'awesome' # использовать awesome.(html|text).erb как макет
end
```

Подобно вьюхам контроллера, используйте `yield` для рендера вьюхи внутри макета.

Также можно передать опцию `layout: 'layout_name'` в вызов render в формате блока, чтобы определить различные макеты для различных действий:

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    mail(to: user.email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Отрендерит часть в HTML, используя файл `my_layout.html.erb`, и текстовую часть с обычным файлом `user_mailer.text.erb`, если он существует.

### Создаем URL во вьюхах Action Mailer

URL могут быть созданы во вьюхах рассыльщика, используя `url_for` или именнованные маршруты.

В отличие от контроллеров, экземпляр рассыльщика не может использовать какой-либо контекст относительно входящего запроса, поэтому необходимо предоставить `:host`, `:controller` и `:action`:

```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

При использовании именнованных маршрутов, необходимо предоставить только `:host`:

```erb
<%= user_url(@user, host: 'example.com') %>
```

У клиентов email отсутствует веб контекст, таким образом у путей нет базового URL для формирования полного веб адреса. Поэтому при использовании именнованных маршрутов имеет смысл только вариант "_url".

Также возможно установить хост по умолчанию, который будет использоваться во всех рассыльщиках, установив опцию `:host` как конфигурационную опцию в `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

При использовании этой настройки следует передать `only_path: false` при использовании `url_for`. Это обеспечит, что гнерируются абсолютные URL, так как хелпер вьюх `url_for` по умолчанию будет создавать относительные URL, когда явно не представлена опция `:host`.

### Рассылка multipart email

Action Mailer автоматически посылает multipart email, если имеются разные шаблоны для одного и того же экшна. Таким образом, для нашего примера UserMailer, если есть `welcome_email.text.erb` и `welcome_email.html.erb` в `app/views/user_mailer`, то Action Mailer автоматически пошлет multipart email с версиями HTML и текстовой, настроенными как разные части.

Порядок, в котором части будут вставлены, определяется `:parts_order` в методе `ActionMailer::Base.default`.

### Рассылка писем с вложениями

Вложения могут быть добавлены с помощью метода `attachments`:

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user)
    @user = user
    @url  = user_url(@user)
    attachments['terms.pdf'] = File.read('/path/terms.pdf')
    mail(to: user.email,
         subject: 'Please see the Terms and Conditions attached')
  end
end
```

Вышеописанное отошлет multipart email с правильно размещенным вложением, верхний уровень будет `multipart/mixed`, и первая часть будет `multipart/alternative`, содержащая сообщения email в чистом тексте и HTML.

### Рассылка писем с динамическими опциями доставки

Если хотите переопределить опции доставки по умолчанию (т. е. данные SMTP) во время доставки писем, можно использовать `delivery_method_options` в экшне рассыльщика.

```ruby
class UserMailer < ActionMailer::Base
  def welcome_email(user,company)
    @user = user
    @url  = user_url(@user)
    delivery_options = { user_name: company.smtp_user, password: company.smtp_password, address: company.smtp_host }
    mail(to: user.email, subject: "Please see the Terms and Conditions attached", delivery_method_options: delivery_options)
  end
end
```
