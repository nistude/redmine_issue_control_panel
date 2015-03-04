include GravatarHelper::PublicMethods

class PanelIssueHooks < Redmine::Hook::ViewListener

  def protect_against_forgery?
    false
  end

  def view_layouts_base_html_head(context)
    stylesheet_link_tag('issue_control_panel.css', :plugin => :redmine_issue_control_panel)
  end

  def view_issues_sidebar_planning_bottom(context = { })
    project = context[:project]
    request = context[:request]
    issue_id = request.symbolized_path_parameters[:id]
    back = request.env['HTTP_REFERER']

    if (issue_id)
      issue = Issue.includes(:status).find(issue_id)
      if (issue)
        if (User.current.allowed_to?(:edit_issues, project))
          o = ''
          statuses = issue.new_statuses_allowed_to(User.current)
          if (!statuses.empty?)
            o << "<h3>#{l(:label_issue_change_status)}</h3>"
            o << '<table class="issue_control_panel_status">'
            statuses.each do |s|
              if (s != issue.status)
                o << '<tr><td>'
                o << link_to(s.name, {:controller => 'issues', :action => 'update', :id => issue, :issue => {:status_id => s}, :back_to => "/issues/show/"+issue_id, :authenticity_token => form_authenticity_token(request.session)}, :method => :put, :class => 'icon icon-move' )
                o << '</td><td align="right">'
                o << link_to(l(:label_issue_edit), {:controller => 'issues', :action => 'edit', :id => issue, :issue => {:status_id => s}}, :class => 'icon icon-edit' )
                o << '</td></tr>'
              end
            end
            o << "</table>"
          end
          assignables = project.assignable_users
          if (!assignables.empty?) || (!issue.assigned_to.nil?)
            o << "<h3>#{l(:label_issue_change_assigned)}</h3>"
            o << '<div' + (assignables.length > 10 ? ' class="issue_control_panel_scroll">' : '>')
            o << '<table class="issue_control_panel_reassign">'
            assignables.each do |u|
              if (u != issue.assigned_to)
                o << '<tr><td>'
                options = {:size => "14", :style => "float: left; margin-right: 2px;"}
                av = if Setting.gravatar_enabled?
                  options.merge!({:ssl => (request && request.ssl?), :default => Setting.gravatar_default})
                  email = nil
                  if u.respond_to?(:mail)
                    email = u.mail
                  elsif u.to_s =~ %r{<(.+?)>}
                    email = $1
                  end
                  gravatar(email.to_s.downcase, options) unless email.blank? rescue ''
                else
                  ''
                end
                o << av unless av.nil?
                o << link_to(u.name, {:controller => 'issues', :action => 'update', :id => issue, :issue => {:assigned_to_id => u}, :back_to => "/issues/show/"+issue_id, :authenticity_token => form_authenticity_token(request.session)}, :method => :put)
                o << '</td></tr>'
              end
            end
            if (!issue.assigned_to.nil?)
              o << '<tr><td>'
              o << link_to(l(:label_issue_remove_assignee), {:controller => 'issues', :action => 'update', :id => issue, :issue => {:assigned_to_id => nil}, :back_to => "/issues/show/"+issue_id, :authenticity_token => form_authenticity_token(request.session)}, :method => :put, :class => 'icon icon-del' )
              o << '</td></tr>'
            end
            o << "</table></div>"
          end
        end
      end
      return o
    end
  end

  #TODO it is not clear how to resolve ActionController or more specific
  #TODO controller from the hook. For now this method just copied from
  #TODO RequestForgeryProtection module (actionpack-2.3.5)
  def form_authenticity_token(session)
    session[:_csrf_token] ||= ActiveSupport::SecureRandom.base64(32)
  end

end
