class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  belongs_to :user

  validates :title, presence: true, length: { minimum: 3 }
  validates :content, presence: true, length: { minimum: 10 }

end