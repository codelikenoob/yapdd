require 'yapdd_api'
require 'uri'

class Domains::EmailsController < Domains::ApplicationController

  before_action :set_domain, only: [:get_inside_mail, :kill_that_mail, :new, :create, :add_filter, :update]
  before_action :set_domains, only: [:new, :update]
  before_action :set_email, only: [:get_inside_mail, :kill_that_mail, :update]
  before_action :set_tab

  def get_inside_mail
    link = YapddAPI.new.get_inside_mailbox(@email)
    redirect_to link
  end
 
  def set_current_email
    if Email.find(params[:id]).domain.user == current_user
      session[:current_email] = params[:id]
      redirect_to root_path
    else
      render status: 403, layout: false
    end    
  end
  
  def show    
  end

  def new
    @email = Email.new
    session[:tab] = "new_email"
    render 'domains/domains/dashboard'
  end
  
  def create
    @email = @domain.emails.new(email_params)
    request = RestClient.get("https://pddimp.yandex.ru/reg_user_token.xml?token=#{@email.domain.domaintoken}&u_login=#{@email.mailname}&u_password=#{@email.pswrd}")
    result = Hash.from_xml(Nokogiri::Slop(request).to_s)
    if result.fetch("page").fetch("error", false)
      if result.fetch("page", "page").fetch("error", "error").fetch("reason", "reason") == "no_address"
        flash[:danger] = "Какая-то фигня с адресом :( (#{result})"
      else
        flash[:danger] = "Что-то пошло не так! (#{result})"
      end
    elsif result.fetch("page").fetch("ok")
        @email.uid = result.fetch("page").fetch("ok").fetch("uid")
    end
    
    url_custom = "https://pddimp.yandex.ru/api2/admin/email/edit?domain=#{@email.domain.domainname}&login=#{@email.mailname}"
    url_custom = url_custom + "&password=#{@email.pswrd}" if @email.pswrd.present?
    url_custom = url_custom + "&iname=#{@email.iname}" if @email.iname.present?
    url_custom = url_custom + "&fname=#{@email.fname}" if @email.fname.present?
    url_custom = url_custom + "&birth_date=#{@email.birth_date.strftime('%F')}" if @email.birth_date.present?
    url_custom = url_custom + "&hintq=#{@email.hintq}" if @email.hintq.present?
    url_custom = url_custom + "&hinta=#{@email.hinta}" if @email.hinta.present?
    url_custom = url_custom + "&sex=#{@email.sex}" if @email.sex.present?

    url = URI::encode(url_custom)
    request = RestClient::Request.execute(method: :post, url: url, headers: { PddToken: "#{@email.domain.domaintoken2}" })
    @result = JSON.parse(request)
    
    puts "---------"
    puts url_custom
    puts "---------"
    puts url
    puts "---------"
    puts @result.to_s
    puts "---------"
    
    @email.enabled = true
    
    if @email.save
      session[:tab] = "info"
      session[:current_email] = @email.id
      flash[:success] = "Ящик добавлен!"
      redirect_to root_path
    else
      errors = ""
      @email.errors.full_messages.each do |err|
        errors = errors + err + "\n"
      end
      flash[:danger] = "Что-то пошло не так!\n#{errors}"
      redirect_to new_email_path
    end
  end

  def update
    if @email.update(email_params)
      flash[:success] = "Мыло успешно отредактировано"
      session[:tab] = "info"
      session[:current_email] = @email.id
    else
      flash[:danger] = "Что-то пошло не так"
    end

    url_custom = "https://pddimp.yandex.ru/api2/admin/email/edit?domain=#{@email.domain.domainname}&login=#{@email.mailname}"
    url_custom = url_custom + "&password=#{@email.pswrd}" if @email.pswrd.present?
    url_custom = url_custom + "&iname=#{@email.iname}" if @email.iname.present?
    url_custom = url_custom + "&fname=#{@email.fname}" if @email.fname.present?
    url_custom = url_custom + "&birth_date=#{@email.birth_date.strftime('%F')}" if @email.birth_date.present?
    url_custom = url_custom + "&hintq=#{@email.hintq}" if @email.hintq.present?
    url_custom = url_custom + "&hinta=#{@email.hinta}" if @email.hinta.present?
    url_custom = url_custom + "&sex=#{@email.sex}" if @email.sex.present?

    url = URI::encode(url_custom)
    request = RestClient::Request.execute(method: :post, url: url, headers: { PddToken: "#{@email.domain.domaintoken2}" })
    @result = JSON.parse(request)

    puts "---------"
    puts url_custom
    puts "---------"
    puts url
    puts "---------"
    puts @result.to_s
    puts "---------"
    
    redirect_to root_path
  end

  def kill_that_mail
    url = "https://pddimp.yandex.ru/api2/admin/email/del?domain=#{@email.domain.domainname}&login=#{@email.mailname}"
    request = RestClient::Request.execute(method: :post, url: url, headers: { PddToken: "#{@email.domain.domaintoken2}" })
    session[:current_email] = nil
    @email.destroy
    redirect_to root_path
  end

  def change_block_status
    email = Email.find(params[:id])
    if email.enabled == true
      newstatus = "no"
    else
      newstatus = "yes"
    end
    if email.enabled == true
      email.enabled = false
      email.save
    else
      email.enabled = true
      email.save
    end
    if email.domain.user == current_user
      url = "https://pddimp.yandex.ru/api2/admin/email/edit?domain=#{email.domain.domainname}&login=#{email.mailname}&enabled=#{newstatus}"
      request = RestClient::Request.execute(method: :post, url: url, headers: { PddToken: "#{email.domain.domaintoken2}" })
      flash[:success] = request.to_s
      redirect_to root_path
    else
      render status: 403, layout: false
    end
  end

  def kill_filter
    email = Email.find(session[:current_email])
    request = RestClient.get("https://pddimp.yandex.ru/delete_forward.xml?token=#{email.domain.domaintoken}&login=#{email.mailname}&filter_id=#{params[:id]}")
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

  def add_filter
    email = Email.find(session[:current_email])
    request_url = "https://pddimp.yandex.ru/set_forward.xml?token=#{@domain.domaintoken}&login=#{email.mailname}&address=#{params[:address]}&copy=yes"
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

private

  def email_params
    params.require(:email).permit(:mailname, :iname, :fname, :pswrd, :birth_date, :hintq, :hinta, :sex)
  end
  
  def set_email
    @email = @domain.emails.find_by_id(params[:id])
    if @email.domain.user != current_user
      render status: 403, layout: false
      @email = nil
    end
  end

  def set_domain
    if session[:current_domain] != nil
      @domain = Domain.find(session[:current_domain])
    else
      @domain = current_user.domains.first
      session[:current_domain] = @domain.id      
    end
    if @domain.user != current_user
      session[:current_domain] = nil
      render status: 403, layout: false
    end    
  end
  
  def set_tab
    if session[:tab] == nil
      session[:tab] = "info"
    end
  end

  def set_domains
    @domains = current_user.domains
  end
  
end
