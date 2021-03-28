# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  context "タイトル・ボディが存在するとき" do
    let(:article) { build(:article) }
    it "記事が作られる" do
      expect(article).to be_valid
    end
  end

  # context "userが存在しないとき" do
  #   fit "記事作成に失敗する" do
  #     article = build(:article)
  #     expect(article).to be_invalid
  #     expect(article.errors.details[:user][0][:error]).to eq :blank
  #   end
  # end

  context "titleが存在しないとき" do
    it "記事作成に失敗する" do
      article = build(:article, title: nil)
      expect(article).to be_invalid
      # expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "bodyが存在しないとき" do
    it "記事作成に失敗する" do
      article = build(:article, body: nil)
      expect(article).to be_invalid
      # expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "titleが30字以上のとき" do
    it "記事作成に失敗する" do
      article = build(:article, title: "あああああああああああああああああああああああああああああああ")
      expect(article).to be_invalid
      # expect(article.errors.details[:title][0][:error]).to eq :too_long
    end
  end
end
