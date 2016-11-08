namespace 'open-api' do

  desc 'Creates OpenApi v2 documentation from metadata defined in code'
  task :docs, [:base_paths, :output_file_path] => :environment do |_, args|
    rails = File.join(Dir.getwd, 'config', 'environment.rb')
    require rails

    base_paths = args[:base_paths] || OpenApi.global_metadata[:base_paths]
    errors = []
    if base_paths.blank?
      errors << 'Missing API base paths; Must be passed as argument, or base_paths must be ' \
          'configured in the OpenApi initializer (config/initializers/open_api.rb)'
    end

    output_file_path = args[:output_file_path] || OpenApi.global_metadata[:output_file_path]
    if output_file_path.blank?
      errors << 'Missing OpenApi output file path; Must be passed as argument, or ' \
          'outout_file_path must be configured in the OpenApi initializer ' \
          '(config/initializers/open_api.rb)'
    end

    if errors.blank?
      OpenApi::Generator.write(base_paths: base_paths, output_file_path: output_file_path,
          stdout: true)
      puts 'OpenApi documentation generation completed successfully!'
    else
      puts 'Rake task failed with the following error(s):'
      errors.each { |error| puts "  * #{error}" }
    end
  end
end

# Support use of open-api or open_api as a task namespace
namespace 'open_api' do
  task :docs, [:base_paths, :output_file_path] => :environment do |_, args|
    Rake::Task['open-api:docs'].invoke(*args)
  end
end
