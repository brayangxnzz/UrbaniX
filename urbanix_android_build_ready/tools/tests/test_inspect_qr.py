import base64, unittest, sys, pathlib
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]))
from inspect_qr import analyse

class TestInspectQr(unittest.TestCase):
    def test_bad(self): self.assertFalse(analyse('**')['valid_base64'])
    def test_shape(self):
        report=analyse(base64.b64encode(bytes(384)).decode())
        self.assertTrue(report['matches_single_observed_sample_shape'])
        self.assertEqual(report['valid_ticket'],'not determined')
    def test_short(self):
        self.assertFalse(analyse(base64.b64encode(b'ab').decode())['matches_single_observed_sample_shape'])
if __name__=='__main__': unittest.main()
