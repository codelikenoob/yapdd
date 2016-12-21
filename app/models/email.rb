class Email < ApplicationRecord
 belongs_to :domain
 validates :mailname, presence: true, length: { minimum: 1, maximum: 50 }
 
end
