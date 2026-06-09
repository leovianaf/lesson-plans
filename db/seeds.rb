puts "Limpando o banco de dados..."
TeacherReview.destroy_all
LlmEvaluation.destroy_all
LessonPlan.destroy_all
User.destroy_all

puts "Criando usuário do Professor..."
User.create!(
  email_address: "professor@teste.com",
  password: "admin"
)

puts "Importando planos e avaliações do CSV..."
result = CsvLessonPlanImporter.call

puts "✅ Seed concluído! #{result[:plans]} planos e #{result[:evaluations]} avaliações importados de #{result[:csv_path]}."
