# This migration comes from personal (originally 20130903143448)
class CreatePersonalPeople < ActiveRecord::Migration
  def change
    create_table :personal_people do |t|
      t.string  :name, :limit => 30, :null => false
      t.string  :surname, :limit => 30, :null => false
      t.integer :user_id, :null => false
      t.string  :socialname, :limit => 30
      t.string  :salutation, :limit => 20
      t.string  :gender, :limit => 1
      t.string  :jobtitle, :limit => 40
      t.string  :department, :limit => 40
      t.string  :hometel, :limit => 15
      t.string  :busitel, :limit => 15
      t.string  :exttel, :limit => 15
      t.string  :fax, :limit => 15
      t.string  :gsm, :limit => 15
      t.string  :voip, :limit => 15
      t.string  :website, :limit => 30
      t.string  :postcode, :limit => 5
      t.string  :address, :limit => 80
      t.string  :district, :limit => 40
      t.integer :city
      t.integer :state
      t.string  :country_id, :limit => 2
      t.string  :status, :limit => 10, :default => 'active'
      t.integer :branch_id
      t.integer :patron_id, :null => false
      t.string  :twitter, :limit => 30
      t.string  :facebook, :limit => 50
      t.string  :linkedin, :limit => 50
      t.integer :manager_id
      t.integer :person_no
      t.date    :start_date
      t.string  :citizen_no, :limit => 20
      t.date    :birth_date
      t.string  :nation, :limit => 2
      t.string  :avatar, :limit => 100
      t.string  :slug, :limit => 60

      t.timestamps
    end
    
    add_index :personal_people, [:user_id, :patron_id], :unique => true
  end
end
