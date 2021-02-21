# frozen_string_literal: true
class UpdateArticleAction < Upgrow::Action
  result :article

  def perform(id, input)
    if input.valid?
      article = ArticleRepository.new.update(id, input)
      result.success(article: article)
    else
      result.failure(input.errors)
    end
  end
end
