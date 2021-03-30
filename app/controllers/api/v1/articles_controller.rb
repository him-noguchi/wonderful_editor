module Api::V1
  class ArticlesController < BaseApiController
    def index
      articles = Article.order(created_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end
  end
end
