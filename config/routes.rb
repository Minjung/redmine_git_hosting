RedmineApp::Application.routes.draw do
    match ':repo_path/*path', 
        :prefix => (Setting.plugin_redmine_git_hosting['httpServerSubdir'] rescue ""), :repo_path => /([^\/]+\/)*?[^\/]+\.git/, :controller => 'git_http', :action => 'show'

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
