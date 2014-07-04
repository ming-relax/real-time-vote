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

ActiveRecord::Schema.define(version: 20140702150401) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: true do |t|
    t.integer  "room_id"
    t.integer  "round_id"
    t.integer  "betray_penalty"
    t.integer  "moneys",                            array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_id",                          array: true
    t.string   "status",         default: "active"
    t.integer  "acked_users",                       array: true
  end

  create_table "offline_records", force: true do |t|
    t.integer "user_id", null: false
  end

  create_table "proposals", force: true do |t|
    t.integer  "group_id"
    t.integer  "round_id"
    t.integer  "submitter"
    t.integer  "acceptor"
    t.boolean  "accepted"
    t.integer  "submitter_penalty"
    t.integer  "acceptor_penalty"
    t.integer  "moneys",            array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rooms", force: true do |t|
    t.integer "users_id", null: false, array: true
  end

  create_table "users", force: true do |t|
    t.string   "username",                     null: false
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "room_id"
    t.integer  "group_id"
    t.integer  "total_earning",    default: 0
    t.integer  "round_id"
    t.string   "weibo"
    t.boolean  "admin"
  end

end
