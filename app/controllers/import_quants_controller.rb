class ImportQuantsController < ApplicationController
  def import
    session['quant_count'] = nil
    if file = params[:file] and csv = file[:name]

      compound_name2compound = {}
      Compound.find_each do |compound|
        compound_name2compound[compound.compound] ||= []
        compound_name2compound[compound.compound] << compound
      end

      #compound_all = Compound.select("compound").all.uniq
      count = 0
      total = 0
      quants = []
      CSV.foreach(csv.path, :headers=>true, :col_sep=>";") do |row|
        total += 1
        record = {}
        row.each do |key, value|
          # puts [key, value].join(" ")
          new_key = key.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_')
          record[new_key] ||= []
          record[new_key] << value
        end
        #if compound = record['compound'] and compound = compound.first and Compound.find_by_compound(compound)
        if compound = record['compound'] and compound = compound.first and compound_name2compound[compound]
          count += 1
        #if compound = record['compound'] and compound = compound.first and compound_all.include?(compound)
          quant = Quant.new
          #quant.compound = record['compound'].first
          quant.compound = compound
          samples = {}
          record.each do |key, values|
            if key =~ /mp_\d+/
              samples[key] = values
            end
          end
          quant.samples = samples.to_s
          #quant.save
          quants << quant
        end
      end
      Quant.import quants

      Quant.find_each do |quant|
        compound_name2compound[quant.compound].to_a.each do |compound|
#          compound.quant = quant
#          compound.quant.compounds << compound
          quant.compounds << compound
        end
      end

      #render :text => compound_all[0,5].join(", ")
      #render :text => "#{count} compounds imported / total #{total} loaded "
      @comment = "#{count} compounds imported / total #{total} loaded "
    else
      render :text => 'file upload failed'
    end
  end
end
