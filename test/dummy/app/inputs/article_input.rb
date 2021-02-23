# frozen_string_literal: true
ArticleInput = Upgrow::Input.new(:title, :body) do
  validates(:title, presence: true)
  validates(:body, presence: true, length: { minimum: 10 })
end
