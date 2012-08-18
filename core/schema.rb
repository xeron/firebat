module FireBat
  class Install < ActiveRecord::Migration

    def self.up
      table_up User, :users, do |t|
        t.column :name, :string
        t.column :password, :string
        t.column :registered_at, :datetime
        t.column :last_seen, :datetime
        t.column :host_id, :integer
        t.column :ident_id, :integer
        t.column :online, :boolean
        t.column :authorised, :boolean
      end
      table_up Host, :hosts do |t|
        t.column :name, :string
      end
      table_up Ident, :idents do |t|
        t.column :name, :string
      end
      table_up Channel, :channels do |t|
        t.column :name, :string
        t.column :password, :string
        t.column :topic, :string
      end
      table_up Role, :roles do |t|
        t.column :name, :string
      end
      table_up RolesUser, :roles_users, :id => false do |t|
        t.column :user_id, :integer
        t.column :role_id, :integer
      end
    end

    def self.down
      drop_table :users
      drop_table :hosts
      drop_table :idents
      drop_table :channels
      drop_table :roles_users
      drop_table :roles
    end

    private

    def table_up(table_class, table_name, options={}, &block)
      unless table_class.table_exists?
        create_table table_name, options, &block
      else
        puts "Table #{table_name} exists."
      end
    end

  end
end
