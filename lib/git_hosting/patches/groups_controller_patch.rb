require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'
require_dependency 'git_hosting'
require_dependency 'groups_controller'

module GitHosting
    module Patches
	module GroupsControllerPatch

	    @@original_projects = []

	    def disable_git_observer_updates
		GitHostingObserver.set_update_active(false)
	    end

	    def do_single_update
		GitHostingObserver.set_update_active(true)
	    end


	    def self.included(base)
		base.class_eval do
		    unloadable
		end
		base.send(:before_filter, :disable_git_observer_updates, :only=>[:update, :destroy, :add_users, :remove_user, :edit_membership, :destroy_membership])
		base.send(:after_filter, :do_single_update,  :only=>[:update, :destroy, :add_users, :remove_user, :edit_membership, :destroy_membership])
	    end
	end
    end
end

# Patch in changes
GroupsController.send(:include, GitHosting::Patches::GroupsControllerPatch)
