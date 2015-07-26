module ImportQuantificationsHelper
  def importQuantifications(csv)
    #compound_all = Compound.select("compound").all.uniq
    n = 0
    first_row = true
    before_samples = 'Minimum CV%'
    starting_sample = nil
    n_samples = 0
    samples = nil
    quants = []
    File.open(csv, 'r').each_line do |line|
      row = line.chomp.split ';'
      if first_row
        row.each_with_index do |cell, i|
          next if samples.nil? and cell != before_samples
          if samples.nil? and cell==before_samples
            samples = {}
            next
          end
          if samples[cell]
            break
          end
          n_samples += 1
          starting_sample ||= i
          sample = Sample.new
          sample.id_string = cell
          if sample.id_string =~ /_([A-Za-z0-9]+_[A-Za-z0-9]+)$/
            sample.short = $1
          else
            sample.short = sample.id_string
          end
          samples[cell] = sample
        end
        samples = samples.values
        Sample.import samples
        raise 'no samples detected' unless n_samples > 0
        raise 'did not detect starting sample column' if starting_sample.nil? or starting_sample<5
        print "    .... interpreted header, detected #{n_samples} samples starting at row #{starting_sample}, continuing ...\n"
        first_row = false
        next
      end
      feature = Feature.new
      feature.id_string = row[0]
      feature.m_z = row[3].to_f if row[3] != ""
      feature.mass = row[1].to_f if row[1] != ""
      feature.charge = row[2].to_i if row[2] != ""
      feature.rt = row[4].to_f if row[4] != ""
      feature.save


      for i in 0..n_samples
        q = Quantification.new
        q.raw = row[starting_sample+i].to_f
        q.norm = row[starting_sample+i+n_samples].to_f
        q.feature = feature
        q.sample = samples[i]
        quants << q
      end

      n += 1
      if n%500==0
        puts "    ....  imported quantification #{n}, continuing...\n"
        Quantification.import quants
        quants = []
      end
    end
    Quantification.import quants
    puts "    imported #{n} features in #{n_samples} samples."
  end
end
