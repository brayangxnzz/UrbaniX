"""Independent Python interoperability check for the UV3 wire format described in Dart.
This is NOT a test execution of Flutter or evidence of V2 compatibility.
"""
import base64, json, time, secrets, unittest
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.exceptions import InvalidSignature

def b64(data): return base64.urlsafe_b64encode(data).decode().rstrip('=')
def unb64(data): return base64.urlsafe_b64decode(data+'='*((-len(data))%4))

def issue(sk,route='Metro',passengers=1,now=1_800_000_000_000):
    from cryptography.hazmat.primitives import serialization
    public=sk.public_key().public_bytes(serialization.Encoding.Raw,serialization.PublicFormat.Raw)
    payload=dict(format='URBANIX_V3_INTERNAL',version=3,id=b64(secrets.token_bytes(16)),route=route,passengers=passengers,issued_at=now,expires_at=now+900_000)
    message=b64(json.dumps(payload,ensure_ascii=False,separators=(',',':')).encode())
    return '.'.join(('UV3',message,b64(sk.sign(message.encode())),b64(public)))

def validate(token, trusted, now, used=None,consume=False):
    used=used if used is not None else set()
    try:
        prefix, message, signature, public=token.split('.')
        if prefix != 'UV3' or public not in trusted: return False
        data=json.loads(unb64(message))
        if (data['format']!='URBANIX_V3_INTERNAL' or data['version']!=3 or data['route'] not in ('Metro','Transmetro','Ruta Integrada','Muevo León') or not isinstance(data['passengers'],int) or not 1<=data['passengers']<=9):return False
        start,end=data['issued_at'],data['expires_at']
        if end-start!=900_000 or not start<=now<end:return False
        Ed25519PrivateKey # keeps import stable
        from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey
        Ed25519PublicKey.from_public_bytes(unb64(public)).verify(unb64(signature),message.encode())
        if data['id'] in used:return False
        if consume:used.add(data['id'])
        return True
    except (ValueError,KeyError,TypeError,InvalidSignature): return False

class CheckV3(unittest.TestCase):
    def setUp(self):
        self.sk=Ed25519PrivateKey.generate();self.now=1_800_000_000_000
        self.token=issue(self.sk,now=self.now)
        self.trust={self.token.split('.')[3]}
    def test_accept(self):self.assertTrue(validate(self.token,self.trust,self.now))
    def test_expiry(self):self.assertFalse(validate(self.token,self.trust,self.now+900_000))
    def test_before_issue(self):self.assertFalse(validate(self.token,self.trust,self.now-1))
    def test_untrusted(self):self.assertFalse(validate(self.token,set(),self.now))
    def test_modified_payload(self):
        x=self.token.split('.');data=json.loads(unb64(x[1]));data['passengers']=9;x[1]=b64(json.dumps(data,separators=(',',':')).encode())
        self.assertFalse(validate('.'.join(x),self.trust,self.now))
    def test_modified_signature(self):
        x=self.token.split('.');sig=bytearray(unb64(x[2]));sig[0]^=1;x[2]=b64(sig)
        self.assertFalse(validate('.'.join(x),self.trust,self.now))
    def test_replay(self):
        used=set();self.assertTrue(validate(self.token,self.trust,self.now,used,True));self.assertFalse(validate(self.token,self.trust,self.now,used,True))
    def test_wrong_format(self):self.assertFalse(validate('garbage',self.trust,self.now))
    def test_second_key_not_trusted(self):
        token=issue(Ed25519PrivateKey.generate(),now=self.now)
        self.assertFalse(validate(token,self.trust,self.now))

if __name__=='__main__':unittest.main()
