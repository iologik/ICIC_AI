# frozen_string_literal: true

class RemoveEmailIndexFromAdminUsers < ActiveRecord::Migration[5.2]
  def up
    sql = 'DROP INDEX index_admin_users_on_email'
    ActiveRecord::Base.connection.execute(sql)
  end

  def down
    sql = %(
      CREATE UNIQUE INDEX index_admin_users_on_email
      ON admin_users
      USING btree
      (email COLLATE pg_catalog."default");
    )
    ActiveRecord::Base.connection.execute(sql)
  end
end
