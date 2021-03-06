# Заголовки по умолчанию

Каждый отклик HTTP от приложения Rails получает следующие заголовки безопасности по умолчанию.

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-XSS-Protection' => '1; mode=block',
  'X-Content-Type-Options' => 'nosniff'
}
```

Можно настроить заголовки по умолчанию в `config/application.rb`.

```ruby
config.action_dispatch.default_headers = {
  'Header-Name' => 'Header-Value',
  'X-Frame-Options' => 'DENY'
}
```

Или можно убрать их.

```ruby
config.action_dispatch.default_headers.clear
```

Вот список обычных заголовков:

- X-Frame-Options := _'SAMEORIGIN' по умолчанию в Rails_ - позволяет фрейминг на тот же домен. Установите 'DENY' для запрета фрейминга или 'ALLOWALL', если хотите разрешить фрейминг на все вебсайты.

- X-XSS-Protection := _'1; mode=block' по умолчанию в Rails_ - использовать XSS Auditor и блокировать страницу, если обнаружена атака XSS. Установите его '0;', если хотите отключить XSS Auditor (полезно, если отклик содержит скрипты из параметров запроса)

- X-Content-Type-Options := _'nosniff' по умолчанию в Rails_ - останавливает браузер от угадывания типа MIME файла.

- X-Content-Security-Policy := [Мощный механизм для контроля с каких сайтов может быть загружен определенный контент](http://dvcs.w3.org/hg/content-security-policy/raw-file/tip/csp-specification.dev.html)

- Access-Control-Allow-Origin := Используется для контроля, каким сайтам позволено проходить правило ограничения домена и посылать межсайтовые запросы.

- Strict-Transport-Security := [Используется для контроля, разрешен ли браузеру доступ к сайту только через безопасное соединение](http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security)
