class ImportCompoundsController < ApplicationController
  def import
    session['compound_count'] = nil
    if file = params[:file] and csv = file[:name]
      count = 0
      count_lipid = 0
      compounds = []
      CSV.foreach(csv.path, :headers=>true, :col_sep=>";") do |row|
        record = {}
        row.each do |key, value|
          record[key.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_')] = value
        end

        sid = if record['link'] =~ /sid=(\d+)/
                $1
              end
        sid = sid.to_s
        count += 1
        #if Lipid.find_by_pubchem_sid(sid)
        #  count_lipid += 1
        #end
        compound = Compound.new
        compound.compound = record['compound']
        compound.compound_id = record['compound_id']
        compound.adducts = record['adducts']
        compound.adducts_size = record['adducts'].split(/,/).length
        compound.score = record['score'].to_f
        compound.fragmentation_score = record['fragmentation_score'].to_f
        compound.mass_error = record['mass_error'].to_f
        compound.isotope_similarity = record['isotope_similarity'].to_f
        compound.retention_time = record['retention_time'].to_f
        compound.sid = sid
        compound.link = record['link']
        compound.description = record['description']
        #compound.save
        compounds << compound
      end
      Compound.import compounds

      sid2lipid = {}
      Lipid.find_each do |lipid|
        sid2lipid[lipid.pubchem_sid] ||= []
        sid2lipid[lipid.pubchem_sid] << lipid
      end
      unlinked_compounds = 0
      Compound.find_each do |compound|
        if lipids = sid2lipid[compound.sid] and lipid = lipids.first
          count_lipid += 1
          lipid.compounds << compound
        else
          compound.delete
          unlinked_compounds += 1
        end
      end

      #render :text => "#{count} compounds imported, #{count_lipid} lipids corresponding compounds are found"
      #render :text => "#{count} compounds imported"
      #render :text => "#{count} compounds imported, compounds with sid linked to lipids: #{count_lipid}"
      @comment = "#{count} compounds imported, compounds with sid linked to lipids: #{count_lipid}, unlinked compounds deleted: #{unlinked_compounds}"
    else
      render :text => 'file upload failed'
    end
  end
end
