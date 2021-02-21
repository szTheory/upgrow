# frozen_string_literal: true
class ArticleInput < Upgrow::Input
  attr_accessor :title, :body

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
