import argparse, gzip, re, subprocess
# create default dict to get numeric value for chrom
from collections import defaultdict

# define the function to clean the pileup of indels etc.
def clean_plp(plp):
    # first remove any ^ sign and character following it
    plp = re.sub(r'\^.',"", plp)
    # next remove all $ signs
    plp = plp.replace("$","")
    # check if there are numbers
    numbers = re.findall('\d+',plp)
    # only if numbers is not empty (empty list is false)
    if numbers:
        numbers = [int(n) for n in numbers]
        vec = re.split('\d+',plp)
        newplp = []
        # process first entry of vec
        element = vec[0]
        element = element.replace("+","")
        element = element.replace("-","")
        newplp.append(element)
        # now loop through the rest of the vector
        for i, element in enumerate(vec[1:]):
            # i will go from 0 on
            # remove the number of bases inserted/deleted
            element = element[numbers[i]:]
            # remove the + or -
            element = element.replace("+","")
            element = element.replace("-","")
            # add it to cleaned up pileup newplp
            newplp.append(element)
        # join them together and replace plp
        plp = "".join(newplp)
    # return cleaned up pileup
    return plp

# read in the arguments
parser = argparse.ArgumentParser(description='Process 1 or more bam files to get allele specific read counts.')

parser.add_argument("-d", "--maxdepth", help='max per-file depth', type=int, default=2500)
parser.add_argument("-n", "--autosomes", help='number of autosomes. Default is 22 (human)', type=int, default=22)
parser.add_argument("-P", "--pseudo-snps", help='tile loci every PSEUDO_SNP position. Default = 2^29 i.e. no pseudo-snps', type=int, default=2**29)
parser.add_argument("-q", "--min-MQ", help='mapping quality threshold. Default=15', type=int, default=15)
parser.add_argument("-Q", "--min-BQ", help='base quality threshold. Default=20', type=int, default=20)
parser.add_argument("-r", "--min-RC", help='min read counts in the normal for a snp to be output. Default=10', type=int, default=10)
parser.add_argument("vcffile", help='snp vcf file; for instance snp-dedup applied to common_all_20180423.vcf.gz')
parser.add_argument("outfile", help='file into which output is written')
parser.add_argument("bamfiles", help='bam file(s) for which read counts are computed', nargs="+")

# get the passed on arguments
args = parser.parse_args()

# number of samples
nsamples = len(args.bamfiles)

# define the dictionary with a default value of 1000
ichrom = defaultdict(lambda: 1000)
# define numeric values for autosomes and X chromosome
chr = 0
while chr < args.autosomes:
    chr += 1
    ichrom[str(chr)] = chr
    ichrom["".join(["chr",str(chr)])] = chr
# numeric value for chromsome X
ichromX = args.autosomes + 1
# add X
ichrom['X'] = ichromX
ichrom['chrX'] = ichromX
# numeric value for chromsome Y
ichromY = args.autosomes + 2
# add Y
ichrom['Y'] = ichromY
ichrom['chrY'] = ichromY


# build the pileup command; count orphan reads (-A) and disable BAQ (-B)
pileupcmd = ['samtools mpileup -A -B']

# add max per-file depth (-d), mapping (-q) and base (-Q) quality
# the integers that are passed must be converted to string first
pileupcmd.append("".join(['-d', str(nsamples*args.maxdepth)]))
pileupcmd.append("".join(['-q', str(args.min_MQ)]))
pileupcmd.append("".join(['-Q', str(args.min_BQ)]))

# setup a small region to test code
#pileupcmd.append("-r 1:1-1000000")

# add the bamfiles (add quotes if name has white space)
for bamfile in args.bamfiles:
    if ' ' in bamfile:
        bamfile = "'" + bamfile + "'"
    pileupcmd.append(bamfile)

#create read count command after querycmd to pileupcmd
bamquery = " ".join(pileupcmd)

# setup the pileup pipe
bampipe = subprocess.Popen(bamquery,
                           stdout=subprocess.PIPE,
                           shell=True)

# open the snp vcf file for reading
snpvcf = gzip.open(args.vcffile, "rt")
# read the first line
currentsnp = snpvcf.readline().rstrip("\r\n")
snp0 = currentsnp.split()
snpchr = ichrom[snp0[0]]
snppos = int(snp0[1])

# setup the output stream
rcfile = gzip.open(args.outfile, "wt")

# generate column header (at least one bam)
rcout = 'Chromosome,Position,Ref,Alt'

# append 'File*R,File*A,File*E,File*D' for each sample
isamp = 0
basescol = []
while isamp < nsamples:
    isamp += 1
    basescol.append(1+3*isamp)
    rcout = rcout + ',' + ",".join(["".join(["File",str(isamp)]) + s for s in ['R','A','E','D']])

# add newline and write to output file
rcout = rcout + '\n'
rcfile.writelines(rcout)

# start streaming the pileup data
# each line has chrom, pos, ref-base (N if no reference fasta)
# followed by num of reads, read bases and base quality per sample
chrsame = False
chrdiff = True
for currentloc in bampipe.stdout:
    locdata = currentloc.decode().rstrip('\r\n').split('\t')
    # bam locus chromosome
    bamchr = ichrom[locdata[0]]
    # if current chromosome is not an autosome or X stop
    if bamchr > ichromX:
        break
    # bam locus position
    bampos = int(locdata[1])
    # depth of normal 
    nbamrc = int(locdata[3])
    # if depth meets the threshold
    if nbamrc >= args.min_RC:
        # chromosomes are ordered by number and position
        # if current bam position gone past snp position move snp to catch up
        while snpchr < bamchr or (snpchr == bamchr and snppos < bampos):
            currentsnp = snpvcf.readline().rstrip("\r\n")
            snp0 = currentsnp.split()
            #print('vcf before bam', currentsnp, snp0)
            if len(snp0) == 4:
                snpchr = ichrom[snp0[0]]
                snppos = int(snp0[1]) # change pos from string to integer
            else:
                vcfeof = True # set vcf end-of-file flag
                break
        # initialize read counts
        rcounts = [0]*4*nsamples
        # now check if current location is a snp
        if bamchr == snpchr and bampos == snppos:
            # counts by sample
            isamp = 0
            irc = 0
            while isamp < nsamples:
                ibases = locdata[basescol[isamp]].upper()
                ibases = clean_plp(ibases)
                rcounts[irc] = ibases.count(snp0[2]) # ref allele count
                irc += 1
                rcounts[irc] = ibases.count(snp0[3]) # alt allele count
                # if depth is more than ref and alt put the rest in E column
                irc += 1
                rcounts[irc] = int(locdata[3*isamp+3]) - rcounts[irc-1] - rcounts[irc-2]
                irc += 2
                # increment sample number
                isamp += 1
            # string the counts together and join with snp info
            rcout = currentsnp.replace('\t',',') + ',' + ','.join(map(str, rcounts)) + '\n'
            # write rcout to output file
            rcfile.writelines(rcout)

        # add depth for pseudo-snps
        if (bampos < snppos or bamchr < snpchr) and bampos % args.pseudo_snps == 0:
            # take the chromosome name and position from locdata join with , and add N,N
            pseudosnp = ",".join(locdata[:2]) + ',N,N,'
            isamp = 0
            while isamp < nsamples:
                rcounts[isamp*4] = int(locdata[3*isamp+3])
                isamp += 1
            # concatenate the counts to pseudo-snp
            rcout = pseudosnp + ','.join(map(str, rcounts)) + '\n'
            # write rcout to output file
            rcfile.writelines(rcout)

rcfile.close()
snpvcf.close()
