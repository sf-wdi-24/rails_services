class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  # note: has_secure_password automatically adds validations for presence
  # of password, password length < 72 characters, and password_confirmation
  has_secure_password

  # only validate password length on create (not update)
  validates :password, length: { minimum: 6 }, on: :create

  validates :email,
    presence: true,
    uniqueness: true,
    format: {
      with: /@/,
      message: "not a valid format"
    }

end