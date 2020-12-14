# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_05_165025) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.date "publication_date"
    t.integer "security_level"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "nominations", force: :cascade do |t|
    t.string "status"
    t.date "nomination_date"
    t.text "comments"
    t.bigint "document_id", null: false
    t.bigint "team_member_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id"], name: "index_nominations_on_document_id"
    t.index ["team_member_id"], name: "index_nominations_on_team_member_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "team_members", force: :cascade do |t|
    t.string "role"
    t.integer "privileges"
    t.integer "security_level"
    t.bigint "person_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["person_id"], name: "index_team_members_on_person_id"
    t.index ["team_id"], name: "index_team_members_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "description"
    t.string "format_style"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "nominations", "documents"
  add_foreign_key "nominations", "team_members"
  add_foreign_key "team_members", "people"
  add_foreign_key "team_members", "teams"
end
