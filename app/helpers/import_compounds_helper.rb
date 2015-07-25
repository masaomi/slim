module ImportCompoundsHelper
  def importIdentifications(csv)
    count = 0
    count_lipid = 0
    unlinked_compounds = 0
    compounds = []
    header = nil
    CSV.foreach(csv, :headers=>false, :col_sep=>";") do |row|
      if header.nil?
        i = -1
        header = row.map {|v| i += 1 ;[v.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_'),i] }
        header = Hash[*header.flatten]
        next
      end
      compound = Compound.new
      compound.compound = row[header['compound']]
      compound.compound_id = row[header['compound_id']]
      compound.adducts = row[header['adducts']]
      compound.adducts_size = compound.adducts.split(/,/).length
      compound.score = row[header['score']].to_f
      compound.fragmentation_score = row[header['fragmentation_score']].to_f
      compound.mass_error = row[header['mass_error']].to_f
      compound.isotope_similarity = row[header['isotope_similarity']].to_f
      compound.link = row[header['link']]
      compound.description = row[header['description']]
      compound.sid = if row[header['link']] =~ /sid=(.+)$/
                       $1
                     else
                       row[header['link']]
                     end
      lipid = Lipid.where(pubchem_sid: compound.sid).take
      if not lipid.nil?
        compound.save
        lipid.compounds << compound
      else
        compound.delete
        unlinked_compounds += 1
      end
      count += 1
      if count%1000==0
        puts " ... imported Identification ##{count}"
      end
    end
    "#{count} compounds imported, thereof compounds with sid unlinked to a lipid  deleted: #{unlinked_compounds}"
  end
end
