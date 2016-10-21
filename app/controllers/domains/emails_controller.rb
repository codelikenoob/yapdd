require 'yapdd_api'

class Domains::EmailsController < Domains::ApplicationController

  before_action :set_email, only: [:get_inside_mail]

  def get_inside_mail
    YapddAPI.new.get_inside_mailbox(@email)
  end
 
  
private

  def set_email
    @email = Email.find(params[:id])
    if @email.domain.user != current_user
      render status: 403, layout: false
    end
  end


end
