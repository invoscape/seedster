class SeedsterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def settings
      empty_directory "db/seedster"
      copy_file "datasets.yml", "db/seedster/datasets.yml"
  end
end
