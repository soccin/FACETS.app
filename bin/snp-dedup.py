import argparse, gzip, subprocess

# read in the 
parser = argparse.ArgumentParser(description='Process SNP VCF file into suitable format.')

parser.add_argument("snpfile", help='input vcf file for instance common_all_20180423.vcf.gz')
parser.add_argument("outfile", help='file into which output is written')

args = parser.parse_args()

# build command string
bcfcmd = ["bcftools", "query", "-f'%CHROM\t%POS\t%REF\t%ALT\n'"]
# if snpfile has whitespace in it wrap it in quotes
if ' ' in args.snpfile:
    args.snpfile = "'" + args.snpfile + "'"

# setup the output stream
snpout = gzip.open(args.outfile, "wt")

# append snpfile to query call
bcfcmd.append(args.snpfile)
# join the list into a string
bcfquery = " ".join(bcfcmd)
snppipe = subprocess.Popen(bcfquery,
                           stdout=subprocess.PIPE,
                           shell=True,
                           bufsize=1)

# write only snp that has single nucleotide for both ref and alt
# read the first snp
prevsnp = snppipe.stdout.readline().decode()
snp0 = prevsnp.rstrip('\r\n').split('\t')
# check if snp is single numcleotide
validsnp = len(snp0[2]) == 1 and len(snp0[3]) == 1

# now read the rest of the vcf stream
nrep = 1 # the first snp has repeat of 1
for currentsnp0 in snppipe.stdout:
    currentsnp = currentsnp0.decode()
    snp1 = currentsnp.rstrip('\r\n').split('\t')
    # check if current snp has a new genomic position
    if snp1[1] != snp0[1]:
        # if prevsnp is valid write to output file
        if validsnp:
            snpout.writelines(prevsnp)
        # set snp0 and prevsnp snp0 a
        prevsnp = currentsnp
        snp0 = snp1
        validsnp = len(snp0[2]) == 1 and len(snp0[3]) == 1
    else:  # this snp has same position as previous one
        # if validsnp check that ref and alt match
        if validsnp:
            validsnp = snp1[2] == snp0[2] and snp1[3] == snp0[3]
        
# write the last stored prevsnp at the end of stream
if validsnp:
    snpout.writelines(prevsnp)
