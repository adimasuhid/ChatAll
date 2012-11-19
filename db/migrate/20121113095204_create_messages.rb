class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender_id
      t.string :receiver_id
      t.string :message_body
      t.string :message_subject

      t.timestamps
    end
  end
end
