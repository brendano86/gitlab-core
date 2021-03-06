# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170906182752) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_log_states", primary_key: "event_id", force: :cascade do |t|
  end

  create_table "file_registry", force: :cascade do |t|
    t.string "file_type", null: false
    t.integer "file_id", null: false
    t.integer "bytes", limit: 8
    t.string "sha256"
    t.datetime "created_at", null: false
  end

  add_index "file_registry", ["file_type", "file_id"], name: "index_file_registry_on_file_type_and_file_id", unique: true, using: :btree
  add_index "file_registry", ["file_type"], name: "index_file_registry_on_file_type", using: :btree

  create_table "project_registry", force: :cascade do |t|
    t.integer "project_id", null: false
    t.datetime "last_repository_synced_at"
    t.datetime "last_repository_successful_sync_at"
    t.datetime "created_at", null: false
    t.boolean "resync_repository", default: true, null: false
    t.boolean "resync_wiki", default: true, null: false
    t.datetime "last_wiki_synced_at"
    t.datetime "last_wiki_successful_sync_at"
  end

  add_index "project_registry", ["last_repository_successful_sync_at"], name: "index_project_registry_on_last_repository_successful_sync_at", using: :btree
  add_index "project_registry", ["last_repository_synced_at"], name: "index_project_registry_on_last_repository_synced_at", using: :btree
  add_index "project_registry", ["project_id"], name: "index_project_registry_on_project_id", unique: true, using: :btree
  add_index "project_registry", ["resync_repository"], name: "index_project_registry_on_resync_repository", using: :btree
  add_index "project_registry", ["resync_wiki"], name: "index_project_registry_on_resync_wiki", using: :btree

end
