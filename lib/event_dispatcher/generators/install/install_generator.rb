require 'rails/generators/migration'

class EventDispatcher::InstallGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc "add the migrations"

  def self.next_migration_number(path)
    unless @prev_migration_nr
      @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
    else
      @prev_migration_nr += 1
    end
    @prev_migration_nr.to_s
  end

  def copy_migrations
    migration_template "create_ed_tables.rb", "db/migrate/create_ed_tables.rb"
  end

  def copy_initializer
    template "event_dispatcher.rb", "config/initializers/event_dispatcher.rb"
  end

end