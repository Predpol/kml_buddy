require "kml_buddy/version"
require "zip"
require "nokogiri"

module KmlBuddy
  class XML

    def initialize(data)
      @data = data
    end

    def to_kml
      kml = ''
      Zip::InputStream.open(StringIO.new(@data)) do |io|
        while entry = io.get_next_entry
          if entry.name[-4, entry.name.length - 1] == '.kmz'
            kml << io.read
          else
            raise "unknown entry in kmz file: #{entry.name}"
          end
        end
      end
      @data = kml
      return @data
    end

    def to_kmz
      stringio = Zip::OutputStream::write_buffer do |zio|
        zio.put_next_entry('formatted.kmz')
        zio.write(@data)
      end
      stringio.rewind
      @data = stringio.sysread
      return @data
    end

    def style_kml
      # parse kml_data
      doc = Nokogiri::XML(@data)

      # delete Style and StyleMap tags
      doc.xpath('//xmlns:Style').each do |node|
        node.remove
      end
      doc.xpath('//xmlns:StyleMap').each do |node|
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
      doc.xpath('//xmlns:styleUrl').each do |node|
        node.content = '#predpol-default'
      end

      # output updated kml
      @data = doc.to_s
      return @data
    end
  end
end