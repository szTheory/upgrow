# frozen_string_literal: true

Rails.application.routes.draw do
  resources :articles

  root 'articles#index'
end
