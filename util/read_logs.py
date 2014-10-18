import gzip
import glob
import json


def main():
    for filename in glob.glob('log-gamemakersandbox*.log.gz'):
        for line in gzip.open(filename, 'rt'):
            doc = json.loads(line)
            
            if doc['item'].startswith('user:'):
                continue
               
            if doc['bytes']['data'] > 200000:
                continue
                
            print(doc['item'], doc['bytes']['data'])


if __name__ == '__main__':
    main()
