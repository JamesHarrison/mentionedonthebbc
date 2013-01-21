module ApplicationHelper
  def link_to_mention(m)
    "<a href=\"/channels/#{m.channel.shortname}/mentions/#{m.slug}\" class=\"mention_link\">#{h(m.name)}</a>".html_safe
  end
end
