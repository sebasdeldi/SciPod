# Clear existing data in development environment
if Rails.env.development?
  Rails.logger.debug "🧹 Clearing existing data..."
  Favorite.destroy_all
  Podcast.destroy_all
  Author.destroy_all
  Publisher.destroy_all
  Category.destroy_all
  User.destroy_all
  Rails.logger.debug "✅ Data cleared!"
end

# Helper methods for generating realistic data
def random_email_provider
  %w[gmail.com yahoo.com hotmail.com outlook.com university.edu institute.org research.net].sample
end

def random_first_name
  %w[
    James Mary John Patricia Robert Jennifer Michael Linda William Elizabeth David Barbara
    Richard Susan Joseph Jessica Thomas Sarah Christopher Nancy Daniel Lisa Matthew Betty
    Anthony Helen Mark Sandra Donald Donna Steven Carol Kenneth Ruth Brian Sharon Edward
    Jessica Kevin Nancy Ronald Lisa Jason Helen Matthew Betty Frank Amy Raymond Shirley
    Gregory Deborah Joshua Donna Terry Carol Stephen Ruth Harold Sandra Walter Amy Gerald
    Julie Gerald Stephanie Arthur Christine Lawrence Virginia Jose Catherine Harold Frances
    Peter Samantha Douglas Rachel Jack Carolyn Jordan Janet Johnny Maria Ralph Rebecca
  ].sample
end

def random_last_name
  %w[
    Smith Johnson Williams Brown Jones Garcia Miller Davis Rodriguez Martinez Hernandez
    Lopez Gonzalez Wilson Anderson Thomas Taylor Moore Jackson Martin Lee Perez Thompson
    White Harris Sanchez Clark Ramirez Lewis Robinson Walker Young Allen King Wright
    Scott Torres Nguyen Hill Flores Green Adams Nelson Baker Hall Rivera Campbell Mitchell
    Carter Roberts Gomez Phillips Evans Turner Diaz Parker Cruz Edwards Collins Reyes
    Stewart Morris Morales Murphy Cook Rogers Gutierrez Ortiz Morgan Cooper Ramos Peterson
    Bailey Reed Kelly Howard Ward Cox Diaz Richardson Wood Watson Brooks Bennett Gray
    James Reyes Cruz Hughes Price Myers Long Foster Sanders Ross Morales Powell Sullivan
    Russell Ortiz Jenkins Gutierrez Perry Butler Barnes Fisher Henderson Coleman Simmons
  ].sample
end

def random_academic_title_part
  prefixes = [
    "Advanced", "Applied", "Clinical", "Computational", "Contemporary", "Critical", "Digital",
    "Emerging", "Experimental", "Global", "Innovative", "Integrated", "International",
    "Modern", "Novel", "Practical", "Quantitative", "Recent", "Sustainable", "Theoretical"
  ]

  subjects = [
    "Artificial Intelligence", "Machine Learning", "Data Science", "Biotechnology",
    "Nanotechnology", "Quantum Computing", "Renewable Energy", "Climate Science",
    "Neuroscience", "Genomics", "Robotics", "Cybersecurity", "Blockchain Technology",
    "Materials Science", "Environmental Engineering", "Biomedical Engineering",
    "Software Engineering", "Computer Vision", "Natural Language Processing",
    "Bioinformatics", "Astrophysics", "Molecular Biology", "Cognitive Psychology",
    "Social Psychology", "Developmental Psychology", "Educational Technology",
    "Urban Planning", "Public Health", "Epidemiology", "Pharmacology", "Immunology",
    "Cancer Research", "Stem Cell Research", "Gene Therapy", "Precision Medicine",
    "Digital Health", "Telemedicine", "Health Informatics", "Medical Imaging",
    "Sustainable Agriculture", "Food Security", "Water Resources", "Ocean Science",
    "Atmospheric Science", "Seismology", "Geology", "Archaeology", "Anthropology",
    "Linguistics", "Philosophy", "Ethics", "Law", "Economics", "Finance",
    "Marketing", "Management", "Leadership", "Innovation", "Entrepreneurship"
  ]

  contexts = [
    "Applications", "Approaches", "Analysis", "Assessment", "Challenges", "Developments",
    "Discoveries", "Findings", "Frameworks", "Implications", "Innovations", "Insights",
    "Methods", "Opportunities", "Outcomes", "Perspectives", "Principles", "Progress",
    "Research", "Solutions", "Strategies", "Studies", "Systems", "Techniques",
    "Trends", "Understanding", "Advances", "Breakthroughs", "Case Studies",
    "Best Practices", "Future Directions", "Implementation", "Integration"
  ]

  "#{prefixes.sample} #{subjects.sample}: #{contexts.sample}"
