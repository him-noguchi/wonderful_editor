require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
    before { create(:article, :draft) }

    it "公開用の記事一覧が取得できる" do
      subject
      res = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(res.length).to eq 2
      expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /article" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在していて" do
      let(:article_id) { article.id }

      context "対象の記事が公開中のとき" do
        let(:article) { create(:article, :published) }

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

      context "対象の記事が下書きのとき" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "指定したidの記事が存在しない場合" do
      let(:article_id) { 10000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "適切なパラメータを送信したとき（公開用）" do
      let(:params) { { article: attributes_for(:article, :published) } }

      it "公開用の記事が作成される" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:ok)
      end
    end

    context "適切なパラメータを送信したとき（下書き用）" do
      let(:params) { { article: attributes_for(:article, :draft) } }

      it "下書きの記事が作成される" do
        expect { subject }.to change { Article.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメータを送信したとき" do
      let(:params) { { article: attributes_for(:article, status: :foo) } }

      it "記事作成に失敗する" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "ログインしていないとき" do
      let!(:current_user) { nil }
      let(:params) { { article: attributes_for(:article) } }
      let(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }

      it "記事作成に失敗する" do
        expect { subject }.to change { Article.count }.by(0)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("You need to sign in or sign up before continuing.")
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, :published) } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分が所持している下書き記事のレコードを更新しようとしたとき" do
      let(:article) { create(:article, :draft, user: current_user) }

      it "記事を公開用として更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとしたとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "記事を更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article.id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    # before do
    #   allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user)
    # end

    context "自分が所持している記事を削除しようとしたとき" do
      let!(:article) { create(:article, user: current_user) }

      it "削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分が所持していない記事を削除しようとしたとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
