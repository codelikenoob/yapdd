require 'yapdd_api'

class Domains::DomainsController < Domains::ApplicationController
  before_action :set_domain, only: [:edit, :update, :show, :index, :dashboard, :refresh, :check_for_forwards, :kill_filter, :add_filter, :kill_that_mail, :block_that_mail, :unblock_that_mail, :set_current_email]
  before_action :set_domains, only: [:dashboard, :new]
  before_action :set_email, only: [:edit, :update, :show, :dashboard]
  before_action :set_tab
  
  def index
  end

  def dashboard
    redirect_to new_domain_path if current_user.domains.empty?
    #redirect_to new_email_path if current_user.domains.emails.empty?
  end

  def show
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = current_user.domains.new(domain_params)
    if @domain.save
      flash[:success] = "Домен добавлен!"
      @domain.refresh_emails
      session[:current_domain] = @domain.id
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @domain.update(domain_params)
      flash[:success] = "Домен успешно отредактирован"
      redirect_to profile_path
    else
      flash[:danger] = "Что-то пошло не так"
      redirect_to profile_path
    end
  end

  def destroy
    @domain = Domain.find_by_id(params[:id])
    @domain.emails.each do |bb|
      bb.destroy
    end
    if @domain.user = current_user
      @domain.destroy
      flash[:success] = "Домен удалён!"
      redirect_to profile_path
    else
      flash[:danger] = "Не твоё - не тронь!"
      redirect_to profile_path
    end
  end

  def refresh
    @domain.refresh_emails
    session[:current_email] = nil
    session[:tab] = "info"
    flash[:success] = "Информация обновлена"
    redirect_to root_path
  end

  def change_domain
    if params[:id] == nil
      redirect_to root_path
    else
      @domain = Domain.find(params[:id])
    end
    if @domain.user == current_user
      session[:current_domain] = @domain.id
      session[:tab] = "info"
      if @domain.emails.first != nil
        session[:current_email] = @domain.emails.order(:mailname).first.id
      end
      redirect_to root_path
    else
      redirect_to root_path
    end
  end
  
  def change_tab
    session[:tab] = params[:id]
    redirect_to root_path
  end


  private
  
  def domain_params
    params.require(:domain).permit(:domainname, :domaintoken, :domaintoken2)
  end

  def set_domain
    if session[:current_domain] != nil
      if Domain.find_by_id(session[:current_domain])
        @domain = Domain.find_by_id(session[:current_domain])
      else
        session[:current_domain] = nil
      end
    elsif session[:current_domain] == nil
      @domain = current_user.domains.first
    end
    if @domain == nil
      redirect_to new_domain_path
    else
      if @domain.user != current_user
        session[:current_domain] = nil
        render status: 403, layout: false
      else
        session[:current_domain] = @domain.id      
      end    
    end
  end

  def set_domains
    @domains = current_user.domains
  end
  
  def set_email
    if @domain.emails.empty?
      session[:tab] = "new_email"
      redirect_to new_email_path
    end
    if session[:current_email] != nil
      if @domain.emails.find_by_id(session[:current_email])
        @email = @domain.emails.find(session[:current_email])
      else
        session[:current_email] = nil
      end
    else
      @email = @domain.emails.order(:mailname).first
      session[:current_email] = @email.id
    end    
  end

  def set_tab
    if (session[:tab] == nil) and (@email != nil)
      session[:tab] = "info"
    end
    if @email == nil
      session[:tab] = "new_mail"
    end
  end

end
