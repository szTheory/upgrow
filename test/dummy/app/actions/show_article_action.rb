# frozen_string_literal: true
class ShowArticleAction < Upgrow::Action
  result :article

  def perform(id)
    article = ArticleRepository.new.find(id)

    result.success(article: article)
  end
end
