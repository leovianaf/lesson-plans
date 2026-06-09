# frozen_string_literal: true

require "csv"
require "yaml"

class CsvLessonPlanImporter
  DEFAULT_GLOB = Rails.root.join("db", "seeds_data", "*.csv").freeze
  MODEL_SUFFIX = "_nota_geral"
  CRITERIA_SUFFIXES = %w[d1 d2 d3 d4 d5].freeze

  def self.call(...)
    new(...).call
  end

  def initialize(csv_path: nil)
    @csv_path = Pathname(csv_path || default_csv_path)
  end

  def call
    raise ArgumentError, "CSV file not found: #{@csv_path}" unless @csv_path.exist?

    imported_plans = 0
    imported_evaluations = 0

    ActiveRecord::Base.transaction do
      each_row do |row|
        lesson_plan = import_lesson_plan!(row)
        imported_plans += 1
        imported_evaluations += import_llm_evaluations!(lesson_plan, row)
      end
    end

    { plans: imported_plans, evaluations: imported_evaluations, csv_path: @csv_path.to_s }
  end

  private

  def each_row
    CSV.foreach(@csv_path, headers: true, encoding: "bom|utf-8") do |row|
      yield row.to_h.transform_keys { |key| normalize_header(key) }
    end
  end


  def normalize_header(value)
    value.to_s.delete_prefix("\uFEFF").strip
  end

  def import_lesson_plan!(row)
    attrs = {
      title: row["titulo"],
      discipline: row["disciplina"],
      theme: normalize_scalar(row["tema"]),
      bncc_skills: normalize_list_text(row["habilidades_bncc"]),
      bncc_descriptions: normalize_scalar(row["avaliacao"]),
      grade: row["serie_escolar"],
      objectives: normalize_list_text(row["objetivos"]),
      materials: normalize_list_text(row["materiais"]),
      steps: normalize_steps(row["etapas"]),
      duration: row["duracao"],
      url: row["url"],
      url_key: row["url_key"],
      bloom_taxonomy: normalize_list_text(row["nivel_bloom"]),
      full_content: row["conteudo_completo"],
      evaluated: false
    }

    lesson_plan = LessonPlan.find_or_initialize_by(csv_uuid: row.fetch("uuid"))
    lesson_plan.assign_attributes(attrs)
    lesson_plan.save!
    lesson_plan.llm_evaluations.delete_all
    lesson_plan
  end

  def import_llm_evaluations!(lesson_plan, row)
    model_names(row).count do |model_name|
      lesson_plan.llm_evaluations.create!(
        lesson_plan_uuid: lesson_plan.csv_uuid,
        ai_model_name: model_name,
        score: normalize_score(row["#{model_name}_nota_geral"]),
        score_d1: normalize_score(row["#{model_name}_d1"]),
        score_d2: normalize_score(row["#{model_name}_d2"]),
        score_d3: normalize_score(row["#{model_name}_d3"]),
        score_d4: normalize_score(row["#{model_name}_d4"]),
        score_d5: normalize_score(row["#{model_name}_d5"]),
        rationale: normalize_scalar(row["#{model_name}_resumo"])
      )
    end
  end

  def model_names(row)
    row.keys.filter_map do |key|
      next unless key.end_with?(MODEL_SUFFIX)

      key.delete_suffix(MODEL_SUFFIX)
    end
  end

  def normalize_list_text(value)
    parsed = parse_collection(value)
    return normalize_scalar(value) unless parsed.is_a?(Array)
    return nil if parsed.empty?

    parsed.map { |item| "- #{item.to_s.strip}" }.join("\n")
  end

  def normalize_steps(value)
    parsed = parse_collection(value)
    return normalize_scalar(value) unless parsed.is_a?(Array)
    return nil if parsed.empty?

    parsed.map do |step|
      next step.to_s unless step.is_a?(Hash)

      title = step["titulo"] || step[:titulo]
      time = step["tempo_sugerido"] || step[:tempo_sugerido]
      content = step["conteudo"] || step[:conteudo]

      header = title.to_s.strip
      header = "#{header} (#{time})" if time.present?
      [header, content.to_s.strip].reject(&:blank?).join("\n")
    end.join("\n\n")
  end

  def normalize_scalar(value)
    return nil if value.nil?

    text = value.to_s.strip
    return nil if text.blank? || text == "[]"

    text
  end

  def normalize_score(value)
    text = normalize_scalar(value)
    return nil if text.nil?

    BigDecimal(text)
  end

  def parse_collection(value)
    text = normalize_scalar(value)
    return nil if text.nil?

    YAML.safe_load(text, permitted_classes: [], aliases: false)
  rescue Psych::SyntaxError
    nil
  end

  def default_csv_path
    Dir[DEFAULT_GLOB.to_s].sort.last || DEFAULT_GLOB
  end
end
