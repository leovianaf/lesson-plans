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

puts "Criando 5 Planos de Aula Sintéticos com Notas..."
modelos_ia = [ "GPT-4o", "Gemini 3.1", "Claude 3.5 Sonnet" ]

5.times do |i|
  plano = LessonPlan.create!(
    csv_uuid: SecureRandom.uuid,
    title: "Plano de Aula de Teste #{i + 1}",
    discipline: "Matemática",
    objectives: "Garantir que os alunos entendam a base de equações de 1º grau.",
    steps: "1. Introdução teórica\n2. Exercícios no quadro\n3. Correção coletiva",
    full_content: "Conteúdo completo detalhado da aula #{i + 1}...",
    evaluated: false
  )

  # Para cada plano, cria 3 avaliações (uma de cada IA) com notas aleatórias
  modelos_ia.each do |modelo|
    LlmEvaluation.create!(
      lesson_plan: plano,
      ai_model_name: modelo,
      score: rand(5..10), # Gera uma nota aleatória entre 5 e 10
      rationale: "Justificativa sintética gerada pelo #{modelo}."
    )
  end
end

puts "✅ Seed concluído! 1 Professor, 5 Planos e 15 Avaliações criadas."