end

def random_academic_summary
  impacts = [
    "significant implications for", "potential to revolutionize", "breakthrough in",
    "novel approach to", "comprehensive analysis of", "innovative solution for",
    "critical examination of", "systematic investigation into", "empirical study of",
    "theoretical framework for", "practical application of", "interdisciplinary approach to"
  ]

  fields = [
    "healthcare delivery", "environmental sustainability", "educational outcomes",
    "technological innovation", "scientific understanding", "policy development",
    "clinical practice", "research methodology", "data analysis", "system optimization",
    "problem-solving", "decision-making", "resource management", "quality improvement",
    "risk assessment", "performance evaluation", "strategic planning", "knowledge discovery"
  ]

  outcomes = [
    "improving patient outcomes", "reducing environmental impact", "enhancing efficiency",
    "advancing scientific knowledge", "supporting evidence-based practice",
    "facilitating informed decision-making", "promoting sustainable development",
    "optimizing resource allocation", "improving quality of life", "addressing global challenges",
    "fostering innovation", "supporting professional development", "enhancing public health",
    "promoting social equity", "advancing technological capabilities"
  ]

  "This research presents #{impacts.sample} #{fields.sample}, with #{outcomes.sample}. " \
  "The findings contribute to our understanding of complex systems and provide valuable " \
  "insights for practitioners, researchers, and policymakers working in related fields."
end

def random_script_excerpt
  openings = [
    "Welcome to today's podcast, where we explore",
    "In this episode, we delve into",
    "Today's discussion focuses on",
    "Our research examines",
    "This study investigates",
    "We present findings on"
  ]

  methods = [
    "systematic review", "meta-analysis", "longitudinal study", "cross-sectional analysis",
    "experimental design", "qualitative research", "quantitative methods", "mixed-methods approach",
    "case study analysis", "comparative study", "pilot study", "randomized controlled trial"
  ]

  findings = [
    "significant correlations", "notable improvements", "positive outcomes", "measurable benefits",
    "important insights", "valuable discoveries", "key findings", "critical observations",
    "promising results", "substantial evidence", "clear patterns", "meaningful relationships"
  ]

  "#{openings.sample} cutting-edge research in this field. Using #{methods.sample}, " \
  "our team identified #{findings.sample} that could reshape how we approach these challenges. " \
  "The implications of this work extend beyond academic research, offering practical applications " \
  "that could benefit practitioners and the broader community. Let's examine the methodology, " \
  "results, and potential impact of these important findings..."
end

def random_issn
  "#{rand(1000..9999)}-#{rand(1000..9999)}"
end

def random_doi
  prefixes = %w[10.1016 10.1038 10.1126 10.1371 10.1073 10.1186 10.3389 10.1109 10.1021 10.1002]
  suffix = "#{('a'..'z').to_a.sample}#{rand(100..999)}.#{rand(1000..9999)}.#{rand(100..999)}"
  "#{prefixes.sample}/#{suffix}"
end

def random_publisher_name
  types = [ "University", "Institute", "Foundation", "Society", "Association", "Academy", "Center" ]
  subjects = [
    "Science", "Technology", "Medicine", "Engineering", "Research", "Innovation",
    "Health", "Education", "Environment", "Sustainability", "Digital", "Advanced",
    "International", "Global", "Applied", "Theoretical", "Clinical", "Experimental"
  ]
  descriptors = [
    "Press", "Publishing", "Publications", "Journal", "Review", "Quarterly",
    "Annual", "Scientific", "Academic", "Professional", "Research", "Studies"
  ]

  "#{subjects.sample} #{types.sample} #{descriptors.sample}"
end

def random_author_name
  "#{random_first_name} #{random_last_name}"
end

# Audio URL to use for all podcasts
SAMPLE_AUDIO_URL = "https://samplelib.com/lib/preview/mp3/sample-15s.mp3"

Rails.logger.debug "🌱 Starting seed process..."

# Create users
Rails.logger.debug "👥 Creating users..."
users = []
50.times do |i|
  first_name = random_first_name
  last_name = random_last_name
  email = "#{first_name.downcase}.#{last_name.downcase}#{i}@#{random_email_provider}"

  user = User.create!(
    email: email,
    password: "password123",
    password_confirmation: "password123"
  )
  users << user
