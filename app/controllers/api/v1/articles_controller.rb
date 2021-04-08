module Api::V1
  class ArticlesController < BaseApiController

    def index
      articles = Article.order(created_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, each_serializer: Api::V1::ArticleSerializer
    end

    def create
      @article = Article.new(
        title: article_params[:title],
        body: article_params[:body],
         user_id: current_user.id
        )

      @article.save!

      render json: @article, each_serializer: Api::V1::ArticleSerializer
    end

    private

      def article_params
        params.require(:article).permit(:title, :body).merge(user_id: current_user.id)
      end

  end
end
