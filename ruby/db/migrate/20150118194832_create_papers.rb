class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.string :source
      t.string :pmid
      t.string :title
      t.string :author
      t.string :container_title
      t.string :publisher
      t.string :publisher_place
      t.string :issn
      t.date :issued
      t.integer :start_page
      t.integer :end_page
      t.integer :volume
      t.integer :issue
      t.string :pmcid
      t.string :type
      t.text :body

      t.timestamps null: false
    end
  end
end
