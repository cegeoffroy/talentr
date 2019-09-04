class Info < ApplicationRecord
  belongs_to :candidate
  serialize :meta_value
  include PgSearch::Model
  pg_search_scope :search_by_meta_value,
    against: [ :meta_value ],
    using: {
      tsearch: { prefix: true } # <-- now `superman batm` will return something!
    }
end
