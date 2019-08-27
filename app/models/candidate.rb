class Candidate < ApplicationRecord
  has_many :infos
  has_many :applications
end
