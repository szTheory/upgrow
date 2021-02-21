# frozen_string_literal: true
class Article
  attr_reader :id, :title, :body, :created_at, :updated_at

  def initialize(id:, title:, body:, created_at:, updated_at:)
    @id = id
    @title = title
    @body = body
    @created_at = created_at
    @updated_at = updated_at
  end
end
