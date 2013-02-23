def install_redmine_git_hosting_routes_new(map)
  RedmineApp::Application.routes.draw do
    match ':repo_path/*path', :prefix => (Setting.plugin_redmine_git_hosting['httpServerSubdir'] rescue ""), :repo_path => /([^\/]+\/)*?[^\/]+\.git/, :controller => 'git_http', :action => 'show'

    # Handle the public keys plugin to my/account.
    scope "/my" do
      resources :public_keys, :controller => 'gitolite_public_keys'
    end

    match 'my/account/public_key/:public_key_id', :controller => 'my', :action => 'account'
    match 'users/:id/edit/public_key/:public_key_id', :controller => 'users', :action => 'edit', :conditions => {:method => [:get]}

    # Handle hooks and mirrors
    match 'githooks', :controller => 'gitolite_hooks', :action => 'stub'
    match 'githooks/post-receive', :controller => 'gitolite_hooks', :action => 'post_receive'
    match 'githooks/test', :controller => 'gitolite_hooks', :action => 'test'

    match 'repositories/:repository_id/mirrors/new', :action => 'create', :conditions => {:method => [:get, :post]}, :to => 'repository_mirrors'
    match 'repositories/:repository_id/mirrors/edit/:id', :action => 'edit', :to => 'repository_mirrors'
    match 'repositories/:repository_id/mirrors/push/:id', :action => 'push', :to => 'repository_mirrors'
    match 'repositories/:repository_id/mirrors/update/:id', :action => 'update', :conditions => {:method => :post}, :to => 'repository_mirrors'
    match 'repositories/:repository_id/mirrors/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}, :to => 'repository_mirrors'

    match 'repositories/:repository_id/post-receive-urls/new', :action => 'create', :conditions => {:method => [:get, :post]}, :to => 'repository_post_receive_urls'
    match 'repositories/:repository_id/post-receive-urls/edit/:id', :action => 'edit', :to => 'repository_post_receive_urls'
    match 'repositories/:repository_id/post-receive-urls/update/:id', :action => 'update', :conditions => {:method => :post}, :to => 'repository_post_receive_urls'
    match 'repositories/:repository_id/post-receive-urls/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}, :to => 'repository_post_receive_urls'

    match 'repositories/:repository_id/deployment-credentials/new', :action => 'create_with_key', :conditions => {:method => [:get, :post]}, :to => 'deployment_credentials'
    match 'repositories/:repository_id/deployment-credentials/edit/:id', :action => 'edit', :to => 'deployment_credentials'
    match 'repositories/:repository_id/deployment-credentials/update/:id', :action => 'update', :conditions => {:method => :post}, :to => 'deployment_credentials'
    match 'repositories/:repository_id/deployment-credentials/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}, :to => 'deployment_credentials'
  end
end

def install_redmine_git_hosting_routes_old(map)
  # URL for items of type httpServer/XXX.git. Some versions of rails has problems with multiple regex expressions, so avoid...
  # Note that 'http_server_subdir' is either empty (default case) or ends in '/'.
  map.connect ":repo_path/*path", :prefix => (Setting.plugin_redmine_git_hosting['httpServerSubdir'] rescue ""), :repo_path => /([^\/]+\/)*?[^\/]+\.git/, :controller => 'git_http'

  # Handle the public keys plugin to my/account.
  map.resources :public_keys, :controller => 'gitolite_public_keys', :path_prefix => 'my'
  map.connect 'my/account/public_key/:public_key_id', :controller => 'my', :action => 'account'
  map.connect 'users/:id/edit/public_key/:public_key_id', :controller => 'users', :action => 'edit', :conditions => {:method => [:get]}

  # Handle hooks and mirrors
  map.connect 'githooks', :controller => 'gitolite_hooks', :action => 'stub'
  map.connect 'githooks/post-receive', :controller => 'gitolite_hooks', :action => 'post_receive'
  map.connect 'githooks/test', :controller => 'gitolite_hooks', :action => 'test'

  map.with_options :controller => 'repositories' do |repo_mapper|
    repo_mapper.with_options :controller => 'repository_mirrors' do |mirror_views|
      mirror_views.connect 'repositories/:repository_id/mirrors/new', :action => 'create', :conditions => {:method => [:get, :post]}
      mirror_views.connect 'repositories/:repository_id/mirrors/edit/:id', :action => 'edit'
      mirror_views.connect 'repositories/:repository_id/mirrors/push/:id', :action => 'push'
      mirror_views.connect 'repositories/:repository_id/mirrors/update/:id', :action => 'update', :conditions => {:method => :post}
      mirror_views.connect 'repositories/:repository_id/mirrors/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}
    end

    repo_mapper.with_options :controller => 'repository_post_receive_urls' do |post_receive_views|
      post_receive_views.connect 'repositories/:repository_id/post-receive-urls/new', :action => 'create', :conditions => {:method => [:get, :post]}
      post_receive_views.connect 'repositories/:repository_id/post-receive-urls/edit/:id', :action => 'edit'
      post_receive_views.connect 'repositories/:repository_id/post-receive-urls/update/:id', :action => 'update', :conditions => {:method => :post}
      post_receive_views.connect 'repositories/:repository_id/post-receive-urls/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}
    end

    repo_mapper.with_options :controller => 'deployment_credentials' do |deploy_views|
      deploy_views.connect 'repositories/:repository_id/deployment-credentials/new', :action => 'create_with_key', :conditions => {:method => [:get, :post]}
      deploy_views.connect 'repositories/:repository_id/deployment-credentials/edit/:id', :action => 'edit'
      deploy_views.connect 'repositories/:repository_id/deployment-credentials/update/:id', :action => 'update', :conditions => {:method => :post}
      deploy_views.connect 'repositories/:repository_id/deployment-credentials/delete/:id', :action => 'destroy', :conditions => {:method => [:get, :delete]}
    end
  end
end

if defined? map
  if Rails::VERSION::MAJOR >= 3
  install_redmine_git_hosting_routes_new(map)
  else
    install_redmine_git_hosting_routes_old(map)
  end
else
  ActionController::Routing::Routes.draw do |map|
    if Rails::VERSION::MAJOR >= 3
      install_redmine_git_hosting_routes_new(map)
    else
      install_redmine_git_hosting_routes_old(map)
    end
  end
end
