# frozen_string_literal: true

class ArticlesController < ApplicationController
  def index
    @articles = ListArticlesAction.new.perform.articles
  end

  def show
    @article = ShowArticleAction.new.perform(params[:id]).article
  end

  def new
    @input = ArticleInput.new
  end

  def edit
    article = EditArticleAction.new.perform(params[:id]).article
    @input = ArticleInput.new(
      title: article.title, body: article.body
    )
  end

  def create
    @input = ArticleInput.new(article_params)

    CreateArticleAction.new.perform(@input)
      .and_then do |article|
        redirect_to(
          article_path(article.id), notice: 'Article was successfully created.'
        )
      end
      .or_else do |errors|
        @errors = errors
        render(:new)
      end
  end

  def update
    @input = ArticleInput.new(article_params)

    UpdateArticleAction.new.perform(params[:id], @input)
      .and_then do |article|
        redirect_to(
          article_path(article.id),
          notice: 'Article was successfully updated.'
        )
      end
      .or_else do |errors|
        @errors = errors
        render(:edit)
      end
  end

  def destroy
    DeleteArticleAction.new.perform(params[:id])
    redirect_to(articles_url, notice: 'Article was successfully destroyed.')
  end

  private

  def article_params
    params.require(:article_input).permit(:title, :body)
  end
end
