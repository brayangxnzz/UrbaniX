import unittest, tempfile
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from locate_aot_strings import inspect
class TestAotInventory(unittest.TestCase):
    def test_offsets(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'data';p.write_bytes(b'prefix-tickets_v2-suffix')
            r=inspect(p)
            item=next(x for x in r['matches'] if x['term']=='tickets_v2')
            self.assertEqual(item['offset'],'0x7')
    def test_absent(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'data';p.write_bytes(b'no text')
            r=inspect(p);self.assertIsNone(next(x for x in r['matches'] if x['term']=='tickets_v2')['offset'])
if __name__=='__main__':unittest.main()
