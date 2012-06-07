#!/usr/bin/env ruby
# Modification for SAM file format
# 
#IL28_4748:6:1:1277:5450#6	0	chromosome:NCBIM37:11:1:121843856:1	30097625	37	48M	*	0	0	CTAGGGTCGTGTACCGTATGGCAGAAATAAAGCTTCAAAAAGCTCAAA	9?BCC=ACC@9ACCACCCC?A@B<ACABABBBBCCCAABBBBB.C(@9	XT:A:U	NM:i:2	X0:i:1	X1:i:0	XM:i:2	XO:i:0	XG:i:0	MD:Z:45C1G0
require 'zlib'
files = Dir.glob("../icr/Sample_TR?_5/R1.sam")
# Set coverage cutoff here:
mincov = ARGV[0].to_i

hh =[]

files.each do |a|
	hash = {}
	f = File.open(a,"r")
	while (line = f.gets)
		line.chomp!
		(id, flag, stupidchr, pos, mapq, cigar, rn, pn,tlen, seq, qual, junk) = line.split(" ")
#		(cig, id, qst, qen, qstr, stupidchr, sst, sen, sstr, len, map) = line.split(" ")
		pos = pos.to_i
		flag = flag.to_i
		mapq = mapq.to_i
		# Check for quality
		if (mapq > 30)
	
		# If we're on the + strand and mapping starts at bases 1-3
		if ((flag == 0) && (stupidchr =~ /NCBIM37:(\d+|[XY])/))
			# Convert chromosome to something sensible
			chr = $1
			qstr = "+"
			# Get the chromosomal position of the tTAA
			# It's already pos in this case
			# Make a hash key and increment  key is chromosome[strand][position] eg. 5+123456, X-89101112
			hkey = chr + qstr.to_s + pos.to_s
			if hash[hkey] == nil
				hash[hkey] = 1
			else
				hash[hkey] += 1
			end
		#Now minus strand
		elsif ((flag == 16) && (stupidchr =~ /NCBIM37:(\d+|[XY])/))
			# Convert chromosome to something sensible
			chr = $1
			qstr = "-"
			# Get the chromosomal position of the tTAA
			#cigar.match("(\d+)M")
			#adj = $1
			pos = pos + seq.length - 3 - 1
			# Make a hash key and increment
			hkey = chr + qstr.to_s + pos.to_s
			if hash[hkey] == nil
				hash[hkey] = 1
			else
				hash[hkey] += 1
			end

		end
		end

	end

o = File.open(a.sub(/.sam/,".hashup"),"w")

#total = 0	
#selected = hash.select {|k,v| v > mincov}
#new = {}
#selected.each {|a| new[a[0]] = a[1]} 
#hash = new
hash.each { |k, v| o.puts "#{k} #{v}" }
o.close


end
