require "kml_buddy/version"
require "zip"
require "nokogiri"

module KmlBuddy
    def unzip_kmz(filename)
        Zip::File.open(filename) do |zipfile|
          zipfile.each do |file|
              file_path = File.join('unzipped', file.name)
              FileUtils.mkdir_p(File.dirname(file_path))
            zipfile.extract(file, file_path)
          end
        end
    end
    
    def zip_kml(filename)
        name = filename.chomp(File.extname(filename)) + '.kmz'
        Zip::File.open(name, Zip::File::CREATE) do |zipfile|
            zipfile.add(filename, filename)
        end
    end
    
    def replace_kml_style_tag(filename)
        # open uploaded kml file
        original_kml = File.open(filename, 'r')
        doc = Nokogiri::XML(original_kml)
        original_kml.close
        doc.remove_namespaces!
        
        # delete Style and StyleMap tags
        doc.css('Style').each do |node|
            node.remove
        end
        doc.css('StyleMap').each do |node|
            node.remove
        end
        
        # create our tags
        style = Nokogiri::XML::Node.new('Style', doc)
        style['id'] = 'predpol-default'
        linestyle = Nokogiri::XML::Node.new('LineStyle', doc)
        linestyle_color = Nokogiri::XML::Node.new('color', doc)
        polystyle = Nokogiri::XML::Node.new('PolyStyle', doc)
        polystyle_color = Nokogiri::XML::Node.new('color', doc)
        linestyle << linestyle_color
        polystyle << polystyle_color
        
        # add content to tags
        linestyle_color.content = 'ff000000'
        polystyle_color.content = '54ffffff'
        style << linestyle
        style << polystyle
        
        # add Style tag to beginning of kml
        document_node = doc.css('Document').first
        document_node.children.first.add_previous_sibling(style)
    
        # change all styleUrl tags to point to predpol-default
        doc.css('styleUrl').each do |node|
            node.content = '#predpol-default'
        end
        
        # save to new kml
        modified_kml = File.open("modified.kml", "w")
        modified_kml.puts doc
        modified_kml.close
    end
    
    replace_kml_style_tag('london.kml')
end
