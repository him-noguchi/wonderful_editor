require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST　/api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なパラメータを送ったとき" do
      let(:params) { attributes_for(:user) }

      it "新規登録ができる" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "header情報を取得できる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "name が空のとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "新規登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)
        expect(res["errors"]["name"]).to eq ["can't be blank"]
      end
    end

    context "email が空のとき" do
      let(:params) { attributes_for(:user, email: nil) }

      it "新規登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)
        expect(res["errors"]["email"]).to eq ["can't be blank"]
      end
    end

    context "password が空のとき" do
      let(:params) { attributes_for(:user, password: nil) }

      it "新規登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
        res = JSON.parse(response.body)
        expect(res["errors"]["password"]).to eq ["can't be blank"]
      end
    end
  end
end
