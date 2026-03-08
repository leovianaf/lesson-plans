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

puts "Criando 5 Planos de Aula Sintéticos Completos..."
modelos_ia = [ "GPT-4o", "Gemini 3.1", "Claude 3.5 Sonnet" ]

# Dados base retirados do seu exemplo
habilidades_bncc = "• EF05MA21\n• EF05MA22"
descricoes_bncc = "• Reconhecer volume como grandeza associada a sólidos geométricos e medir volumes por meio de empilhamento de cubos, utilizando, preferencialmente, objetos concretos."
objetivos = "• Calcular correspondência entre volume e capacidade por meio de deslocamento de líquidos.\n• Relacionar centímetro cúbico com milímetro cúbico."
materiais = "• Lápis\n• Borracha\n• Caderno\n• Cubos de montar"
taxonomia_bloom = "• Compreender\n• Aplicar\n• Analisar"

# Transformando o array de hashes das etapas em um texto formatado
etapas_brutas = [
  {
    'titulo' => 'Resumo da aula',
    'tempo_sugerido' => '',
    'conteudo' => "Orientações: Este slide não é um substituto para as anotações para o professor e não deve ser apresentado para os alunos. Trata-se apenas de um resumo da proposta para apoiá-lo na aplicação do plano em sala de aula.\nCompartilhe o objetivo da aula com os alunos antes de aplicar proposta."
  },
  {
    'titulo' => 'Objetivo',
    'tempo_sugerido' => '2 minutos.',
    'conteudo' => "Orientação: Projete ou leia o objetivo para a turma.\nPropósito: Compartilhar o objetivo da aula."
  }
]

etapas_formatadas = etapas_brutas.map do |etapa|
  tempo = etapa['tempo_sugerido'].presence || 'Tempo não definido'
  "📌 #{etapa['titulo']} (#{tempo})\n#{etapa['conteudo']}"
end.join("\n\n")


5.times do |i|
  plano = LessonPlan.create!(
    csv_uuid: SecureRandom.uuid,
    title: "Plano de Aula Completo - Geometria #{i + 1}",
    discipline: "Matemática",
    theme: "Geometria e Volume",
    grade: "5º Ano",
    duration: "50 minutos",
    url: "https://novaescola.org.br/plano-de-aula/teste-#{i}",
    url_key: "teste-geometria-#{i}",
    bncc_skills: habilidades_bncc,
    bncc_descriptions: descricoes_bncc,
    objectives: objetivos,
    materials: materiais,
    bloom_taxonomy: taxonomia_bloom,
    steps: etapas_formatadas,
    full_content: "Conteúdo JSON bruto ou texto longo original ficaria salvo aqui...",
    evaluated: false
  )

  # Para cada plano, cria 3 avaliações (uma de cada IA) com notas aleatórias
  modelos_ia.each do |modelo|
    LlmEvaluation.create!(
      lesson_plan: plano,
      ai_model_name: modelo,
      score: rand(5..10),
      rationale: "Justificativa sintética gerada pelo modelo #{modelo}. Ele avaliou o alinhamento com a BNCC e a clareza das etapas propostas."
    )
  end
end

puts "✅ Seed concluído! 1 Professor, 5 Planos complexos e 15 Avaliações criadas."