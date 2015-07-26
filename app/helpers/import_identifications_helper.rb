module ImportIdentificationsHelper
  def importIdentifications(csv)
    line_count = 0
    ident_count = 0
    header = nil
    identifications = []
    no_lipid = 0
    no_feature = 0
    File.open(csv, 'r').each_line do |line|
      row = line.chomp.split ';'
      if header.nil?
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
      end
      if row[header['link']] =~ /sid=(.+)$/
        ident.lipid = Lipid.where(pubchem_sid: $1.to_i).take
        if ident.lipid.nil?
          no_lipid += 1
          next
        end
      else
        next #ignore if lipid is not found
      end
      identifications << ident
      ident_count += 1
      if ident_count%1000==0
        puts " ... imported identification ##{ident_count}"
        Identification.import identifications
        identifications = []
      end
    end
    Identification.import identifications
    "#{ident_count} identifications imported, ignored: #{line_count-ident_count}. Reasons for ignoring: no lipid found: #{no_lipid}, no feature found: #{no_feature}"
  end
end
