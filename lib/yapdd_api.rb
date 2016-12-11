require 'rest-client'

class YapddAPI

  def initialize
  end

  def get_inside_mailbox(email)
    request = RestClient.get('https://pddimp.yandex.ru/api/user_oauth_token.xml', params: { domain: email.domain.domainname, token: email.domain.domaintoken, login: email.mailname})
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    token = result["action"]["domains"]["domain"]["email"].fetch("oauth_token")
    "http://passport.yandex.ru/passport?mode=oauth&error_retpath=&access_token=#{token}&type=trusted-pdd-partner"
  end

  def add_filter
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
    redirect_to root_path
  end

  def kill_filter
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
    redirect_to root_path
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

  
end
