module ApplicationHelper
  def full_url(link)
    request.protocol + request.host_with_port + link
  end
end
