class CreateExtensionSites < ActiveRecord::Migration
  def change
    create_table :extension_sites do |t|
      t.belongs_to :site
      t.string :name

      t.timestamps
    end
    add_index :extension_sites, :site_id

    add_foreign_key :extension_sites, :sites
  end
end