end
Rails.logger.debug { "✅ Created #{users.count} users" }

# Create authors
Rails.logger.debug "✍️ Creating authors..."
authors = []
200.times do |i|
  # Ensure unique names by adding index when needed
  base_name = random_author_name
  name = base_name

  # If this name already exists, add a suffix
  counter = 1
  while Author.exists?(name: name)
    name = "#{base_name} #{counter}"
    counter += 1
  end

  author = Author.create!(name: name)
  authors << author
end
Rails.logger.debug { "✅ Created #{authors.count} authors" }

# Create publishers
Rails.logger.debug "🏢 Creating publishers..."
publishers = []
50.times do |i|
  # Ensure unique names by adding index when needed
  base_name = random_publisher_name
  name = base_name

  # If this name already exists, add a suffix
  counter = 1
  while Publisher.exists?(name: name)
    name = "#{base_name} #{counter}"
    counter += 1
  end

  publisher = Publisher.create!(name: name)
  publishers << publisher
end
Rails.logger.debug { "✅ Created #{publishers.count} publishers" }

# Create categories
Rails.logger.debug "🏷️ Creating categories..."
category_names = [
  "Technology",
  "Science",
  "Medicine",
  "Engineering",
  "Biology",
  "Physics",
  "Chemistry",
  "Mathematics",
  "Computer Science",
  "Data Science",
  "Artificial Intelligence",
  "Machine Learning",
  "Biotechnology",
  "Environmental Science",
  "Psychology",
  "Neuroscience",
  "Materials Science",
  "Energy",
  "Healthcare",
  "Education",
  "Research Methods",
  "Innovation",
  "Sustainability",
  "Climate Science",
  "Public Health",
  "Biomedical Engineering",
  "Social Sciences",
  "Economics",
  "Business",
  "Management"
]

categories = []
category_names.each do |name|
  category = Category.create!(name: name)
  categories << category
end
Rails.logger.debug { "✅ Created #{categories.count} categories" }

# Create podcasts
Rails.logger.debug "🎙️ Creating podcasts..."
podcasts = []
statuses = [ :processing, :ready, :error, :cancelled ]
status_weights = [ 0.1, 0.75, 0.1, 0.05 ] # Mostly ready, some processing/error, few cancelled

500.times do |i|
  # Select random status based on weights
  status = statuses[status_weights.each_with_index.map { |weight, idx| [ weight, idx ] }
                   .sort_by { |weight, _| rand }
                   .last[1]]

  # Ensure unique titles
  base_title = random_academic_title_part
  title = base_title

  # If this title already exists, add a suffix
  counter = 1
  while Podcast.exists?(title: title)
    title = "#{base_title} #{counter}"
    counter += 1
  end

  podcast = Podcast.create!(
    title: title,
    summary: random_academic_summary,
    script: random_script_excerpt + " " + random_academic_summary,
    issn: random_issn,
    doi: "#{random_doi}.#{i}", # Ensure uniqueness
    user: users.sample,
    status: status,
    status_details: status == :processing ? [ "processing_source_file", "generating_script", "generating_audio_file" ].sample : ""
  )

  # Attach audio file from URL for ready podcasts
  if status == :ready
    begin
      require 'open-uri'
      podcast.audio.attach(
        io: URI.open(SAMPLE_AUDIO_URL),
        filename: "podcast_#{podcast.id}_audio.mp3",
        content_type: "audio/mpeg"
      )
    rescue => e
      Rails.logger.debug { "⚠️ Could not attach audio for podcast #{podcast.id}: #{e.message}" }
    end
  end

  podcasts << podcast

  Rails.logger.debug "." if i % 50 == 0
end
Rails.logger.debug { "\n✅ Created #{podcasts.count} podcasts" }

# Associate podcasts with authors (1-4 authors per podcast)
Rails.logger.debug "🔗 Creating podcast-author associations..."
author_count_weights = [ 1, 1, 1, 2, 2, 3, 4 ] # Weighted toward 1-2 authors
podcasts.each do |podcast|
  author_count = author_count_weights.sample
  selected_authors = authors.sample(author_count)
  podcast.authors = selected_authors
end
Rails.logger.debug "✅ Created podcast-author associations"

# Associate podcasts with publishers (0-2 publishers per podcast)
Rails.logger.debug "🔗 Creating podcast-publisher associations..."
publisher_count_weights = [ 0, 1, 1, 1, 2 ] # Weighted toward 0-1 publishers
podcasts.each do |podcast|
  publisher_count = publisher_count_weights.sample
  if publisher_count > 0
    selected_publishers = publishers.sample(publisher_count)
    podcast.publishers = selected_publishers
  end
