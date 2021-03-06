# Изменение существующих миграций

Периодически вы будете делать ошибки при написании миграции. Если вы уже запустили миграцию, вы не сможете просто отредактировать миграцию и запустить ее снова: Rails посчитает, что он уже выполнял миграцию, и ничего не сделает при запуске `rake db:migrate`. Вы должны откатить миграцию (например, с помощью `rake db:rollback`), отредактировать миграцию и затем запустить `rake db:migrate` для запуска исправленной версии.

В целом, редактирование существующих миграций не хорошая идея. Вы создадите дополнительную работу себе и своим коллегам, и вызовете море головной боли, если существующая версия миграции уже была запущена в production. Вместо этого, следует написать новую миграцию, выполняющую требуемые изменения. Редактирование только что созданной миграции, которая еще не была закомичена в систему контроля версий (или, хотя бы, не ушла дальше вашей рабочей машины) относительно безвредно.

Метод `revert` может быть очень полезным при написании новой миграции для возвращения предыдущей в целом или какой то части (смотрите [Возвращение к предыдущим миграциям](https://github.com/morsbox/rusrails/blob/4.0/source/01-rails-database-migrations/2-writing-a-migration.md)
