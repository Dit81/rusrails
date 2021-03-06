class Admin::CategoriesController < Puffer::Base

  setup do
    group :pages
  end

  index do
    field :name
    field :url_match
    field :text
    field :enabled
    field :show_order
  end

  form do
    field :name
    field :url_match
    field :text
    field :enabled
    field :show_order
  end

end
