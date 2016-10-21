require 'rest-client'

class YapddAPI

  def initialize
  end

  def get_inside_mailbox(email)
    request_url = "https://pddimp.yandex.ru/api/user_oauth_token.xml?domain=#{email.domain.domainname}&token=#{email.domain.domaintoken}&login=#{email.mailname}"
    request = RestClient.get(request_url)
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    token = result["action"]["domains"]["domain"]["email"].fetch("oauth_token")
    link = "http://passport.yandex.ru/passport?mode=oauth&error_retpath=&access_token=#{token}&type=trusted-pdd-partner"
    redirect_to link
  end

  def addfilter
    request_url = "https://pddimp.yandex.ru/set_forward.xml?token=#{@domain.domaintoken}&login=#{params[:email]}&address=#{params[:address]}&copy=yes"
    request = RestClient.get(request_url)
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    if result.fetch("page").fetch("error", false)
      if result.fetch("page", "page").fetch("error", "error").fetch("reason", "reason") == "no_address"
        flash[:danger] = "Не могу поставить перадресацию на такой адрес! :("
      else
        flash[:danger] = "Что-то пошло не так! (#{result})"
      end
    else
      flash[:success] = "Вроде, получилось!"
    end
    redirect_to :back
  end

  def killfilter
    request = RestClient.get("https://pddimp.yandex.ru/delete_forward.xml?token=#{@domain.domaintoken}&login=#{params[:email]}&filter_id=#{params[:filter]}")
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    if result.fetch("page").fetch("error", false)
      if result.fetch("page", "page").fetch("error", "error").fetch("reason", "reason") == "no_address"
        flash[:danger] = "Какая-то фигня с адресом :("
      else
        flash[:danger] = "Что-то пошло не так! (#{result})"
      end
    else
      flash[:success] = "Удалил!"
    end
    redirect_to :back
  end

  def refresh_emails
    self.emails.each do |eml|
      eml.destroy
    end
    self.domain_get_emails
    self.domain_get_image_url
  end

  def update_email_info
    request_url = "https://pddimp.yandex.ru/edit_user.xml?token=#{@domain.domaintoken}&domain_name=#{@domain.domainname}&login=#{self.mailname}&password=#{self.pswrd}&iname=#{self.iname}&fname=#{self.fname}&hintq=#{self.hintq}&hinta=#{self.hinta}&sex=#{self.sex}"
    request = RestClient.get(request_url)
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    if result["page"] == "ok"
      flash[:success] = "Email успешно добавлен!"
      redirect_to home_path
    else
      flash[:danger] = "Хьюстон, у нас хуйнюстон! #{result}"
      render 'new'
    end
  end

  def domain_get_image_url
    request = RestClient.get("https://pddimp.yandex.ru/api2/admin/domain/logo/check?domain=#{self.domainname}", headers: { PddToken: "#{self.domaintoken2}" })
    self.image = JSON.parse(request)['logo-url']
    self.save
  end

	def domain_get_emails
    page = 1
    loop do
      request = RestClient.get(url: "https://pddimp.yandex.ru/api2/admin/email/list?domain=#{@email.domain.domainname}&page=#{page}&on_page=100", headers: { PddToken: "#{@email.domain.domaintoken2}" })
      break if JSON.parse(request)['accounts'].size == 0
      JSON.parse(request)['accounts'].each do |m|
          newemail = self.emails.new
          newemail.mailname = m['login']
          newemail.fname = m['fname']
          newemail.iname = m['iname']
          newemail.birth_date = m['birth_date']
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
