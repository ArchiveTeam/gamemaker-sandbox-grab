import sys
import requests
import re


def main():
    with open('suspect_items.txt', 'r') as f:
        for line in f:
            item_id, warc_size = line.split(None, 1)
            game_id = item_id.split(':', 1)[1].split('-', 1)[0]
            
            print('Check', item_id, file=sys.stderr)
            
            url = 'http://sandbox.yoyogames.com/games/{}/download'.format(game_id)
            response = requests.get(url)
            response.raise_for_status()
            
            match = re.search(r'(\d+\.?\d*) ([MK])B', response.text)
            
            if not match:
                print(item_id, 'ERROR')
                continue
            
            size = float(match.group(1)) * 2 ** 10
            
            if match.group(2) == 'M':
                size *= 2 ** 10
            
            print('  size', size, ' KB:', size // 2 ** 10, file=sys.stderr)
            
            if size > 200000:
                print(item_id, size)


if __name__ == '__main__':
    main()
