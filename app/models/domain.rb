class Domain < ApplicationRecord
    belongs_to :user
    has_many :emails

end
