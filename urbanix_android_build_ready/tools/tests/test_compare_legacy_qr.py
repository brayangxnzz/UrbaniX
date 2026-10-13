import base64, pathlib, sys, unittest
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]))
from compare_legacy_qr import inspect_qr_text, compare_texts

class TestLegacyComparisons(unittest.TestCase):
 def test_original_shape_does_not_mean_authenticated(self):
  text=base64.b64encode(bytes(384)).decode()
  r=inspect_qr_text(text)
  self.assertTrue(r['same_observed_shape'])
  self.assertFalse(r['same_bytes_as_reference'])
  self.assertEqual(r['authenticity'],'NOT VERIFIED')
 def test_detect_same_payload(self):
  x=base64.b64encode(b'hello').decode()
  self.assertTrue(compare_texts([x,x])['all_same_bytes'])
  self.assertFalse(compare_texts([x,base64.b64encode(b'world').decode()])['all_same_bytes'])
 def test_bad(self):
  self.assertFalse(inspect_qr_text('x.123')['base64'])
 def test_no_false_positive(self):
  self.assertFalse(compare_texts(['bad','**'])['all_same_bytes'])
if __name__=='__main__':unittest.main()
