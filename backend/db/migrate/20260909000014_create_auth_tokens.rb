class CreateAuthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :auth_tokens do |t|
      t.references :membership, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.references :replaced_by, foreign_key: { to_table: :auth_tokens }
      t.timestamps
    end

    add_index :auth_tokens, :token_digest, unique: true
  end
end
