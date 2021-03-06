require 'redmine'

require 'panel_issue_hooks'

Redmine::Plugin.register :redmine_issue_control_panel do
  name 'Redmine Issue Control Panel plugin'
  author 'Konstantin Zaitsev, Alexandr Poplavsky'
  description 'Switch issue statuses from sidebar - without opening the Update screen.'
  version '0.2.0'
end
