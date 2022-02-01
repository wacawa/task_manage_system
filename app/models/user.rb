class User < ApplicationRecord
  has_many :tasks, dependent: :destroy
  attr_accessor :remember_token

  validates :email, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  def self.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      return user
    end
  end

  def self.line_omniauth(hash)
    where(provider: hash["provider"], uid: hash["sub"]).first_or_initialize.tap do |user|
      user.provider = hash["provider"]
      user.uid = hash["sub"]
      user.email = hash["email"]
      user.oauth_token = hash["a_token"]
      user.oauth_expires_at = Time.at(hash["exp"])
      return user
    end
  end
  
end
