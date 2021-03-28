require "rails_helper"

RSpec.describe User, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  context "すべてのカラム を指定しているとき" do
    let(:user) { build(:user) }
    it "ユーザーが作られる" do
      expect(user).to be_valid
    end
  end

  context "name を指定していないとき" do
    let(:user) { build(:user, name: nil) }
    it "ユーザー作成に失敗する" do
      expect(user).to be_invalid
      # expect(user.errors.details[:name][0][:error]).to eq :blank
    end
  end

  context "name が31文字以上のとき" do
    it "ユーザー作成に失敗する" do
      user = build(:user, name: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
      expect(user).to be_invalid
      # expect(user.errors.details[:name][0][:error]).to eq :too_long
    end
  end

  context "emailが無い場合" do
    let(:user) { build(:user, email: nil) }
    it "エラーが発生する" do
      expect(user).not_to be_valid
    end
  end

  context "passwordが無い場合" do
    let(:user) { build(:user, password: nil) }
    it "エラーが発生する" do
      expect(user).not_to be_valid
    end
  end
end
