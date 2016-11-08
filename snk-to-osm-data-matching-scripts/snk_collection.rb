class SnkCollection
  def initialize path_to_csv, lib_filter
    @lib_filter = lib_filter
    csv = File.read path_to_csv
    libraries_csv = csv.split("\n")[1..-1]
    puts "Loaded #{libraries_csv.length} SNK records"

    @libraries = []
    @library_search_index = {}
    libraries_csv.each do |library_raw_data|
      library =  SnkLibrary.new(library_raw_data)
      if library.is_matching(lib_filter)
        @libraries << library
        if(library.street)
          search_key = [library.city, library.street, library.addressnumber]
        else
          search_key = [library.city, library.addressnumber]
        end
        @library_search_index[search_key] = library 
      end
    end
    puts "Filtered to #{@libraries.length} SNK records"
  end

  def load_osm_data
    json_osm_response = execute_overpass_query
    json_osm_response['elements'].each do |r|
      if(r['tags']['addr:street'])
        search_key = [r['tags']['addr:city'], r['tags']['addr:street'],r['tags']['addr:streetnumber']]
      else
        search_key = [r['tags']['addr:city'], r['tags']['addr:housenumber']]
      end
      
      snk_library_matching_to_osm_result = @library_search_index[search_key]

      if snk_library_matching_to_osm_result
        snk_library_matching_to_osm_result.add_osm_data r
      end
    end

    puts "enhanced #{@libraries.select {|l| l.osm_address_found?}.size} SNK libraries with osm data"
  end

  def to_osm_change_xml
    xml = <<-STRING
