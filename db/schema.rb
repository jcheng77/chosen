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

ActiveRecord::Schema.define(version: 20150212065754) do

  create_table "brand_model_tencents", force: true do |t|
    t.integer  "brand_id"
    t.string   "brand_name"
    t.string   "first_letter"
    t.string   "brand_logo"
    t.string   "brand_country"
    t.integer  "man_id"
    t.string   "man_name"
    t.integer  "serial_id"
    t.string   "serial_name"
    t.string   "serial_pic"
    t.string   "serial_first"
    t.string   "serial_low_price"
    t.string   "serial_high_price"
    t.string   "serial_lever"
    t.string   "serial_country"
    t.string   "serial_displace"
    t.string   "serial_producing_state"
    t.string   "serial_video"
    t.string   "serial_use_way"
    t.string   "serial_competion"
    t.string   "hd_pics",                limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "good_comments"
    t.string   "bad_comments"
  end

  create_table "car_brands", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_colors", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_makers", force: true do |t|
    t.string   "name"
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_models", force: true do |t|
    t.string   "name"
    t.integer  "year"
    t.integer  "maker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_models_shops", force: true do |t|
    t.integer "model_id"
    t.integer "shop_id"
  end

  create_table "car_pics", force: true do |t|
    t.string   "pic_url"
    t.integer  "model_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_prices", force: true do |t|
    t.date     "offering_date"
    t.decimal  "price",         precision: 10, scale: 0
    t.integer  "trim_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_trims", force: true do |t|
    t.string   "name"
    t.integer  "model_id"
    t.decimal  "guide_price", precision: 12, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cars", force: true do |t|
    t.string   "name"
    t.string   "model"
    t.decimal  "price",      precision: 12, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vehicle_id"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "vehicles", force: true do |t|
    t.string   "brand"
    t.string   "model"
    t.float    "lowest_price",  limit: 24
    t.float    "highest_price", limit: 24
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "xcar_short_comments", force: true do |t|
    t.string   "brand_name"
    t.string   "serial_name"
    t.string   "good_comments"
    t.string   "short_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
    t.integer  "serial_id"
    t.integer  "tencent_sid"
    t.string   "hd_pic"
  end

end
