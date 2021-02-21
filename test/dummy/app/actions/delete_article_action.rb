# frozen_string_literal: true
class DeleteArticleAction < Upgrow::Action
  def perform(id)
    ArticleRepository.new.delete(id)
    result.success
  end
end
