class CreateGitCaches < ActiveRecord::Migration
    def self.up
	create_table :git_caches do |t|
	    t.column :command, :text
	    t.column :command_output, :binary
	    t.column :proj_identifier, :string
	    t.timestamps
	end
 
# Not sure exactly which way is more sutable for problem with index on TEXT,
# so just disable it now.
# http://stackoverflow.com/questions/1827063/mysql-error-key-specification-without-a-key-length
#	add_index :git_caches, :command
    end

    def self.down
	drop_table :git_caches
    end
end
