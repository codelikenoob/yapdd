class UsersController < ApplicationController
  before_action :set_domains
  before_action :set_domain

  def dashboard
  end

  def profile
  end
  
  private

  def set_domains
    @domains = current_user.domains.order(:domainname)
  end

  def set_domain
    if session[:current_domain] != nil
      @domain = Domain.find_by_id(session[:current_domain])
    else
      @domain = current_user.domains.first
      session[:current_domain] = @domain.id      
    end
    if @domain.user != current_user
      session[:current_domain] = nil
      render status: 403, layout: false
    end    
  end

  
end
