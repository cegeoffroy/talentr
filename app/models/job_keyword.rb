class JobKeyword < ApplicationRecord
  belongs_to :keyword
  belongs_to :job
end
