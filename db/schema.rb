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

ActiveRecord::Schema.define(version: 20160927132854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "domains", force: :cascade do |t|
    t.string   "domainname"
    t.string   "domaintoken"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "image"
    t.string   "domaintoken2"
  end

  create_table "emails", force: :cascade do |t|
    t.integer  "domain_id"
    t.string   "mailname"
    t.date     "birth_date"
    t.string   "iname"
    t.string   "fname"
    t.text     "hintq"
    t.decimal  "sex"
    t.boolean  "enabled"
    t.boolean  "signed_eula"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "fio"
    t.string   "aliases"
    t.string   "pswrd"
    t.string   "hinta"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "login"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
