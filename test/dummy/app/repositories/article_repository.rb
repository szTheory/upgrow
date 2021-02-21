# frozen_string_literal: true
class ArticleRepository
  def all
    ArticleRecord.all.map do |record|
      to_model(record.attributes)
    end
  end

  def create(input)
    record = ArticleRecord.create!(title: input.title, body: input.body)
    to_model(record.attributes)
  end

  def find(id)
    record = ArticleRecord.find(id)
    to_model(record.attributes)
  end

  def update(id, input)
    record = ArticleRecord.find(id)
    record.update!(title: input.title, body: input.body)
    to_model(record.attributes)
  end

  def delete(id)
    record = ArticleRecord.find(id)
    record.destroy!
  end

  private

  def to_model(attributes)
    Article.new(**attributes.symbolize_keys)
  end
end
