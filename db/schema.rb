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

ActiveRecord::Schema.define(version: 20140211215110) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mappings", force: true do |t|
    t.integer  "quanto_key_id"
    t.integer  "api_key_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.boolean  "revoked",       default: false
  end

  create_table "oauth_keys", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "token_secret"
    t.string   "plugin"
    t.integer  "mapping_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
