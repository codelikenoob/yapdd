require 'yapdd_api'

class Domain < ApplicationRecord
  belongs_to :user
  has_many :emails
  validates :domainname, :domaintoken, :domaintoken2, presence: true

  def refresh_emails
    self.emails.each do |eml|
      eml.destroy
    end
    self.domain_get_emails
    self.domain_get_image_url
  end

  def domain_get_image_url
    request = RestClient::Request.execute(method: :get, url: "https://pddimp.yandex.ru/api2/admin/domain/logo/check?domain=#{self.domainname}", headers: { PddToken: "#{self.domaintoken2}" })
    self.image = JSON.parse(request)['logo-url']
    if self.image.empty?
      self.image = "https://img-fotki.yandex.ru/get/50936/10713508.2341/0_f6abb_45be1c77_S.jpg"
    end
    self.save
  end

	def domain_get_emails
    page = 1
    loop do
      request = RestClient::Request.execute(method: :get, url: "https://pddimp.yandex.ru/api2/admin/email/list?domain=#{self.domainname}&page=#{page}&on_page=100", headers: { PddToken: "#{self.domaintoken2}" })
      break if JSON.parse(request)['accounts'].size == 0
      JSON.parse(request)['accounts'].each do |m|
          newemail = self.emails.new
          newemail.mailname = m['login'].split("@")[0]
          newemail.uid = m['uid']
          newemail.fname = m['fname']
          newemail.iname = m['iname']
          newemail.birth_date = "#{m['birth_date']}"
          newemail.sex = m['sex']
          newemail.hintq = m['hintq']
          m['enabled'] == "yes" ? newemail.enabled = 1 : newemail.enabled = 0
          newemail.aliases = m['aliases']
          newemail.fio = m['fio']
          newemail.save
        end
        page += 1
      end
  end
    
  def get_forward_list(email)
    require 'rest-client'
    require 'active_support/core_ext/hash'  #from_xml 
    require 'nokogiri'
    request = RestClient::Request.execute(method: :get, url: "https://pddimp.yandex.ru/get_forward_list.xml?token=#{self.domaintoken}&login=#{email.mailname}")
  end

end
