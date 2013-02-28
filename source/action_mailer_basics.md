Основы Action Mailer
====================

Это руководство предоставит вам все, что нужно для того, чтобы посылать и получать электронную почту в вашем приложении, и раскроет множество внутренних методов Action Mailer. Оно также раскроет, как тестировать ваши рассыльщики.

После прочтения этого руководства, вы узнаете:

* Как отправлять и получать письма в приложении Rails.
* Как создавать и редактировать класс Action Mailer и вьюху рассыльщика.
* Как настраивать Action Mailer для своей среды.
* Как тестировать свои классы Action Mailer.

Action Mailer позволяет отправлять электронные письма из вашего приложения, используя модель и вьюхи рассыльщика. Таким образом, в Rails электронная почта используется посредством создание рассыльщиков, наследуемых от `ActionMailer::Base`, и находящихся в `app/mailers`. Эти рассыльщики имеют связанные вьюхи, которые находятся среди вьюх контроллеров в `app/views`.

Отправка электронной почты
--------------------------

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

Получение электронной почты
---------------------------

Получение и парсинг электронной почты с помощью Action Mailer может быть довольно сложным делом. До того, как электронная почта достигнет ваше приложение на Rails, нужно настроить вашу систему, чтобы каким-то образом направлять почту в приложение, которому нужно быть следящим за ней. Таким образом, чтобы получать электронную почту в приложении на Rails, нужно:

* Реализовать метод `receive` в вашем рассыльщике.

* Настроить ваш почтовый сервер для направления почты от адресов, желаемых к получению вашим приложением, в `/path/to/app/bin/rails runner 'UserMailer.receive(STDIN.read)'`.

Как только метод, названный `receive`, определяется в каком-либо рассыльщике, Action Mailer будет парсить сырую входящую почту в объект email, декодировать его, создавать экземпляр нового рассыльщика и передавать объект email в метод экземпляра рассыльщика `receive`. Вот пример:

```ruby
class UserMailer < ActionMailer::Base
  def receive(email)
    page = Page.find_by_address(email.to.first)
    page.emails.create(
      subject: email.subject,
      body: email.body
    )

    if email.has_attachments?
      email.attachments.each do |attachment|
        page.attachments.create({
          file: attachment,
          description: email.subject
        })
      end
    end
  end
end
```

Колбэки Action Mailer
---------------------

Action Mailer позволяет определить `before_action`, `after_action` и 'around_action'.

* Фильтры могут быть определены в блоке или сиволом с именем метода рассыльщика, подобно контроллерам.

* `before_action` можно использовать для предварительного заполнения объекта mail значениями по умолчанию, delivery_method_options или вставки заголовков по умолчанию и вложений.

* `after_action` можно использовать для подобной настройки, как и в `before_action`, но используя переменные экземпляра, установленные в экшне рассыльщика.

```ruby
class UserMailer < ActionMailer::Base
  after_action :set_delivery_options, :prevent_delivery_to_guests, :set_business_headers

  def feedback_message(business, user)
    @business = business
    @user = user
    mail
  end

  def campaign_message(business, user)
    @business = business
    @user = user
  end

  private

  def set_delivery_options
    # Тут у вас есть доступ к экземпляру mail и переменным экземпляра @business и @user
    if @business && @business.has_smtp_settings?
      mail.delivery_method.settings.merge!(@business.smtp_settings)
    end
  end

  def prevent_delivery_to_guests
    if @user && @user.guest?
      mail.perform_deliveries = false
    end
  end

  def set_business_headers
    if @business
      headers["X-SMTPAPI-CATEGORY"] = @business.code
    end
  end
end
```

* Фильтры рассыльщика прерывают дальнейшую обработку, если body установлено в не-nil значение.

Использование хелперов Action Mailer
------------------------------------

Action Mailer теперь всего лишь наследуется от Abstract Controller, поэтому у вас есть доступ к тем же общим хелперам, как и в Action Controller.

Настройка Action Mailer
-----------------------

Следующие конфигурационные опции лучше всего делать в одном из файлов среды разработки (environment.rb, production.rb, и т.д...)

