module HappyAssets
  module Helper
    def packaged_javascript_include(*packages)
      javascript_to_load = happy_assets_helper('js', packages)
      return javascript_include_tag(*javascript_to_load)
    end

    def packaged_stylesheet_include(*packages)
      stylesheet_to_load = happy_assets_helper('css', packages)
      return stylesheet_link_tag(*stylesheet_to_load)
    end

    def happy_assets_helper(package_type, packages)
      returning Array.new do |items_to_load|
        for package in packages
          raise "#{package_type} package '#{package}' does not exist" unless HappyAssets::Base.packages[package_type][package.to_s]
          if File.exist?(HappyAssets::Base.packed_filename(package, package_type))
            items_to_load << HappyAssets::Base.public_packed_filename(package, package_type)
          else
            items_to_load.concat(HappyAssets::Base.packages[package_type][package.to_s])
          end
        end
      end
    end
  end
end

ActionView::Base.send(:include, HappyAssets::Helper)