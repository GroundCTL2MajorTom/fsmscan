import optparse
import sys


def parse_args():
    parser = optparse.OptionParser('usage: %prog [options] target.com', version="%prog 1.5")
    parser.add_option('-f', dest='file', default='subnames.txt',
                      help='File contains new line delimited subs, default is subnames.txt.')
    parser.add_option('--full', dest='full_scan', default=False, action='store_true',
                      help='Full scan, NAMES FILE subnames_full.txt will be used to brute')
    parser.add_option('-i', '--ignore-intranet', dest='i', default=False, action='store_true',
                      help='Ignore domains pointed to private IPs')
    parser.add_option('-w', '--wildcard', dest='w', default=False, action='store_true',
                      help='Force scan after wildcard test failed')
    parser.add_option('-t', '--threads', dest='threads', default=500, type=int,
                      help='Num of scan threads, 500 by default')
    parser.add_option('-p', '--process', dest='process', default=6, type=int,
                      help='Num of scan process, 6 by default')
    parser.add_option('--no-https', dest='no_cert_check', default=False, action='store_true',
                      help='Disable get domain names from HTTPS cert, this can save some time')
    parser.add_option('-o', '--output', dest='output', default=None,
                      type='string', help='Output file name. default is {target}.txt')

    (options, args) = parser.parse_args()
    if len(args) < 1:
        parser.print_help()
        sys.exit(0)

    return options, args
