module ImportIdentificationsHelper
  def importIdentifications(csv)
    line_count = 0
    ident_count = 0
    header = nil
    identifications = []
    no_lipid = 0
    no_feature = 0
    File.open(csv, 'r') do |file|
      file.each_line do |line|

        row = line.chomp.split ';'
        row = row.map {|cell| if cell =~/^"([^"]*)"$/
                                $1
                              else
                                cell
                              end }
        if header.nil?
          next if row[0] == ""
          i = -1
          header = row.map {|v| i += 1 ;[v.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_'),i] }
          header = Hash[*header.flatten]
          next
        end
        line_count += 1
        ident = Identification.new
        ident.feature = Feature.where(id_string: row[header['compound']]).take
        if ident.feature.nil? #ignore if feature is not found
          no_feature += 1
          next
        end
        if row[header['link']] =~ /sid=(.+)$/
          ident.lipid = Lipid.where(pubchem_sid: $1.to_i).take
          if ident.lipid.nil?
            no_lipid += 1
            next
          end
          puts 'Found oxidated lipid!!!' if ident.lipid.oxidations>0
        elsif row[header['link']] =~ /LMID=(.+)$/
          ident.lipid = Lipid.where(lm_id: $1).take
          if ident.lipid.nil?
            no_lipid += 1
            next
          end
        else
          ident.lipid = Lipid.where(common_name: row[header['description']]).take
          if ident.lipid.nil?
            puts 'Could not identify lipid %s with link %s'%[row[header['description']],row[header['link']]]
            no_lipid += 1
            next
          end
        end

        ident.score = row[header['score']].to_f
        ident.fragmentation_score = row[header['fragmentation_score']].to_f
        ident.mass_error =  row[header['mass_error']].to_f
        ident.isotope_similarity = row[header['isotope_similarity']].to_f
        ident.adducts = row[header['adducts']].split(/,/).length
        identifications << ident
        ident_count += 1
        if ident_count%1000==0
          puts " ... imported identification ##{ident_count}"
          Identification.import identifications
          identifications = []
        end
      end
    end
    Identification.import identifications
    "#{ident_count} identifications imported, ignored: #{line_count-ident_count}. Reasons for ignoring: no lipid found: #{no_lipid}, no feature found: #{no_feature}"
  end
end
