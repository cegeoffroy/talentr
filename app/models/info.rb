class Info < ApplicationRecord
  belongs_to :candidate
  serialize :meta_value
end
