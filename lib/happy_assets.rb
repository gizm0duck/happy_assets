module HappyAssets
  class Base
    CONFIG_FILE   = "#{RAILS_ROOT}/config/happy_assets.yml"
    FILE_PREPEND  = "packaged"
    JSMIN_PATH    = "#{RAILS_ROOT}/vendor/plugins/happy_assets/lib"
    cattr_accessor :packages
    HappyAssets::Base.packages = YAML::load(File.open(CONFIG_FILE)) if File.exists?(CONFIG_FILE)
    class << self
      # Generate all packages that are outlined in the config file
      def pack(*package_types)
        package_types = ['js', 'css'] if package_types.empty?
        for package_type in package_types
          Base.generate_packages(package_type)
        end
        return "All #{package_types.join(' and ')} packages generated successfully"
      end
      
      # Remove all packed files, or only of a particular type(js or css)
      def unpack(*package_types)
        package_types = ['js', 'css'] if package_types.empty?
        for package_type in package_types
          HappyAssets::Base.packages[package_type].keys.collect do |package|
            FileUtils.rm packed_filename(package, package_type) rescue "#{packed_filename(package, package_type)} does not exist"
          end
        end
        return "All #{package_types.join(' and ')} packages removed"
      end
    
      ###
      # Use this to create a specific package if you need to
      # HappyAssetPackager::Base.generate_package('css', 'base')
      ###
      def generate_package(package_type, package)
        files = self.packages[package_type][package]
        # Iterate over all files in the package and create a single file out of them using the package name|
        File.open(packed_filename(package, package_type), "w+") do |file| 
          file.write(join_file_contents(files, package_type))
        end
        send("compress_#{package_type}", package)
        return "#{package} package generated successfully"
      end
    
      ###
      # Create all packages for a particular package_type (js, css)
      # HappyAssetPackager::Base.generate_package('css')
      ###
      def generate_packages(package_type)
        self.packages[package_type].each do |package, files|
          generate_package(package_type, package)
        end
        return "All #{package_type} packages generated successfully"
      end
    
      def join_file_contents(files, package_type)
        files.collect { |filename| File.read(base_filename(filename, package_type)) }.join("\n\n")
      end
    
      def compress_js(package)
        temp_file    = temp_filename(package, 'js')
        source_file  = packed_filename(package, 'js')
        # write out to a temp file
        File.open(temp_file, "w") {|f| f.write(File.read(source_file)) }
        # compress file with JSMin library        
        `ruby #{JSMIN_PATH}/jsmin.rb <#{temp_file} >#{source_file} \n`
        FileUtils.rm(temp_file)
      end
      
      def compress_css(package)
        source_file = packed_filename(package, 'css')
        css         = File.read(source_file)
        # From Asset Packager plugin
        css.gsub!(/\s+/, " ")     # collapse space
        css.gsub!(/\} /, "}\n")   # add line breaks
        css.gsub!(/\n$/, "")      # remove last break
        css.gsub!(/ \{ /, " {")   # trim inside brackets
        css.gsub!(/; \}/, "}")    # trim inside brackets
        File.open(source_file, 'w') {|f| f.write(css) }
      end
    
      ###
      # Methods to handle dealing with all the ugly file names being passed around
      ###
        ## calls either js_root or css_root depending on package_type being passed in
        def base_path(package_type)
          send("#{package_type}_root")
        end
    
        def js_root
          File.join(RAILS_ROOT, 'public', 'javascripts')
        end
    
        def css_root
          File.join(RAILS_ROOT, 'public', 'stylesheets')
        end
        
        def public_packed_filename(package, package_type)
          "#{FILE_PREPEND}_#{package}.#{package_type}"
        end
        
        def packed_filename(package, package_type)
          File.join(base_path(package_type), public_packed_filename(package, package_type))
        end
      
        def temp_filename(package, package_type)
          filename = packed_filename(package, package_type).split('.')
          filename.last << '_UNCOMPRESSED'
          filename.join('.')
        end
      
        def base_filename(filename, package_type)
          File.join(base_path(package_type), filename)
        end
    end
  end
end