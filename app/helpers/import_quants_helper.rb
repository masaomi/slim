module ImportQuantsHelper
  def importQuants(csv)
    require 'csv'
    #compound_all = Compound.select("compound").all.uniq
    count = 0
    total = 0
    quants = []
    CSV.foreach(csv, :headers=>true, :col_sep=>";") do |row|
      total += 1
      record = {}
      row.each do |key, value|
        # puts [key, value].join(" ")
        new_key = key.downcase.gsub(/\(.+\)/,'').strip.gsub(/\s/,'_')
        record[new_key] ||= []
        record[new_key] << value
      end
      if compound = record['compound']
        count += 1
        if count%1000 == 0
          Quant.import quants
          puts "    .... imported quantification ##{count}"
          quants = []
        end
        quant = Quant.new
        quant.compound = compound
        samples = {}
        record.each do |key, values|
          if key =~ /mp_\d+/
            samples[key] = values
          end
        end
        quant.samples = samples.to_s
        quants << quant
      end
    end
    Quant.import quants
    puts 'Now assigning compounds to quants'
    Quant.find_each do |quant|
      Compound.where(compound: quant.compound).map {|comp| quant.compounds << comp}
    end
    return "    #{count} compounds imported / total #{total} loaded "
  end
end
