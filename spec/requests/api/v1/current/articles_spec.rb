require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET api/v1//current/articles" do
    # pending "add some examples (or delete) #{__FILE__}"
    subject { get(api_v1_current_articles_path, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "複数の記事が存在するとき" do
      let!(:article1) { create(:article, :published, updated_at: 1.days.ago, user: current_user) }
      let!(:article2) { create(:article, :published, updated_at: 2.days.ago, user: current_user) }
      before do
        create(:article, :draft, user: current_user)
        create(:article, :published)
      end

      it "自分が書いた公開用の記事の一覧のみ取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res.map {|d| d["id"] }).to eq [article1.id, article2.id]
        expect(res.length).to eq 2
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"]["name"]).to eq current_user.name
        expect(res[0]["user"]["email"]).to eq current_user.email
      end
    end
  end
end
