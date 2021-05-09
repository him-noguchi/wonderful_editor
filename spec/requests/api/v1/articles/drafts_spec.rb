require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }

  describe "GET /articles/drafts" do
    # pending "add some examples (or delete) #{__FILE__}"
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:article1) { create(:article, :draft, user: current_user) }
    let!(:article2) { create(:article, :draft, user: current_user) }
    let!(:article3) { create(:article, :published, user: current_user) }
    before { create(:article, :draft) }

    it "自分が作成した下書き一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 2
      expect(res[0]["id"]).to eq article2.id
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /article/draft" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定したidの記事が存在していて" do
      let(:article_id) { article.id }

      context "対象の記事が自分で作成した下書きのとき" do
        let(:article) { create(:article, :draft, user: current_user) }

        it "記事の内容を取得できる" do
          subject
          res = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
        end
      end

      context "対象の記事が公開中のとき" do
        let(:article) { create(:article, :published, user: current_user) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "自分で作成した記事でない場合" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
