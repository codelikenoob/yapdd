require 'yapdd_api'

class Domain < ApplicationRecord
  belongs_to :user
  has_many :emails
  validates :domainname, :domaintoken, :domaintoken2, presence: true

  def refresh_emails
    self.emails.destroy_all
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
          newemail.sex = m['sex'].to_s
          newemail.hintq = m['hintq']
          m['enabled'] == "yes" ? newemail.enabled = 1 : newemail.enabled = 0
          JSON.parse(m['aliases'].to_s).each do |aliaz|
            newemail.aliases << aliaz
          end
          newemail.fio = m['fio']
          m['maillist'] == "yes" ? newemail.maillist = 1 : newemail.maillist = 0
          m['ready'] == "yes" ? newemail.signed_eula = 1 : newemail.signed_eula = 0
          get_filters(newemail)
          newemail.save
        end
        page += 1
      end
  end
  
  def get_filters(email)
    q = Hash.from_xml(Nokogiri::Slop(email.domain.get_forward_list(email)).to_s)
    if q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters') != nil
      @filters = q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters').fetch('filter', 'no filter')    
    else
      @filters = []
    end     
    if @filters.class != Array
      @filters = [@filters]
    end
    @filters = @filters.sort_by{|item| item["filter_param"]}
    email.fwdto = []
    @filters.each do |fltr|
      email.fwdto << fltr['filter_param']
    end
  end

  def get_forward_list(email)
    require 'rest-client'
    require 'active_support/core_ext/hash'  #from_xml 
    require 'nokogiri'
    request = RestClient::Request.execute(method: :get, url: "https://pddimp.yandex.ru/get_forward_list.xml?token=#{self.domaintoken}&login=#{email.mailname}")
  end

end
