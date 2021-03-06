# Рендеринг данных xml и json

ActionController позволяет очень просто рендерить данные `xml` или `json`. Если создадите контроллер с помощью скаффолдинга, то он будет выглядеть следующим образом.

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users}
      format.json { render json: @users}
    end
  end
end
```

Отметьте, что в вышеописанном коде `render xml: @users`, а не `render xml: @users.to_xml`. Это связано с тем, что если введена не строка, то rails автоматически вызовет `to_xml`.
