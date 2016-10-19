class Domains::DomainsController < Domains::ApplicationController
  before_action :set_domain, only: [:edit, :update, :show, :index, :refresh, :check_for_forwards, :killfilter, :addfilter, :get_inside_mail, :kill_that_mail, :block_that_mail, :unblock_that_mail]

  def index
	redirect_to new_domain_path if current_user.domains.empty?    
	@domains = current_user.domains.all
  end

  def show
  end

  def new
    @domain = Domain.new
  end

  def create
    @domain = Domain.new(domain_params)
    @domain.user = current_user

    if @domain.save
      flash[:success] = "Домен добавлен!"
      redirect_to domains_path
    else
      render :new
    end
  end

  def edit
  end

  private
  
  def domain_params
    params.require(:domain).permit(:domainname, :domaintoken, :domaintoken2)
  end

  def set_domain
    @domain = current_user.domains.first
  end

  
end
