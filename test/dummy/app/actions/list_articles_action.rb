# frozen_string_literal: true
class ListArticlesAction < Upgrow::Action
  result :articles

  def perform
    result.success(articles: ArticleRepository.new.all)
  end
end
