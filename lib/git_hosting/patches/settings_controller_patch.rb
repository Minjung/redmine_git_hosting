module GitHosting
  module Patches
    module SettingsControllerPatch
      unloadable

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          helper :application_ext
          include ApplicationExtHelper
        end
      end

      module InstanceMethods

      end

    end
  end
end

unless SettingsController.included_modules.include?(GitHosting::Patches::SettingsControllerPatch)
  SettingsController.send(:include, GitHosting::Patches::SettingsControllerPatch)
end
