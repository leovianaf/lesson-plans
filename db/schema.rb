# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_28_174000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "lesson_plans", force: :cascade do |t|
    t.string "bloom_taxonomy"
    t.text "bncc_descriptions"
    t.text "bncc_skills"
    t.datetime "created_at", null: false
    t.string "csv_uuid"
    t.string "discipline"
    t.string "duration"
    t.boolean "evaluated", default: false
    t.text "full_content"
    t.string "grade"
    t.text "materials"
    t.text "objectives"
    t.text "steps"
    t.string "theme"
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "url_key"
    t.index ["csv_uuid"], name: "index_lesson_plans_on_csv_uuid", unique: true
  end

  create_table "llm_evaluations", force: :cascade do |t|
    t.string "ai_model_name"
    t.datetime "created_at", null: false
    t.bigint "lesson_plan_id", null: false
    t.text "rationale"
    t.integer "score"
    t.datetime "updated_at", null: false
    t.index ["lesson_plan_id"], name: "index_llm_evaluations_on_lesson_plan_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "teacher_reviews", force: :cascade do |t|
    t.bigint "chosen_llm_evaluation_id", null: false
    t.datetime "created_at", null: false
    t.bigint "lesson_plan_id", null: false
    t.text "observation"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chosen_llm_evaluation_id"], name: "index_teacher_reviews_on_chosen_llm_evaluation_id"
    t.index ["lesson_plan_id"], name: "index_teacher_reviews_on_lesson_plan_id"
    t.index ["user_id"], name: "index_teacher_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "llm_evaluations", "lesson_plans"
  add_foreign_key "sessions", "users"
  add_foreign_key "teacher_reviews", "lesson_plans"
  add_foreign_key "teacher_reviews", "llm_evaluations", column: "chosen_llm_evaluation_id"
  add_foreign_key "teacher_reviews", "users"
end
