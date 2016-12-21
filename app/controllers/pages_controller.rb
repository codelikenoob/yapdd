class PagesController < ApplicationController
  before_action :set_domain, only: [:faq]
  before_action :set_domains, only: [:faq]

  def welcome
  end

  def faq
  end
  
  private

  def set_domain
    if current_user.present?
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
  end

  def set_domains
    if current_user.present?
      @domains = current_user.domains
    end
  end

end
