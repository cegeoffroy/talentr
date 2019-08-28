class User < ApplicationRecord
  has_many :jobs, dependent: :destroy
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :timeoutable, :omniauthable, omniauth_providers: [:google_oauth2]
  mount_uploader :photo, PhotoUploader

  def self.create_from_provider_data(provider_data)
    where(provider: provider_data.provider, uid: provider_data.uid).first_or_create do | user |
      user.email = provider_data.info.email
      user.first_name = provider_data.info.first_name
      user.last_name = provider_data.info.last_name
      user.password = Devise.friendly_token[0, 20]
      user.token = provider_data.credentials.token
      user.expires = provider_data.credentials.expires
      user.expires_at = provider_data.credentials.expires_at
      user.refresh_token = provider_data.credentials.refresh_token
      # user.skip_confirmation!
    end
  end
end
