module ApplicationHelper

  def render_content
    if session[:tab] == "info"
      render 'domains/domains/info'
    elsif session[:tab] == "new_email"
      render 'domains/emails/new_email'
    elsif session[:tab] == "forward"
      render 'domains/domains/forward'
    end
  end

  def get_filters(email)
    q = Hash.from_xml(Nokogiri::Slop(email.domain.get_forward_list(email)).to_s)
    if q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters') != nil
      @filters = q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters').fetch('filter', 'no filter')    
    else
      @filters = []
    end     
    if @filters.class != Array
      @filters = [@filters]
    end
    @filters = @filters.sort_by{|item| item["filter_param"]}
    email.fwdto = []
    @filters.each do |fltr|
      email.fwdto << fltr['filter_param']
    end
  end

  def incoming(mail)
    @incomefwd = []
    domains = current_user.domains
    domains.each do |domain|
      emails = domain.emails
      emails.each do |email|
        fwdto = email.fwdto
          fwdto.each do |fwdaddr|
            if fwdaddr == (mail.mailname + "@" + mail.domain.domainname)
              @incomefwd << (email.mailname + "@" + email.domain.domainname)
            end
          end
        end
    end
    @incomefwd = @incomefwd.sort!
  end
  
end
