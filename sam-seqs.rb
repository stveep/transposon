#!/usr/bin/env ruby
# Script to get 1st 4 bp of sequence from SAM mappings.
require 'rubygems'
require 'bio'

hash = {}
hash.default = ()

inf = File.open(ARGV[0],'r')

while (l = inf.gets)
#IL28_4748:6:120:19771:8510#0	16	chromosome:NCBIM37:14:1:125194864:1	62170813	0	9M	*	0	0	TAACACTAA	(7B??B?=2	XT:A:R	NM:i:0	X0:i:26186	XM:i:0	XO:i:0	XG:i:0	MD:Z:
	# Force high quality - commented as this is now done with samtools view -q 30
	fields = l.split("\t")
#	unless (fields[4].to_i > 30)
#		next
#	end

	flag = fields[1]
	seq = fields[9]
	stupidchr = fields[2]
	cigar = fields[5]
	pos = fields[3].to_i
	# For + strand match
	if ((flag !~ /r/) && (stupidchr =~ /NCBIM37:(\d+|[XY])/))                        # Convert chromosome to something sensible
		chr = $1
		qstr = "-"
		# Get the chromosomal position of the tTAA
		# It's already pos in this case
		# Make a hash key and increment  key is chromosome[strand][position] eg. 5+123456, X-89101112
		hkey = chr + qstr.to_s + pos.to_s
		site = seq[0,4]
	elsif ((flag =~ /r/) && (stupidchr =~ /NCBIM37:(\d+|[XY])/))
		qstr="+"
		# Convert chromosome to something sensible
		chr = $1
		# Get the chromosomal position of the tTAA
		adj = cigar.scan(/(\d+)M/)[0][0]
		pos = pos + adj.to_i - 3 - 1
		# Make a hash key and increment
		hkey = chr + qstr.to_s + pos.to_s
		siteob = Bio::Sequence::NA.new(seq[seq.length-4,seq.length])
		site = siteob.complement.upcase	
	end
	if hash[site].nil? then hash[site] = [hkey] else hash[site].push(hkey) end

end
hash.each{|k, v| print "#{k}\t#{v.length}\t#{v.uniq.length}\t#{v.uniq.join(",")}\n"}
