class Job < ApplicationRecord
  belongs_to :user
  has_many :application
  has_many :opening_keywords

end
