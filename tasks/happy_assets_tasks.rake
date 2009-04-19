# desc "Explaining what the task does"
# task :happy_assets do
#   # Task goes here
# end

namespace :happy_assets do
  
  desc "initialization for happy_assets plugin"
  task :initialize => :environment do
    unless File.exists?(HappyAssets::Base::CONFIG_FILE)
      Dir.chdir("public/javascripts")
      js = Dir.glob('*.js')
      Dir.chdir("../stylesheets")
      css = Dir.glob('*.css')
      
      File.open(HappyAssets::Base::CONFIG_FILE, "w+") do |file|
        file.write({
          'js' => {
            'default' => js,
            'extra'   => []
          },
          'css' => {
            'default' => css,
            'extra'   => []
          }
        }.to_yaml)
      end
      puts "Created: #{HappyAssets::Base::CONFIG_FILE}"
    else
      puts "Nothing to do"
    end
  end
  
  desc "package assets for deployment"
  task :pack => :environment do
   puts HappyAssets::Base.pack
  end
  
  desc "delete packaged assets to force unpacked versions to be displayed for development and testing"
  task :unpack => :environment do
   puts HappyAssets::Base.unpack
  end
end