require 'yapdd_api'

class Domains::DomainsController < Domains::ApplicationController
  before_action :set_domain, only: [:edit, :update, :show, :index, :dashboard, :refresh, :check_for_forwards, :kill_filter, :add_filter, :kill_that_mail, :block_that_mail, :unblock_that_mail, :set_current_email]
  before_action :set_domains, only: [:dashboard, :new]
  before_action :set_email, only: [:edit, :update, :show, :dashboard]
  
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
      redirect_to root_path
    else
      render :new
    end
  end

  def edit
  end

  def refresh
    @domain.refresh_emails
    session[:current_email] = nil
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
      session[:current_email] = @domain.emails.order(:mailname).first.id
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

  def set_domains
    @domains = current_user.domains
  end
  
  def set_email
    if session[:current_email] != nil
      @email = @domain.emails.find(session[:current_email])
    else
      @email = @domain.emails.order(:mailname).first
      session[:current_email] = @email.id
    end    
  end

end