| Конфигурация            | Описание |
| ----------------------- | -------- |
| `template_root`         | Определяет основу, от которой будут делаться ссылки на шаблоны.|
| `logger`                | logger исользуется для создания информации на ходу, если возможно. Можно установить как `nil` для отсутствия логирования. Совместим как с `Logger` в Ruby, так и с логером `Log4r`.|
| `smtp_settings`         | Позволяет подробную настройку для метода доставки `:smtp`:<ul><li>`:address` - Позволяет использовать удаленный почтовый сервер. Просто измените его изначальное значение "localhost".</li><li>`:port`  - В случае, если ваш почтовый сервер не работает с 25 портом, можете изменить его.</li><li>`:domain` - Если необходимо определить домен HELO, это можно сделать здесь.</li><li>`:user_name` - Если почтовый сервер требует аутентификацию, установите имя пользователя этой настройкой.</li><li>`:password` - Если почтовый сервер требует аутентификацию, установите пароль этой настройкой. </li><li>`:authentication` - Если почтовый сервер требует аутентификацию, здесь нужно определить тип аутентификации. Это один из символов `:plain`, `:login`, `:cram_md5`.</li><li>`:enable_starttls_auto` - Установите его в `false` если есть проблема с сертификатом сервера, которую вы не можете решить.</li></ul>|
| `sendmail_settings`     | Позволяет переопределить опции для метода доставки `:sendmail`.<ul><li>`:location` - Расположение исполняемого sendmail. По умолчанию `/usr/sbin/sendmail`.</li><li>`:arguments` - Аргументы командной строки. По умолчанию `-i -t`.</li></ul>|
| `raise_delivery_errors` | Должны ли быть вызваны ошибки, если email не может быть доставлен. Это работает, если внешний сервер email настроен на немедленную доставку.|
| `delivery_method`       | Определяет метод доставки. Возможные значения `:smtp` (по умолчанию), `:sendmail`, `:file` и `:test`.|
| `perform_deliveries`    | Определяет, должны ли методы deliver_* фактически выполняться. По умолчанию должны, но это можно отключить для функционального тестирования.|
| `deliveries`            | Содержит массив всех электронных писем, отправленных через Action Mailer с помощью delivery_method :test. Очень полезно для юнит- и функционального тестирования.|
| `default_options`       | Позволит вам установить значения по умолчанию для опций метода `mail` (`:from`, `:reply_to` и т.д.).|

### Пример настройки Action Mailer

Примером может быть добавление следующего в подходящий файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i -t'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-replay@example.org'}
```

### Настройка Action Mailer для GMail

Action Mailer теперь использует гем Mail, теперь это сделать просто, нужно добавить в файл `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
+  port:                 587,
+  domain:               'baci.lindsaar.net',
+  user_name:            '<username>',
+  password:             '<password>',
+  authentication:       'plain',
+  enable_starttls_auto: true  }
```

Тестирование рассыльщика
------------------------

По умолчанию Action Mailer не посылает электронные письма в среде разработки test. Они всего лишь добавляются к массиву `ActionMailer::Base.deliveries`.

Тестирование рассыльщиков обычно включает две вещи: Первая это то, что письмо помещается в очередь, а вторая это то, что письмо правильное. Имея это в виду, можем протестировать наш пример рассыльщика из предыдущих статей таким образом:

```ruby
class UserMailerTest < ActionMailer::TestCase
  def test_welcome_email
    user = users(:some_user_in_your_fixtures)

    # Посылаем email, затем тестируем, если оно не попало в очередь
    email = UserMailer.welcome_email(user).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Тестируем, содержит ли тело посланного email то, что мы ожидаем
    assert_equal [user.email], email.to
    assert_equal 'Welcome to My Awesome Site', email.subject
    assert_match "<h1>Welcome to example.com, #{user.name}</h1>", email.body.to_s
    assert_match 'you have joined to example.com community', email.body.to_s
  end
end
```

В тесте мы посылаем email и храним возвращенный объект в переменной `email`. Затем мы убеждаемся, что он был послан (первый assert), затем, во второй группе операторов контроля, мы убеждаемся, что email действительно содержит то, что мы ожидаем.
