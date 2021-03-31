require "rails_helper"

RSpec.describe "Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, updated_at: 3.days.ago) }

    it "記事一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article2.id, article1.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /article" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在している場合" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }

      it "記事の内容を取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        # expect(res["updated_at"]).to eq article.updated_at
        expect(res["user"]["id"]).to eq article.user.id
      end
    end

    context "指定したidの記事が存在しない場合" do
      let(:article_id) {10000}

      it "記事が見つからない" do
        expect{ subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end
end
