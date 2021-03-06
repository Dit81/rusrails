# Интеграционное тестирование

Интеграционные тесты используются для тестирования взаимодействия любого числа контроллеров. Они в основном используются для тестирования важных рабочих процессов в вашем приложении.

В отличие от юнит- и функциональных тестов, интеграционные тесты должны быть явно созданы в папке 'test/integration' вашего приложения. Rails предоставляет вам генератор для создания скелета интеграционного теста.

```bash
$ rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Вот как выглядит вновь созданный интеграционный тест:

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  fixtures :all

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
```

Интеграционные тесты унаследованы от `ActionController::IntegrationTest`. Это делает доступным несколько дополнительных хелперов для использования в ваших интеграционных тестах. Также необходимо явно включать фикстуры, чтобы сделать их доступными для теста.

### Хелперы, доступные для интеграционных тестов

В дополнение к стандартным хелперам тестирования, есть несколько дополнительных хелперов, доступных для интеграционных тестов:

| Хелпер                                                             | Назначение                                                                         |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `https?`                                                           | Возвращает `true`, если сессия имитирует безопасный запрос HTTPS.                  |
| `https!`                                                           | Позволяет имитировать безопасный запрос HTTPS.                                     |
| `host!`                                                            | Позволяет установить имя хоста для использовании в следующем запросе.              |
| `redirect?`                                                        | Возвращает `true`, если последний запрос был перенаправлением.                     |
| `follow_redirect!`                                                 | Отслеживает одиночный перенаправляющий отклик.                                     |
| `request_via_redirect(http_method, path, [parameters], [headers])` | Позволяет сделать HTTP запрос и отследить любые последующие перенаправления.       |
| `post_via_redirect(path, [parameters], [headers])`                 | Позволяет сделать HTTP запрос POST и отследить любые последующие перенаправления.  |
| `get_via_redirect(path, [parameters], [headers])`                  | Позволяет сделать HTTP запрос GET и отследить любые последующие перенаправления.   |
| `patch_via_redirect(path, [parameters], [headers])`                | Позволяет сделать HTTP запрос PATCH и отследить любые последующие перенаправления. |
| `put_via_redirect(path, [parameters], [headers])`                  | Позволяет сделать HTTP запрос PUT и отследить любые последующие перенаправления.   |
| `delete_via_redirect(path, [parameters], [headers])`               | Позволяет сделать HTTP запрос DELETE и отследить любые последующие перенаправления.|
| `open_session`                                                     | Открывает экземпляр новой сессии.                                                  |

### Примеры интеграционного тестирования

Простой интеграционный тест, использующий несколько контроллеров:

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "login and browse site" do
    # login via https
    https!
    get "/login"
    assert_response :success

    post_via_redirect "/login", username: users(:avs).username, password: users(:avs).password
    assert_equal '/welcome', path
    assert_equal 'Welcome avs!', flash[:notice]

    https!(false)
    get "/posts/all"
    assert_response :success
    assert assigns(:products)
  end
end
```

Как видите, интеграционный тест вовлекает несколько контроллеров и использует весь стек от базы данных до отправителя. В дополнение можете иметь несколько экземпляров сессии, открытых одновременно в тесте, и расширить эти экземпляры с помощью методов контроля для создания очень мощного тестирующего DSL (Предметно-ориентированного языка программирования) только для вашего приложения.

Вот пример нескольких сессий и собственного DSL в общем тесте

```ruby
require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "login and browse site" do

    # User avs logs in
    avs = login(:avs)
    # User guest logs in
    guest = login(:guest)

    # Both are now available in different sessions
    assert_equal 'Welcome avs!', avs.flash[:notice]
    assert_equal 'Welcome guest!', guest.flash[:notice]

    # User avs can browse site
    avs.browses_site
    # User guest can browse site as well
    guest.browses_site

    # Continue with other assertions
  end

  private

  module CustomDsl
    def browses_site
      get "/products/all"
      assert_response :success
      assert assigns(:products)
    end
  end

  def login(user)
    open_session do |sess|
      sess.extend(CustomDsl)
      u = users(user)
      sess.https!
      sess.post "/login", username: u.username, password: u.password
      assert_equal '/welcome', path
      sess.https!(false)
    end
  end
end
```
