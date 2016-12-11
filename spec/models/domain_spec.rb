require 'rails_helper'

RSpec.describe Domain, type: :model do
  it { should validate_presence_of :domainname }
  it { should validate_presence_of :domaintoken }
  it { should validate_presence_of :domaintoken2 }

end