end
Rails.logger.debug "✅ Created podcast-publisher associations"

# Associate podcasts with categories (1-3 categories per podcast)
Rails.logger.debug "🔗 Creating podcast-category associations..."
category_count_weights = [ 1, 1, 1, 2, 2, 3 ] # Weighted toward 1-2 categories
podcasts.each do |podcast|
  category_count = category_count_weights.sample
  selected_categories = categories.sample(category_count)
  podcast.categories = selected_categories
end
Rails.logger.debug "✅ Created podcast-category associations"

# Create favorites (realistic distribution)
Rails.logger.debug "❤️ Creating favorites..."
favorites_count = 0
favorite_count_weights = [ 0, 0, 1, 1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 10, 12, 15, 20 ] # Weighted toward fewer

users.each do |user|
  # Each user favorites 0-20 podcasts (weighted toward fewer)
  favorite_count = favorite_count_weights.sample

  if favorite_count > 0
    # Bias toward favoriting "ready" podcasts
    available_podcasts = podcasts.select { |p| p.status == "ready" }
    available_podcasts += podcasts.sample([ podcasts.count / 4, 50 ].min) # Add some variety

    selected_podcasts = available_podcasts.uniq.sample([ favorite_count, available_podcasts.count ].min)

    selected_podcasts.each do |podcast|
      begin
        Favorite.create!(user: user, podcast: podcast)
        favorites_count += 1
      rescue ActiveRecord::RecordNotUnique
        # Skip if already favorited
      end
    end
  end
end
Rails.logger.debug { "✅ Created #{favorites_count} favorites" }

# Final statistics
Rails.logger.debug "\n📊 Seed Data Summary:"
Rails.logger.debug { "👥 Users: #{User.count}" }
Rails.logger.debug { "✍️ Authors: #{Author.count}" }
Rails.logger.debug { "🏢 Publishers: #{Publisher.count}" }
Rails.logger.debug { "🏷️ Categories: #{Category.count}" }
Rails.logger.debug { "🎙️ Podcasts: #{Podcast.count}" }
Rails.logger.debug "   📊 By Status:"
Rails.logger.debug { "   ⏳ Processing: #{Podcast.where(status: :processing).count}" }
Rails.logger.debug { "   ✅ Ready: #{Podcast.where(status: :ready).count}" }
Rails.logger.debug { "   ❌ Error: #{Podcast.where(status: :error).count}" }
Rails.logger.debug { "   🚫 Cancelled: #{Podcast.where(status: :cancelled).count}" }
Rails.logger.debug { "❤️ Favorites: #{Favorite.count}" }
Rails.logger.debug { "🔗 Podcast-Author associations: #{Podcast.joins(:authors).count}" }
Rails.logger.debug { "🔗 Podcast-Publisher associations: #{Podcast.joins(:publishers).count}" }
Rails.logger.debug { "🔗 Podcast-Category associations: #{Podcast.joins(:categories).count}" }

# Show some example data
Rails.logger.debug "\n🎯 Sample Data:"
sample_podcast = Podcast.includes(:authors, :publishers, :categories, :favorites).ready.first
if sample_podcast
  Rails.logger.debug { "📚 Sample Podcast: '#{sample_podcast.title}'" }
  Rails.logger.debug { "   👤 Creator: #{sample_podcast.user.email}" }
  Rails.logger.debug { "   ✍️ Authors: #{sample_podcast.authors.pluck(:name).join(', ')}" }
  Rails.logger.debug { "   🏢 Publishers: #{sample_podcast.publishers.pluck(:name).join(', ')}" } if sample_podcast.publishers.any?
  Rails.logger.debug { "   🏷️ Categories: #{sample_podcast.categories.pluck(:name).join(', ')}" }
  Rails.logger.debug { "   ❤️ Favorites: #{sample_podcast.favorites.count}" }
  Rails.logger.debug { "   📝 Summary: #{sample_podcast.summary[0..100]}..." }
end

most_favorited = Podcast.left_joins(:favorites).group(:id).order('COUNT(favorites.id) DESC').first
if most_favorited
  Rails.logger.debug { "\n🏆 Most Favorited Podcast: '#{most_favorited.title}' (#{most_favorited.favorites.count} favorites)" }
end

Rails.logger.debug "\n🎉 Seeding completed successfully!"
