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

  def get_filters
    q = Hash.from_xml(Nokogiri::Slop(@domain.get_forward_list(@email)).to_s)
    if q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters') != nil
      @filters = q.fetch('page', 'no page').fetch('ok', 'not ok').fetch('filters', 'no filters').fetch('filter', 'no filter')    
    else
      @filters = []
    end     
    if @filters.class != Array
      @filters = [@filters]
    end
    @filters = @filters.sort_by{|item| item["filter_param"]}
  end

end
