require 'yapdd_api'

class Domains::DomainsController < Domains::ApplicationController
  before_action :set_domain, only: [:edit, :update, :show, :index, :dashboard, :refresh, :check_for_forwards, :killfilter, :addfilter, :kill_that_mail, :block_that_mail, :unblock_that_mail]
  before_action :set_email, only: [:get_inside_mail]

  def index
  end

  def dashboard
    redirect_to new_domain_path if current_user.domains.empty?    
    @domains = current_user.domains
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
      redirect_to domains_path
    else
      render :new
    end
  end

  def edit
  end

  def refresh
    @domain.refresh_emails
    flash[:success] = "Информация обновлена"
    redirect_to :back
  end

  def get_inside_mail
    YapddAPI.new.get_inside_mailbox(@domain,@email)
  end

  private
  
  def domain_params
    params.require(:domain).permit(:domainname, :domaintoken, :domaintoken2)
  end

  def set_domain
    if params[:id] != nil
      @domain = Domain.find(params[:id])
    else
      @domain = current_user.domains.first
    end
    if @domain.user != current_user
      render status: 403, layout: false
    end
  end

  def set_email
    @email = Email.find(params[:id])
    if @email.domain.user != current_user
      render status: 403, layout: false
    end
  end

end
