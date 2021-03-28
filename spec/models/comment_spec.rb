# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_article_id  (article_id)
#  index_comments_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Comment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  context "bodyが存在するとき" do
    it "コメントが作られる" do
      comment = build(:comment)
      expect(comment).to be_valid
    end
  end

  context "bodyが空のとき" do
    it "コメント作成に失敗する" do
      comment = build(:comment, body: nil)
      expect(comment).to be_invalid
      # expect(comment.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "bodyが100字以上のとき" do
    it "コメント作成に失敗する" do
      comment = build(:comment, body: "あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ")
      expect(comment).to be_invalid
      # expect(comment.errors.details[:body][0][:error]).to eq :too_long
    end
  end
end
