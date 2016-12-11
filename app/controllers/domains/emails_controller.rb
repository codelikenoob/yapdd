require 'yapdd_api'

class Domains::EmailsController < Domains::ApplicationController

  before_action :set_domain, only: [:get_inside_mail, :new]
  before_action :set_email, only: [:get_inside_mail]
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
    render 'domains/domains/dashboard'
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

private

  def set_email
    @email = @domain.emails.find(params[:id])
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
  
end
