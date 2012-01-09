#!/usr/bin/env ruby
# seen hash of hashes contains all mate mappings (field 7) for a given fwd mapping (field 3).
seen = Hash.new

inf = File.open(ARGV[0],'r')
o = File.open(ARGV[0].sub("sam","rmdup"),'w')

while (l = inf.gets)
	fields = l.split("\t")
	next if fields[3] == "0" || fields[7] == "0"
	# Only properly paired reads considered:
	if fields[1].to_i & 64 == 64

	# This code is imported from smalt-seqs to generate hash keys.
		flag = fields[1].to_i
		seq = fields[9]
		stupidchr = fields[2]
		cigar = fields[5]
		pos = fields[3].to_i
		# For + strand match, read 1, paired, no clipping at start of read
		if (flag & 16 == 0 && flag & 2 == 2)  
	# Convert chromosome to something sensible
			chr = stupidchr
			qstr = "+"
			# Get the chromosomal position of the tTAA
			# Need to accountt for soft clipping
			adj = 0
			if (cigar.match(/^(\d+)S/))
				adj = $1.to_i
				next if adj > 4
			end
			pos = pos - adj
			# Make a hash key and increment  key is chromosome[strand][position] eg. 5+123456, X-89101112
			hkey = chr + qstr.to_s + pos.to_s
	#Sim. for - strand, no clipping at end of read
		elsif (flag & 16 == 16 && flag & 2 == 2)
			qstr="-"
			# Convert chromosome to something sensible
			chr = stupidchr
	# need to fix this for neg. arand - how to get position if clipping is present?
			beg = 0
			if (cigar.match(/^(\d+)S/))
				beg = $1.to_i
				if (cigar.match(/(\d+)S$/))
				adj = $1.to_i
				next if adj > 4
				end
			end
			# Get the chromosomal position of the tTAA
			pos = pos - beg + seq.length - 3 - 1
			# Make a hash key and increment
			hkey = chr + qstr.to_s + pos.to_s
		end

		#Creates the hash for this fwd mapping if it doesn't already exist
		seen[hkey] = Hash.new unless seen.has_key?(hkey)
		o.puts l unless seen[hkey].has_key?(fields[7])
		seen[hkey][fields[7]] = 1
	end

end