<?xml version="1.0" encoding="UTF-8"?>
      <osmChange version="0.6" generator="Ruby">\n
    STRING
    xml << "\t<create>\n"
    xml << @libraries.map {|l| l.to_osm_change_create_xml}.compact.join("\n")
    xml << "\n\t</create>\n"
    xml << "</osmChange>"

    xml
  end

  def to_html
    html = <<-STRING
    <html>
    <style>
      table {
          font-family: sans-serif;
      }
      table tr td {
          padding: 3px;
          border: 1px solid grey;
      }
    </style>
    SNK libraries filtered by #{@lib_filter}
    <table>
    STRING
    html << @libraries.map {|l| l.to_html}.join("\n")
    html += "<table></html>"
    html
  end

  private

  def to_overpass_query
    overpass_query = "<osm-script bbox=\"48.0456,19.2747,48.4641,19.9706\" output=\"json\">"
    @libraries.each do |library|
      overpass_query += library.to_overpass_query
    end
    overpass_query += "</osm-script>"
  end

  def execute_overpass_query
    File.open('./tmp/query.osm', 'w'){|f| f.write to_overpass_query}
    #response = `curl -X POST -d @tmp/query.osm http://overpass-api.de/api/interpreter`
    #json = JSON.parse response
    json = {"version"=>0.6, "generator"=>"Overpass API", "osm3s"=>{"timestamp_osm_base"=>"2016-11-08T11:03:02Z", "copyright"=>"The data included in this document is from www.openstreetmap.org. The data is made available under ODbL."}, "bounds"=>{"minlat"=>48.0456, "minlon"=>19.2747, "maxlat"=>48.4641, "maxlon"=>19.9706}, "elements"=>[{"type"=>"way", "id"=>59563451, "timestamp"=>"2016-10-30T14:48:55Z", "version"=>2, "changeset"=>43284992, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3599817, "lon"=>19.5416568}, "nodes"=>[738865203, 738865018, 738865175, 738865179, 738865139, 738865203], "tags"=>{"addr:city"=>"Lupoč", "addr:conscriptionnumber"=>"102", "addr:country"=>"SK", "addr:housenumber"=>"102", "addr:place"=>"Lupoč", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>63635166, "timestamp"=>"2016-11-01T06:52:44Z", "version"=>2, "changeset"=>43319484, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2852463, "lon"=>19.7168346}, "nodes"=>[787330173, 787328583, 787326977, 787329515, 787328246, 787326700, 787329292, 787327683, 787329791, 787330173], "tags"=>{"addr:city"=>"Trebeľovce", "addr:conscriptionnumber"=>"109", "addr:country"=>"SK", "addr:housenumber"=>"109", "addr:place"=>"Trebeľovce", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>61275557, "timestamp"=>"2016-10-29T16:45:09Z", "version"=>2, "changeset"=>43269030, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.212782, "lon"=>19.8144789}, "nodes"=>[765607290, 765606057, 765608039, 765606456, 765608548, 765607178, 765607290], "tags"=>{"addr:city"=>"Čakanovce", "addr:conscriptionnumber"=>"312", "addr:country"=>"SK", "addr:housenumber"=>"312", "addr:place"=>"Čakanovce", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59624748, "timestamp"=>"2016-11-01T06:15:27Z", "version"=>2, "changeset"=>43319086, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.429027, "lon"=>19.5528489}, "nodes"=>[739632574, 739632159, 739637399, 739634441, 739638966, 739632104, 739633284, 739639244, 739632574], "tags"=>{"addr:city"=>"Ružiná", "addr:conscriptionnumber"=>"102", "addr:country"=>"SK", "addr:housenumber"=>"102", "addr:place"=>"Ružiná", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65185164, "timestamp"=>"2016-11-01T09:36:57Z", "version"=>2, "changeset"=>43321882, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3468257, "lon"=>19.8373451}, "nodes"=>[797419582, 797422252, 797423129, 797421202, 797421944, 797419971, 797423463, 797421704, 797418616, 797422675, 797420377, 797417792, 797423654, 797421539, 797417851, 797421994, 797422655, 797421627, 797418541, 797422658, 797420333, 797417781, 797423114, 797421265, 797418288, 797422430, 797421926, 797418940, 797422957, 797420844, 797418068, 797419649, 797422235, 797419582], "tags"=>{"addr:city"=>"Veľké Dravce", "addr:conscriptionnumber"=>"240", "addr:country"=>"SK", "addr:housenumber"=>"240", "addr:place"=>"Veľké Dravce", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>63702771, "timestamp"=>"2016-11-01T06:08:45Z", "version"=>2, "changeset"=>43319043, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2451521, "lon"=>19.784822}, "nodes"=>[787868831, 787868407, 787871102, 787869914, 787868831], "tags"=>{"addr:city"=>"Ratka", "addr:conscriptionnumber"=>"109", "addr:country"=>"SK", "addr:housenumber"=>"109", "addr:place"=>"Ratka", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>288285213, "timestamp"=>"2016-10-31T17:47:30Z", "version"=>2, "changeset"=>43309884, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3630223, "lon"=>19.5078523}, "nodes"=>[2918449326, 2918449291, 2918449297, 2918449270, 2918449257, 2918449275, 2918449280, 2918449317, 2918449326], "tags"=>{"addr:city"=>"Praha", "addr:conscriptionnumber"=>"37", "addr:country"=>"SK", "addr:housenumber"=>"37", "addr:place"=>"Praha", "building"=>"yes", "source"=>"Bing", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65181184, "timestamp"=>"2016-10-31T17:50:56Z", "version"=>2, "changeset"=>43309948, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2999643, "lon"=>19.7917163}, "nodes"=>[797380692, 797379521, 797380980, 797379783, 797379124, 797380692], "tags"=>{"addr:city"=>"Prša", "addr:conscriptionnumber"=>"79", "addr:country"=>"SK", "addr:housenumber"=>"79", "addr:place"=>"Prša", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>154919674, "timestamp"=>"2016-11-01T07:05:59Z", "version"=>2, "changeset"=>43319672, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2613974, "lon"=>19.6174596}, "nodes"=>[1673745923, 1673745957, 1673745983, 1673745949, 1673745945, 1673745917, 1673745923], "tags"=>{"addr:city"=>"Veľká nad Ipľom", "addr:conscriptionnumber"=>"68", "addr:country"=>"SK", "addr:housenumber"=>"68", "addr:place"=>"Veľká nad Ipľom", "building"=>"yes", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59713787, "timestamp"=>"2016-10-29T06:47:14Z", "version"=>4, "changeset"=>43260366, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.4107497, "lon"=>19.4324535}, "nodes"=>[741088148, 741088348, 741088247, 741088568, 741088360, 741088216, 741088806, 741088677, 741088441, 741088255, 741088130, 741088279, 741088155, 741088625, 741088148], "tags"=>{"addr:city"=>"Ábelová", "addr:conscriptionnumber"=>"95", "addr:country"=>"SK", "addr:housenumber"=>"95", "addr:place"=>"Ábelová", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65157684, "timestamp"=>"2016-10-29T06:53:39Z", "version"=>2, "changeset"=>43260435, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2424493, "lon"=>19.8473818}, "nodes"=>[797213782, 797213739, 797213206, 797213250, 797214080, 797213546, 797214382, 797213867, 797213341, 797214174, 797213647, 797213385, 797214213, 797213683, 797213159, 797213986, 797213462, 797214302, 797213782], "tags"=>{"addr:city"=>"Belina", "addr:conscriptionnumber"=>"194", "addr:country"=>"SK", "addr:housenumber"=>"194", "addr:place"=>"Belina", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59561739, "timestamp"=>"2016-10-30T14:51:03Z", "version"=>2, "changeset"=>43285017, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3331286, "lon"=>19.5642073}, "nodes"=>[738837889, 738837531, 738837179, 738838372, 738837739, 738837378, 738838562, 738838222, 738838185, 738837849, 738837487, 738837147, 738838037, 738837689, 738837327, 738838527, 738838480, 738837889], "tags"=>{"addr:city"=>"Mašková", "addr:conscriptionnumber"=>"76", "addr:country"=>"SK", "addr:housenumber"=>"76", "addr:place"=>"Mašková", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59740981, "timestamp"=>"2016-10-30T14:22:53Z", "version"=>2, "changeset"=>43284542, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3730734, "lon"=>19.4509342}, "nodes"=>[741517404, 741517400, 741517403, 741517406, 741517402, 741517404], "tags"=>{"addr:city"=>"Lentvora", "addr:conscriptionnumber"=>"61", "addr:country"=>"SK", "addr:housenumber"=>"61", "addr:place"=>"Lentvora", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>278069997, "timestamp"=>"2016-10-30T14:05:12Z", "version"=>2, "changeset"=>43284243, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2926399, "lon"=>19.7764927}, "nodes"=>[2824992409, 2824992415, 2824992414, 2824992528, 2824992555, 2824992522, 2824992518, 2824992456, 2824992457, 2824992431, 2824992409], "tags"=>{"addr:city"=>"Fiľakovské Kováče", "addr:conscriptionnumber"=>"275", "addr:country"=>"SK", "addr:housenumber"=>"275", "addr:place"=>"Fiľakovské Kováče", "building"=>"yes", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65388422, "timestamp"=>"2016-10-29T16:47:19Z", "version"=>2, "changeset"=>43269080, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2490968, "lon"=>19.8877037}, "nodes"=>[798674612, 798674911, 798674553, 798674847, 798673912, 798674221, 798674408, 798674715, 798675164, 798674083, 798674809, 798674612], "tags"=>{"addr:city"=>"Čamovce", "addr:conscriptionnumber"=>"69", "addr:country"=>"SK", "addr:housenumber"=>"69", "addr:place"=>"Čamovce", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59614606, "timestamp"=>"2016-10-31T17:40:57Z", "version"=>2, "changeset"=>43309725, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.4059944, "lon"=>19.5983795}, "nodes"=>[739483446, 739482277, 739481624, 739483821, 739483060, 739481968, 739481408, 739483534, 739482682, 739481679, 739484074, 739483177, 739481323, 739483920, 739483229, 739483962, 739483328, 739482171, 739481563, 739483729, 739482915, 739481853, 739483446], "tags"=>{"addr:city"=>"Podrečany", "addr:conscriptionnumber"=>"190", "addr:country"=>"SK", "addr:housenumber"=>"190", "addr:place"=>"Podrečany", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>260352975, "timestamp"=>"2016-11-01T06:58:15Z", "version"=>2, "changeset"=>43319564, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.4284055, "lon"=>19.5032287}, "nodes"=>[2658208603, 2658208655, 2658208647, 2658208600, 2658208599, 2658208587, 2658208582, 2658208547, 2658208554, 2658208516, 2658208518, 2658208434, 2658208453, 2658208535, 2658208568, 2658208622, 2658208603], "tags"=>{"addr:city"=>"Tuhár", "addr:conscriptionnumber"=>"56", "addr:country"=>"SK", "addr:housenumber"=>"56", "addr:place"=>"Tuhár", "building"=>"yes", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>59637276, "timestamp"=>"2016-10-29T16:36:54Z", "version"=>3, "changeset"=>43268880, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.4565591, "lon"=>19.4782647}, "nodes"=>[739803708, 739802251, 739800819, 739806776, 739801154, 739808376, 739806949, 739802240, 739800471, 739805460, 739803708], "tags"=>{"addr:city"=>"Budiná", "addr:conscriptionnumber"=>"96", "addr:country"=>"SK", "addr:housenumber"=>"96", "addr:place"=>"Budiná", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>63700235, "timestamp"=>"2016-10-31T17:36:04Z", "version"=>2, "changeset"=>43309587, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2326932, "lon"=>19.7507981}, "nodes"=>[787856847, 787855755, 787854435, 787856104, 787854662, 787856422, 787854942, 787855402, 787856761, 787855653, 787854357, 787855988, 787856847], "tags"=>{"addr:city"=>"Pleš", "addr:conscriptionnumber"=>"7", "addr:country"=>"SK", "addr:housenumber"=>"7", "addr:place"=>"Pleš", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>61045346, "timestamp"=>"2016-10-29T16:38:06Z", "version"=>2, "changeset"=>43268900, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2934247, "lon"=>19.8480199}, "nodes"=>[764092441, 764092788, 764092002, 764093003, 764092133, 764092366, 764093547, 764092567, 764091886, 764092084, 764093122, 764092197, 764093303, 764091838, 764092441], "tags"=>{"addr:city"=>"Bulhary", "addr:conscriptionnumber"=>"96", "addr:country"=>"SK", "addr:housenumber"=>"96", "addr:place"=>"Bulhary", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65197559, "timestamp"=>"2016-11-01T06:29:44Z", "version"=>2, "changeset"=>43319205, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2764479, "lon"=>19.8780656}, "nodes"=>[797455935, 797454602, 797453280, 797455394, 797454405, 797453024, 797455188, 797453832, 797455608, 797454285, 797456371, 797455051, 797455935], "tags"=>{"addr:city"=>"Šíd", "addr:conscriptionnumber"=>"37", "addr:country"=>"SK", "addr:housenumber"=>"37", "addr:place"=>"Šíd", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65188430, "timestamp"=>"2016-11-01T06:22:12Z", "version"=>2, "changeset"=>43319138, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3024658, "lon"=>19.8215552}, "nodes"=>[797442803, 797443610, 797444508, 797445251, 797443118, 797444048, 797444866, 797442803], "tags"=>{"addr:city"=>"Šávoľ", "addr:conscriptionnumber"=>"220", "addr:country"=>"SK", "addr:housenumber"=>"220", "addr:place"=>"Šávoľ", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>65158821, "timestamp"=>"2016-10-31T18:03:04Z", "version"=>2, "changeset"=>43310201, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.2200582, "lon"=>19.8276907}, "nodes"=>[797223482, 797218250, 797222506, 797220603, 797223011, 797218701, 797223482], "tags"=>{"addr:city"=>"Radzovce", "addr:conscriptionnumber"=>"507", "addr:country"=>"SK", "addr:housenumber"=>"507", "addr:place"=>"Radzovce", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>60921364, "timestamp"=>"2016-11-01T06:26:06Z", "version"=>2, "changeset"=>43319171, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.1921445, "lon"=>19.8168111}, "nodes"=>[762653319, 762654339, 762653597, 762653854, 762653742, 762653429, 762653300, 762653973, 762654274, 762653319], "tags"=>{"addr:city"=>"Šiatorská Bukovinka", "addr:conscriptionnumber"=>"41", "addr:country"=>"SK", "addr:housenumber"=>"41", "addr:place"=>"Šiatorská Bukovinka", "building"=>"yes", "import"=>"budovy201004", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}, {"type"=>"way", "id"=>286612661, "timestamp"=>"2016-10-31T17:32:50Z", "version"=>2, "changeset"=>43309520, "user"=>"kaporskaddress_bot", "uid"=>3081077, "center"=>{"lat"=>48.3588635, "lon"=>19.7588741}, "nodes"=>[2902906384, 2902906380, 2902906365, 2902906364, 2902906362, 2902906375, 2902906384], "tags"=>{"addr:city"=>"Pinciná", "addr:conscriptionnumber"=>"12", "addr:country"=>"SK", "addr:housenumber"=>"12", "addr:place"=>"Pinciná", "building"=>"yes", "source"=>"kapor2", "source:conscriptionnumber"=>"kapor2"}}]}
    return json
  end
end 
