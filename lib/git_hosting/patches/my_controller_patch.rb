require_dependency 'project'
require_dependency 'principal'
require_dependency 'user'
require_dependency 'git_hosting'
require_dependency 'my_controller'

module GitHosting
    module Patches
	module MyControllerPatch
	    # Add in values for viewing public keys:
	    def account_with_public_keys
		# Previous routine
		account_without_public_keys

		@gitolite_user_keys = @user.gitolite_public_keys.active.user_key.find(:all,:order => 'title ASC, created_at ASC')
		@gitolite_deploy_keys = @user.gitolite_public_keys.active.deploy_key.find(:all,:order => 'title ASC, created_at ASC')
		@gitolite_public_keys = @gitolite_user_keys + @gitolite_deploy_keys
		@gitolite_public_key = @gitolite_public_keys.detect{|x| x.id == params[:public_key_id].to_i}
		if @gitolite_public_key.nil?
		    if params[:public_key_id]
			# public_key specified that doesn't belong to @user.  Kill off public_key_id and try again
			redirect_to :public_key_id => nil, :tab => nil
			return
		    else
			@gitolite_public_key = GitolitePublicKey.new
		    end
		end
	    end

	    def self.included(base)
		base.class_eval do
		    unloadable

#		    helper :application_ext
		    helper :gitolite_public_keys
		end
		begin
		    base.send(:alias_method_chain, :account, :public_keys)
		rescue
		end
	    end
	end
    end
end

# Patch in changes
MyController.send(:include, GitHosting::Patches::MyControllerPatch)
