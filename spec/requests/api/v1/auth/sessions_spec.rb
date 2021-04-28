require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST　/api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "メールアドレス・パスワードが正しいとき" do
      let(:current_user) { create(:user) }
      let(:params) { { email: current_user.email, password: current_user.password } }

      it "ログインできる" do
        subject
        header = response.header
        expect(response).to have_http_status(:ok)
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "メールアドレスが正しくないとき" do
      let(:current_user) { create(:user) }
      let(:params) { { email: "test@example.com", password: current_user.password } }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to include("Invalid login credentials. Please try again.")
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "パスワードが正しくないとき" do
      let(:current_user) { create(:user) }
      let(:params) { { email: current_user.email, password: "example" } }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["success"]).to be_falsey
        expect(res["errors"]).to include("Invalid login credentials. Please try again.")
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE　/api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ログアウトに必要な情報を送信したとき" do
      let(:user) { create(:user)}
      let!(:headers) { user.create_new_auth_token }
      it "ログアウトできる" do
        expect{ subject }.to change { user.reload.tokens }.from(be_present).to(be_blank)
        expect(response).to have_http_status(:ok)
      end
    end

    context "誤った情報を送信したとき" do
      let(:user) { create(:user)}
      let!(:headers) { { "access-token"=> "", "token-type"=>"", "client"=>"", "expiry"=>"", "uid"=>""} }
      fit "ログアウトできない" do
        subject
        expect(response).to have_http_status(404)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include("User was not found or was not logged in.")
      end
    end
  end
end
