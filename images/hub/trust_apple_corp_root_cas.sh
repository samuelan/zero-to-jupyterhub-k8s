#!/bin/bash
# Via: https://github.pie.apple.com/crypto-services/trust-apple-corp-root-cas

# Ensure bash is being used to execute this script (single brackets are used below to guarantee POSIX compliance)
if [ -z "${BASH_VERSION}" ] || [ -n "${POSIXLY_CORRECT}" ]; then
  echo "ERROR: Script requires bash and does not support POSIX mode (Run as follows: sudo bash $0)" 1>&2
  exit 1
fi

# Cause script to exit immediately after command failure, including any command in a command pipeline
set -eo pipefail

# When globing for directories, do not default to literal star
shopt -s nullglob

########################################################################################################################
# Constants
########################################################################################################################

# Note: For pre-configured roots we provide the alias and pre-calculated fingerprints to avoid the need for having a
# hard dependency on openssl (which may not be present on many systems)

readonly ROOTS_CORP=(
'
apple_corporate_root_ca
SHA1: A1:71:DC:DE:E0:8B:1B:AE:30:A1:AE:6C:C6:D4:03:3B:FD:EF:91:CE
SHA256: 50:41:69:C1:76:A2:C3:0D:A2:E9:0E:A9:8A:53:5D:78:EF:42:F3:1A:90:FA:48:B6:CE:C2:45:A4:72:12:7A:D3
-----BEGIN CERTIFICATE-----
MIIDsTCCApmgAwIBAgIIFJlrSmrkQKAwDQYJKoZIhvcNAQELBQAwZjEgMB4GA1UE
AwwXQXBwbGUgQ29ycG9yYXRlIFJvb3QgQ0ExIDAeBgNVBAsMF0NlcnRpZmljYXRp
b24gQXV0aG9yaXR5MRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQGEwJVUzAe
Fw0xMzA3MTYxOTIwNDVaFw0yOTA3MTcxOTIwNDVaMGYxIDAeBgNVBAMMF0FwcGxl
IENvcnBvcmF0ZSBSb290IENBMSAwHgYDVQQLDBdDZXJ0aWZpY2F0aW9uIEF1dGhv
cml0eTETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UEBhMCVVMwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC1O+Ofah0ORlEe0LUXawZLkq84ECWh7h5O
7xngc7U3M3IhIctiSj2paNgHtOuNCtswMyEvb9P3Xc4gCgTb/791CEI/PtjI76T4
VnsTZGvzojgQ+u6dg5Md++8TbDhJ3etxppJYBN4BQSuZXr0kP2moRPKqAXi5OAYQ
dzb48qM+2V/q9Ytqpl/mUdCbUKAe9YWeSVBKYXjaKaczcouD7nuneU6OAm+dJZcm
hgyCxYwWfklh/f8aoA0o4Wj1roVy86vgdHXMV2Q8LFUFyY2qs+zIYogVKsRZYDfB
7WvO6cqvsKVFuv8WMqqShtm5oRN1lZuXXC21EspraznWm0s0R6s1AgMBAAGjYzBh
MB0GA1UdDgQWBBQ1ICbOhb5JJiAB3cju/z1oyNDf9TAPBgNVHRMBAf8EBTADAQH/
MB8GA1UdIwQYMBaAFDUgJs6FvkkmIAHdyO7/PWjI0N/1MA4GA1UdDwEB/wQEAwIB
BjANBgkqhkiG9w0BAQsFAAOCAQEAcwJKpncCp+HLUpediRGgj7zzjxQBKfOlRRcG
+ATybdXDd7gAwgoaCTI2NmnBKvBEN7x+XxX3CJwZJx1wT9wXlDy7JLTm/HGa1M8s
Errwto94maqMF36UDGo3WzWRUvpkozM0mTcAPLRObmPtwx03W0W034LN/qqSZMgv
1i0use1qBPHCSI1LtIQ5ozFN9mO0w26hpS/SHrDGDNEEOjG8h0n4JgvTDAgpu59N
CPCcEdOlLI2YsRuxV9Nprp4t1WQ4WMmyhASrEB3Kaymlq8z+u3T0NQOPZSoLu8cX
akk0gzCSjdeuldDXI6fjKQmhsTTDlUnDpPE2AAnTpAmt8lyXsg==
-----END CERTIFICATE-----
'
'
apple_corporate_root_ca_2
SHA1: 93:B2:B7:E3:61:F5:34:7A:5A:99:52:6A:7C:85:92:F0:C0:3C:FA:BC
SHA256: 5E:A8:ED:04:2C:B8:8D:2A:40:A5:AE:E9:CB:C8:F1:C0:D1:93:95:4B:8C:47:1D:3A:05:A0:FA:04:9C:07:88:CB
-----BEGIN CERTIFICATE-----
MIICRTCCAcugAwIBAgIIE0aVDhdcN/0wCgYIKoZIzj0EAwMwaDEiMCAGA1UEAwwZ
QXBwbGUgQ29ycG9yYXRlIFJvb3QgQ0EgMjEgMB4GA1UECwwXQ2VydGlmaWNhdGlv
biBBdXRob3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMB4X
DTE2MDgxNzAxMjgwMVoXDTM2MDgxNDAxMjgwMVowaDEiMCAGA1UEAwwZQXBwbGUg
Q29ycG9yYXRlIFJvb3QgQ0EgMjEgMB4GA1UECwwXQ2VydGlmaWNhdGlvbiBBdXRo
b3JpdHkxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMHYwEAYHKoZI
zj0CAQYFK4EEACIDYgAE6ROVmqXFAFCLpuLD3loNJwfuxX++VMPgK5QmsUuMmjGE
/3NWOUGitN7kNqfq62ebPFUqC1jUZ3QzyDt3i104cP5Z5jTC6Js4ZQxquyzTNZiO
emYPrMuIRYHBBG8hFGQxo0IwQDAdBgNVHQ4EFgQU1u/BzWSVD2tJ2l3nRQrweevi
XV8wDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwMD
aAAwZQIxAKJCrFQynH90VBbOcS8KvF1MFX5SaMIVJtFxmcJIYQkPacZIXSwdHAff
i3+/qT+DhgIwSoUnYDwzNc4iHL30kyRzAeVK1zOUhH/cuUAw/AbOV8KDNULKW1Nc
xW6AdqJp2u2a
-----END CERTIFICATE-----
'
'
apple_corporate_rsa_root_ca_3
SHA1: 1A:9E:78:29:76:96:FF:C8:9F:EB:F5:D5:F3:05:3C:E1:53:8C:34:00
SHA256: B2:EC:09:00:2B:DE:DA:40:E2:46:A5:FC:9C:FF:81:36:6E:73:B5:71:D2:7C:A5:33:75:36:B1:BA:DA:96:5F:E5
-----BEGIN CERTIFICATE-----
MIIFhTCCA22gAwIBAgIUcq4V0xpX0K4oAn9EyM6pTpuoKwswDQYJKoZIhvcNAQEM
BQAwSjELMAkGA1UEBhMCVVMxEzARBgNVBAoTCkFwcGxlIEluYy4xJjAkBgNVBAMT
HUFwcGxlIENvcnBvcmF0ZSBSU0EgUm9vdCBDQSAzMB4XDTIxMDIxNzE5MzAzMVoX
DTQxMDIxMzAwMDAwMFowSjELMAkGA1UEBhMCVVMxEzARBgNVBAoTCkFwcGxlIElu
Yy4xJjAkBgNVBAMTHUFwcGxlIENvcnBvcmF0ZSBSU0EgUm9vdCBDQSAzMIICIjAN
BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAwLsOaWB6T5qq58bICdbu6HBXPx9t
Y0M2i6V8xtLQbJQqM8gGALEsPyvUhOBACmPCoaafeKjx4++IjHi4Hn+j14OFg7J8
w6yr2f8mW7d47LoIkOt9OeqGhdZi/VU38oJd7qEye7hk6kCFhagOzBNJ1DILHPb4
04C2XGat4tUMFGzUlmQ3wsJIINIpq9jevasz+uA29GGPTgVMkWlqwNtxw74GoqF4
jnNmno5/W8M6cyzjh3AGZU3DWHfr3ZvACUVftJsm/htsoCNm0sr5t/iXClu6+STO
nmR3Leiq1w40kSFnD9obTs884U+iq49kr2tteSSvZV53YHuxkaBIG92wGOMyYhZ9
q3AluVokLHjOGW6tN/seFP0b51gOl/p+mDDLA3fSG5RuuMqjvHQXiSiBu5OTCtCd
8cbyPhiSAvYl0rhsWeYItcwWflVCUB7HAy/qlwicNo9aE0aSaN/3qmU4TzXW8H70
lbh6A2cKxGr9+y479d/DLGfcFj89wvmrhHrW3mZIgVwVjV49BfLed1Swihezit/a
CPQ0WF17FfqxIedVPusdjcfeT6BCU/X/+cq0sv06CiFZ4KNmDOn2XLii82xfMcj1
xWE+HufMWDuwS5DHJt0ttbknD1togzPBxaEu1/nIqZ5kYVUkCi+YXJQihaX+F5aJ
kacwlGPAmIBrMLcCAwEAAaNjMGEwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAW
gBSNX/LRHQdiX1xtg8SPTXcr6sPmqjAdBgNVHQ4EFgQUjV/y0R0HYl9cbYPEj013
K+rD5qowDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBDAUAA4ICAQAOvvN+Prwt
KG2fROheiSw4scNk0WXcczWpUvYQKtMw5FzYofA28AYoE/HT2qQXFldMq+FlJ0v/
sWVkXWB3X9RQltUXZ0RLVdw7/ZGXzUZh7ui2VXMRFv8wAgO8FwMzOTheZYeVB6gq
fJ0jYkCA4CjAmCuGPieZMmNENI/Nup0W6P1bPO5xOxre787BpXQrqXZ/VpLauGqC
YX17rkpJG4w+4zFEl1Ex5K74gp+VQnrC7+WGgwd996gFRPURQL5oJC/1ofnhQedo
kdTbwPyeqK94WRhYihe3uq7B8rAsxoxPTY3oxEfN0oSuP9IEgoUZBhee9HeDMCjS
fbiL/JW/w1VjXyuufkfQbuvx122GZFCAFBej2DAGXWZKghOG7XxyPYYlam7A5eBQ
DIJ+nY4hRh9r01A0LszRA5oQXs3nhUqWymbiR2gXMGrumsC0tGB45FKX3xWKBg+a
iQ3bdfyLcLgM0c2eXgQRvX1k89D5El/byushVTWSjUgf/4UwgxfvzmvAiZm8KSGb
Jd7SSZPCQmVwNbq/RlwVt4QIMv1lHXnvklc8ZQKmdNRHo/sICl00jGCq4ahpLcul
WeRrAdvaWk/fatr0ywplIByHtvntZnLQ06GSWu+1cRP4TmLxblJrnRj2oq26QN70
yhWSKDdj61wiTWzsGel3LblgJGdr2QtmZA==
-----END CERTIFICATE-----
'
)
readonly ROOTS_APZ=(
'
apz_ec_root_ca
SHA1: 23:4F:E0:B7:A4:48:C7:68:BF:9C:3F:1B:9D:F9:0E:F2:E8:E4:13:6C
SHA256: 75:B8:D4:E0:0D:F9:4F:13:D9:1B:BB:5E:39:97:14:24:2C:FC:3D:6C:CD:75:DD:C1:1C:6A:88:DC:39:8D:5A:B2
-----BEGIN CERTIFICATE-----
MIIBrzCCATWgAwIBAgIQIDgbPLOvBKyjzSSyIc7xhTAKBggqhkjOPQQDAzAZMRcw
FQYDVQQDDA5BUFogRUMgUm9vdCBDQTAeFw0xOTExMTQwMDU3MzdaFw00NDExMDkw
MDAwMDBaMBkxFzAVBgNVBAMMDkFQWiBFQyBSb290IENBMHYwEAYHKoZIzj0CAQYF
K4EEACIDYgAE3XnjbLREdx7YuS0iGUrfOiazmPXXwol6tbgZdoku3S+5XNoodlwn
Fzp2I3aHr8svEnMaetVMN/SVaSlAAj8MXs/vUcrQ/83OMxd/pE736Mt/0iUuuJ6H
zZHMMoBfjba0o0IwQDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQW53qBfnRf
LZK48YsoAwkP/cqRVjAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwMDaAAwZQIw
dYCYmy30TmOoMQW1OXbRpEZF7GyAxwK10DbrEo4til4IeTkXfn/6IH/PMpw8iHoH
AjEA29zXw7JWtSQCjgeA9jAd7+lly11WgV3nK9gIPzXxv7KQWmjT1oYuSjKnOLXL
6wDS
-----END CERTIFICATE-----
'
'
apz_rsa_root_ca
SHA1: 1F:95:28:57:09:30:7E:B8:69:BC:55:AA:10:80:1A:8F:EB:F7:D7:2D
SHA256: 72:AF:40:C4:0D:40:55:AA:86:CD:1E:AB:E6:BF:86:2E:7D:A1:FF:EC:09:43:7D:4B:CA:AD:64:D1:F6:52:61:36
-----BEGIN CERTIFICATE-----
MIIFADCCAuigAwIBAgIQdLFutURIdbiN+XFLbSxo4jANBgkqhkiG9w0BAQwFADAa
MRgwFgYDVQQDDA9BUFogUlNBIFJvb3QgQ0EwHhcNMTkxMTE0MDA1NTA3WhcNNDQx
MTE0MDA1NTA3WjAaMRgwFgYDVQQDDA9BUFogUlNBIFJvb3QgQ0EwggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDKcfDZfUN9uoCu6fvhzT5B1Sq5yDMpQ9/Y
BOg+klx3UEgUicB6ZshNlyXGt7p9+fY3HQns+T1JE4JfaAoekolteUeCLbi2xRHd
MG+3MP9B8EomAPle4B+V7ATTq45GgwzkCwJQUafG5oOstI2a1dL6xGZmhcW0G9oA
h64qOes9oNNU4pqJaT9VMasIEWuOVOiyA5eK6UUaNNfULSpjHXbpxJMIqTls+G/L
/eFtItvnYS3Qq4Bw9msw9oXiygjHt4wlJugLqjYnt7W4LH6RufRmAZ1e9PqggO5l
VZqezn8Z3C1PUW5Yq+ojEEL5xq6mcef/X+e5iur7nP34Mk0pxH/mRzFqeYB53xza
l4aeRiAOIuIy4lfW1w2zQBShXNQ49LdtQmFk/ZLSRkB3OGf0Hgtl3vhocNMRIANf
HOxqHz4tsdQmhmqDK0ko/B5Qd2hlmDaFeuBkhkJ6AhZYudISHartCviIMNa7f+N+
JfqPUH0IwDpJMFPaNEZbFNXsSMmm5kAzOcWE/oX+9tIsvrAGcvrU6U1p2bYTsmsQ
73at8qx0AxJNnQJC+3ts3HGI4A51Gx1Jc52hhcaa1M9iik9w6qL7/ZkkIty2Vf5i
0QTqvRiDjtcBqEN0xjDWSc/U5RpavxUl16/tke4/AmN6XvF+i6Z4Nn9XcIWq60L8
jA/NImL0FQIDAQABo0IwQDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQ9mLgg
o25IPfqX47wFmT2oQ+q58DAOBgNVHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQEMBQAD
ggIBAIXtCTykzgQ4cp/qO8BnSSW9eCUQhdMxQs2Sc+kPO+cnWts6aPJavaaeqNiR
Tkn8E9cHFHWr0BIQC2XaxntacceOIMjpPPioXFStxVSlvXD/hrQlaKZedQr5RPDY
TmCh5ZaNgLjTxFBAptMm+LLB93VsjEgX99Vh79TIW+ld1e6/XCPce46u8UYNO1fV
d1nVPxwwHNfNMDnExWyoTemoIvedo8BN5uBc4Xhvh4A7I8J4YVLcJL1RoSc6VTXY
HAcEI3JgGYSCOKwEcT7GTtrx351rqNswXvqJ3GMp51wNPP7wmhuEt0/XgXJx7h9o
CTaSdqfdd/Phe81zTQvl1OTa4ZAvc4H1Ra5yybl7bTtQi66vwARtBy52BLZ6WHMM
jlfLNBqGjkH8AMxEMReHnPZPuq+rmopOQ8qkTKRQkuitpr35HBAjNLRz2naSx7Qm
Rb7WFtS1nWqVn9Gl01phgPGuGiBLtOJBCeAzRveSqUJTMWB8F3N4xBNO5djkT5EU
IqgXJRr0QzSAhwoo5V/PxaS1EBOrXcYAAvdAMOAPzuiKT1EtC4N9obby4EbqFJFy
X9M73lcklRWhhz5dWE4dqLe2phKFfrgyBNtaNrDJ9Z9/c9ci2GxqLeM44yhAfiBV
Aeu3VNbMTh//hzyXlC9X9r9mCOxju1tiPX2VO//gOkFiWbbt
-----END CERTIFICATE-----
'
)
readonly ROOTS_SILK_ROAD=(
'
silk_road_ec_root
SHA1: 10:64:33:26:D0:93:13:31:55:C8:4F:82:8B:63:CD:3F:10:BA:67:D7
SHA256: D6:2D:F5:9C:78:CE:42:59:B6:3C:B2:6F:71:5B:36:C8:C8:4E:22:01:69:3E:26:D2:23:94:0E:A8:79:34:42:F4
-----BEGIN CERTIFICATE-----
MIIBeDCCAR6gAwIBAgIQUkEYmd/cRfV1tNZfzyCZbTAKBggqhkjOPQQDAjAcMRow
GAYDVQQDDBFTaWxrIFJvYWQgRUMgUm9vdDAeFw0xOTA5MjYyMTIxMDhaFw0yOTA5
MjYwMDAwMDBaMBwxGjAYBgNVBAMMEVNpbGsgUm9hZCBFQyBSb290MFkwEwYHKoZI
zj0CAQYIKoZIzj0DAQcDQgAEwBCzhytCvQtaWqpuJ254/KooOu7YIN2/x2b6lgtF
irkhaESWggYbs4uIPKGR4WXMhxPJJbs2Rd7ME3q3F6/djqNCMEAwDwYDVR0TAQH/
BAUwAwEB/zAdBgNVHQ4EFgQUMq3eAOZ5WQ/mTWzL89ft/ka1tdAwDgYDVR0PAQH/
BAQDAgEGMAoGCCqGSM49BAMCA0gAMEUCIQCjX/OMop3yaknrBZ9dm62Y/AAve0O6
ar1lWKTnTjYiPgIga1BDmdtpgAGRSYe/+uoVQGm0MI4QcWPbyrTUwcBaCOA=
-----END CERTIFICATE-----
'
'
silk_road_rsa_root
SHA1: 68:9E:BA:36:0A:78:AB:C0:96:8C:10:D3:F7:EC:20:69:38:2B:20:62
SHA256: 6B:52:F9:96:BB:D9:1B:97:9C:F7:80:85:15:AB:2D:CC:01:AC:9B:09:6B:F6:7A:46:82:17:66:A1:0D:FA:0D:F2
-----BEGIN CERTIFICATE-----
MIIDBjCCAe6gAwIBAgIQBoLACadXHcaj9T1O24PdEjANBgkqhkiG9w0BAQsFADAd
MRswGQYDVQQDDBJTaWxrIFJvYWQgUlNBIFJvb3QwHhcNMTkwOTI2MjExNjM1WhcN
MjkwOTI2MDAwMDAwWjAdMRswGQYDVQQDDBJTaWxrIFJvYWQgUlNBIFJvb3QwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDHHY1lDNlNZG/o0JrNzernqLfw
Nf62Z/uvishB9BYHnxKZjKVNKzl+Q0BxhrGKfyEVJuGgueJCd2ZFi2XMOyxmNPk6
oVMWTtAdFspaY9CvnE9ANNt7nsq01cz509M83y47Pu/Ke6SRHegRvgbwtr1AqLGF
Vp3z2rfxcj1T0kTvirWZ9R6OFmAq/NMS5F6SwV4HnBje3ojS4E0AVxhLKpWS5Vw5
CwA86OL+LeDQcG3LPDsUDvL6if4o0lGiPm2PO6v3jEV5sR6WuPSShzReesKJS7Je
qCzn18gi0Uv+6/bVQd+qNYSkk+bC3W1+UfLlMAxxmw/PlViu0LbXOYl2MYTPAgMB
AAGjQjBAMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFAD1wS5nn0mhr/3HYVXY
vwbIi55gMA4GA1UdDwEB/wQEAwIBBjANBgkqhkiG9w0BAQsFAAOCAQEAs2kUPA5J
DuUrux6q2eseBA7tMd5XWoycmg8oSMVGA08489PZOlcAmlBDxI5qLbk/BViZDc5A
EaBaeqmtzjU/w7yGS3HCWPmHTkK6BIFCahNAuflcNJhbYz1yln68IsSmq33MNVJH
FUikB5o5x+5mbxU+3bBLJHd3Tuq2myhk4+iBCwM9NJ6IJZX+2sCz6dqV6UB7ovJd
G9pny2pEPsvdOC+UdPZQzkARTTTq3lI9GDGcOcRLZtXV14lJIAi4kGeIhoHQ9kpk
nL4gd8Y+xFauDELHCmcFHaDT9YaUfZ2a9fO/S+qdjl52nkqrMC2761tdjVSedtm/
bH3JerDV0mVSsQ==
-----END CERTIFICATE-----
'
)
readonly ROOTS_GOLDEN_GATE=(
'
golden_gate_ec_root
SHA1: A5:4B:CE:17:B6:1E:85:BD:0B:FF:7C:75:15:64:D4:A0:87:A1:02:BA
SHA256: A0:11:EF:AE:66:2E:E1:88:D1:EB:BA:51:8F:3F:EC:F9:8B:C9:8A:3E:18:42:F5:01:2B:CC:30:B3:CC:F4:AE:42
-----BEGIN CERTIFICATE-----
MIIBuTCCAT+gAwIBAgIQcMngVTgk+JXGIkuph3DDODAKBggqhkjOPQQDAzAeMRww
GgYDVQQDDBNHb2xkZW4gR2F0ZSBFQyBSb290MB4XDTIwMDMxODIwMTcwNloXDTQ1
MDMxNTAwMDAwMFowHjEcMBoGA1UEAwwTR29sZGVuIEdhdGUgRUMgUm9vdDB2MBAG
ByqGSM49AgEGBSuBBAAiA2IABEfLlVEnwmQiaFX0g/l7cVhFCSSsKTerTuK3I0Ab
CFljyUZxl1PoHk7jRo4fsHK+XatspWYcqRCNVlS3TR5DO+lxgqPsk7Oaz1Uv0I+T
JMSPCtYVygAszvm48haVq6Fdd6NCMEAwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
FgQUr/SlpOBxle7aXUTIROYXRF93V4owDgYDVR0PAQH/BAQDAgEGMAoGCCqGSM49
BAMDA2gAMGUCMAUE/rPI+iCnJrjlGLg8UEZJ2h48F1EFdIvwXJeVPB2R6lP2nngZ
MvxNa2nphFxGcAIxAP/V4Yo9zvpzuIZbbS+U09sQdsD06QCr3CISJC0mSlL7eeXX
4HDJFz3MUubsT6iF4Q==
-----END CERTIFICATE-----
'
'
golden_gate_rsa_root
SHA1: 72:CD:FE:90:DF:C2:74:FC:AD:37:CD:B3:ED:94:FD:5C:8A:3D:CE:47
SHA256: D3:13:43:79:58:F9:91:3E:6C:5F:F8:AE:76:B9:FE:B4:7D:96:F0:20:58:39:14:82:8E:C9:C2:89:F7:DD:AB:00
-----BEGIN CERTIFICATE-----
MIIFCjCCAvKgAwIBAgIQVMmKVXphJRtb32RL2F7vvjANBgkqhkiG9w0BAQwFADAf
MR0wGwYDVQQDDBRHb2xkZW4gR2F0ZSBSU0EgUm9vdDAeFw0yMDAzMTgyMDEyMzJa
Fw00NTAzMTUwMDAwMDBaMB8xHTAbBgNVBAMMFEdvbGRlbiBHYXRlIFJTQSBSb290
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA3nZMGoSs1D8kxSx4Ercv
3IRsCVSDnHR2j6t5H5Ewhjj1MY2DyiGCUFs8EyAj4TMAtKihK2Z4uOdxehQZVLG8
DZhNWiTkKglZv/OhfRe7xHakkuoNwo4FcmQjElBQH4Q3ueXN55hZfwwtPD/bW9wR
+DlufLH73sh1i1mvt5HA1WB1UKcHzUhO5DeIKlDt0J1w4g6RII2xar6TSUud/+Rx
wdrU1YmjcSv7V60cEbucs2bKmV/vB7Vq1sYJ1iixjIar+7s3B+z9WyqstFjJh1xY
6Ru+/CJxN702Oh8HrxMTYUc8G8abvZTZUHOet4y2N6sAjPNf2ESNMwnQCOcNv2yN
azGdUsxS8kZSTP20hbbZpPajNxJJ6ZPGLjYaRS216fEM41wqLu5R15nyzLu5me+L
7HR9delYSHq2ysVZt+mBZR6E2EDCC2G5ec81QzkmnsOQwOyrAcDIVQ2klV+KPyrb
soNccmkVWjmqmgSQI/oplxu0OoDh5lE8CW5M/GJeEYz8Q3bV+JERuwm6t662nRuj
AXk8M1ljEbmqQRr3vShvm1Y/D6i3kvCEXEoeHIEU74/xhWRXJR9UcNBYmImiD6U3
2BLw0saqBRuByOEJDiieb+pMAeq+IqBENrT7YGyW1BtsRNdQ/FL7TM2V3opoQ1nu
8l68fdEZxal17DJp/brDdfcCAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAdBgNV
HQ4EFgQUgA3jctgatEyI5lp9oDm7m4VrMYcwDgYDVR0PAQH/BAQDAgEGMA0GCSqG
SIb3DQEBDAUAA4ICAQCX1iE2DsMcgNAIkUu6rEERIAijab4Sd4jA+YdcNvc53B01
DyDZYRPW6R3J+hvhaWfgiKav/25todBaVm1lK05lccmBFFkOnA0wclahloRuA1C3
E/Lx/jDmRCWpMUdWHCo7MD+AqDo/x8jMFkl8Y1EibCtmtzf03yN1qx6pq4OwrO9F
FR/Fq3trtdTK4iXbs4JI7ElQhnqX5NdgYt6xYpog/2AiJx7CCDSllgAV/MPOvB49
Fpk9rx0bePw9GIZxvlcqPD85OjU14YV5cZMqYnaXY6iYxrSyrgwRoR+CRHnCqG16
radPO5nGlsmDute/ZSnvTEa8ffYB2z8Te1o58u66AqHKwF36cpFIBWys4OJ/67PH
5kDNuSCkCae0GZ1SGRq0Omv4DjfdApltqwY4fQY0R/Z6IPa0rVEygKP/5f4R6U9Z
mvy8gu4DRKyszPHHu4iwznmhT1hULufku/R3I/dJYgPYHrV96BhqOn62UrqEei7d
Q+yh++ZQuNYlngAM/ZCfrSy74+dev6pDnQF/oPKRlpUI7jSXlweW5FIi9DoJ88gU
Z8Q6nBy38gDDqqy4R8eFQYq/wCAyZh9SpBfquwM4HsROypg8wKLDpgRXuRUSVLTp
Mcf9qpY0bgvHtLY1nThDz+DKroIUNPJqvWVXGDa20e4U5l5iWF5NYIHOF5F8BQ==
-----END CERTIFICATE-----
'
)

readonly CURRENT_USER_DIR=~

TRUST_STORE_SEARCH_PATHS=(
  # macOS
  /Library/Java                                                 # Java
  /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin           # Java
  /Library/Python                                               # Python
  /System/Library/Frameworks/Python.framework/Versions          # Python
  /Library/Frameworks/Python.framework/Versions                 # Python
  /etc/ssl                                                      # Openssl
  /Applications/IntelliJ*.app                                   # Java: IntelliJ IDEA (may include version number)
  /Applications/PyCharm.app                                     # Java: PyCharm
  /Applications/GoLand.app                                      # Java: GoLand
  /Applications/Burp\ Suite\ Professional.app                   # Java: Burp Suite Professional
  /Applications/Burp\ Suite\ Community\ Edition.app             # Java: Burp Suite Community Edition
  /Applications/DBeaver.app                                     # Java: DBeaver Universal Database Manager
  /Applications/Tableau\ Desktop.app                            # Java: Tableau Desktop
  /Library/Dremio                                               # Dremio
  # linux
  /usr/lib/python*                                              # Python
  /usr/java                                                     # Java: OracleJDK (CentOS/Debian/OEL/RHEL/SUSE/Ubuntu)
  /usr/lib/jvm                                                  # Java: OpenJDK (CentOS/Debian/OEL/RHEL/Ubuntu)
  /usr/lib64/jvm                                                # Java: OpenJDK (SUSE)
  /etc/java                                                     # Java: OpenJDK (CentOS 8: symlinks to this location)
  /usr/local/openjdk*                                           # Java: openjdk 8-11 containers
  /opt/Oracle/Middleware                                        # Java: Oracle Middleware applications
  /etc/pki/tls                                                  # Openssl: System
  /home/linuxbrew/.linuxbrew                                    # Openssl: Homebrew
  /opt/chef/embedded/ssl/certs                                  # Chef Embedded Trust
  /opt/chef-workstation/embedded/ssl/certs                      # Chef Workstation Embedded Trust
  /opt/vagrant                                                  # Vagrant on linux
  # MacPorts
  /opt/local
)

# brew
if command -v "brew" >/dev/null; then
  BREW_PREFIX=$(brew --prefix)
  BREW_CELLAR=$(brew --cellar)
  BREW_REPO=$(brew --repo)
else
  BREW_PREFIX="/usr/local"
  BREW_CELLAR="${BREW_PREFIX}/Cellar"
  BREW_REPO="${BREW_PREFIX}/Homebrew"
fi
readonly BREW_PREFIX
readonly BREW_CELLAR
readonly BREW_REPO
TRUST_STORE_SEARCH_PATHS+=(
  "${BREW_CELLAR}"/openjdk*                                     # Java
  "${BREW_PREFIX}"/etc/openssl*                                 # Openssl
  "${BREW_REPO}"/Library/Homebrew/vendor/portable-ruby          # Portable Ruby
  "${BREW_PREFIX}"/lib/python*                                  # Python
  "${BREW_CELLAR}"/python                                       # Python
  "${BREW_CELLAR}"/twine-pypi/*/libexec/lib/python*             # Python: twine
  "${BREW_CELLAR}"/httpie                                       # Python: httpie
  "${BREW_CELLAR}"/awscli                                       # Python: awscli
  "${BREW_CELLAR}"/certbot                                      # Python: certbot
)

# java
if command -v "java" >/dev/null &&
   JAVA_HOME="$(java -XshowSettings:properties -version 2>&1 \
                | grep "java.home" | sed 's|.*java.home[^/]*\(.*\)|\1|')"; then
  readonly JAVA_HOME
  TRUST_STORE_SEARCH_PATHS+=("${JAVA_HOME}")
fi

# anaconda
if command -v "conda" >/dev/null &&
   CONDA_PATH+=("$(conda env list | grep base | awk '{print $NF}')"); then
  readonly CONDA_PATH
  TRUST_STORE_SEARCH_PATHS+=("${CONDA_PATH}")
else
  TRUST_STORE_SEARCH_PATHS+=("/opt/"*conda*)
fi

# unix
TRUST_STORE_SEARCH_PATHS+=(~)                                   # Catch-all: Current user's home directory; can be
                                                                # disabled by specifying --no-user-dir
readonly TRUST_STORE_SEARCH_PATHS

# Paths to exclude from trust store find results
#
# NOTE: `find` matches against expanded absolute paths, so ~ cannot be used here
readonly TRUST_STORE_FIND_FILTERS=(
  \(
  # macOS
  -not \( -path '/Users/*/Library/Calendars' -prune \)                        # don't prompt for Terminal access to Calendars
  -not \( -path '/Users/*/Library/CloudStorage' -prune \)                     # don't prompt for Terminal access to cloud storage (e.g., Box)
  -not \( -path '/Users/*/Library/Application\ Support/AddressBook' -prune \) # don't prompt for Terminal access to Contacts
  -not \( -path '/Users/*/Library/Reminders' -prune \)                        # don't prompt for Terminal access to Reminders
  -not \( -path '/Users/*/Pictures' -prune \)                                 # this can be huge, lets NOT search inside it
  -not \( -path '/Users/*/.Trash' -prune \)                                   # doesn't make sense to updated deleted trust stores
  # conda
  #
  # Don't modify conda's cached packages b/c it corrupts integrity checks)
  #
  # Note: Unfortunately the path to anaconda packages is controlled by the user that installed anaconda, so attempting
  # an exclusion like '*conda*/pkgs' isn't guaranteed to work. Additionally, discovering the anaconda packages location
  # by calling the 'conda list' command won't work unless conda is active (and there can be multiple conda installed).
  # So, the best compromise we came up with was the set of exclusions below.
  -not \( -path '*/pkgs/*jdk*' -prune \)
  -not \( -path '*/pkgs/ca-certificates-*' -prune \)
  -not \( -path '*/pkgs/certifi-*' -prune \)
  -not \( -path '*/pkgs/requests-*' -prune \)
  -not \( -path '*/pkgs/pip-*' -prune \)
  # bazel
  #
  # Don't modify the JDK bazel ships with to avoid "corrupt installation.... cacerts' is missing or modified" errors
  -not \( -path '*/.cache/bazel' -prune \)
  \)
)

# Whole name values to include in trust store find results
readonly TRUST_STORE_FIND_WHOLENAMES=(
  \(
  -wholename    "*/lib/security/*cacerts"            # Java
  -o -wholename "*/Caches/*/tasks/cacerts"           # JetBrains (e.g IntelliJ IDEA, PyCharm, GoLand, etc)
  -o -wholename "*/ssl/cacerts"                      # JetBrains (alt. installation path)
  -o -wholename "*/certifi/cacert.pem"               # Python certifi
  -o -wholename "*/botocore/cacert.pem"              # Python botocore
  -o -wholename "*/requests/cacert.pem"              # Python requests
  -o -wholename "*/etc/*/cert.pem"                   # OpenSSL
  -o -wholename "*/ssl/cacert.pem"                   # OpenSSL (conda)
  -o -wholename "*/ssl/cert.pem"                     # OpenSSL (conda)
  -o -wholename "*/certs/cacert.pem"                 # Chef
  -o -wholename "*/portable-ruby/*/libexec/cert.pem" # Homebrew Portable Ruby
  -o -wholename "*/Dremio/*/lib/cacerts.pem"         # Dremio
  -o -wholename "*/.conan/cacert.pem"                # Conan (user home config dir)
  -o -wholename "*/vagrant/embedded/cacert.pem"   # Vagrant
  \)
)

readonly JETBRAINS_TRUST_STORE_SEARCH_PATHS=(
  # macOS
  ~/Library/Caches/IntelliJIdea*  # IntelliJ IDEA
  ~/Library/Caches/IdeaIC*        # IntelliJ IDEA Community Edition
  ~/Library/Caches/PyCharm*       # PyCharm
  ~/Library/Caches/GoLand*        # GoLand
)

########################################################################################################################
# Functions
########################################################################################################################

syntax_error_note() {
  echo "Note: For detailed help/usage information re-run with the --help option"
}

handle_shift_error() {
  local -r arg_name="${1}"

  echo "ERROR: ${arg_name} argument value is missing but required"
  syntax_error_note
  return 1
}

# Prints a Usage statement to STDOUT
usage() {
  cat <<EOF
Usage: trust_apple_corp_root_cas.sh [-h|--help]
                                    [--no-user-dir]
                                    [--no-corp]
                                    [--apz]
                                    [--silk-road]
                                    [--golden-gate]
                                    [--no-os-trust-store]
                                    [--additional-cas <file>]
                                    [search_path...]

  Updates system trust stores with Apple Corporate roots. Supports updating OS,
  Java, Python, and OpenSSL trust stores.

options/flags:
  -h, --help:           Show this help message and exit.
  --no-corp:            Do not install Apple Corporate Root CAs.
  --apz:                Install APZ Root CAs.
  --silk-road:          Install Silk Road Root CAs.
  --golden-gate:        Install Golden Gate Root CAs.
  --no-user-dir:        When searching default search paths, do not search ~.
                        Ignored when search_path is specified.
  --no-os-trust-store:  Skip updating OS trust stores.

optional arguments:
  --additional-cas:     File containing additional Root CA certificates to be
                        trusted in PEM format. Use of this feature introduces
                        a hard dependency on openssl.

search_path:  Path on filesystem to search for default Java trust stores under.
              When not provided, the following defaults are used instead:
                $(printf '%s\n                ' "${TRUST_STORE_SEARCH_PATHS[@]}")
EOF
}

assert_command_exists() {
  local -r command_name="${1}"
  local -r command_missing_details="${2}"
  if ! command -v "${command_name}" 1>/dev/null 2>&1; then
    echo "ERROR: Command '${command_name}' is missing but required${command_missing_details}"
    return 1
  fi
}

# INPUTS
# $1: certificate format ("PEM" or "DER")
# $2: path to certificate file
#
# OUTPUTS
# stdout: certificate fingerprint
get_cert_fingerprint() {
  local -r inform="${1}"
  local -r cert_file="${2}"

  openssl x509 -inform "${inform}" -in "${cert_file}" -fingerprint -sha256 -noout 2>/dev/null
}

# INPUTS
# $1: path to folder containing certificate files (without trailing slash)
#
# OUTPUTS
# stdout: certificate fingerprints (one per line)
get_cert_fingerprints() {
  local -r cert_files_path="${1}"

  local cert_file cert_fingerprint
  for cert_file in "${cert_files_path}"/*; do

    # Attempt to determine certificate fingerprint
    #
    # First try PEM format
    if ! cert_fingerprint=$(get_cert_fingerprint "PEM" "${cert_file}") ; then
      # Then try DER format
      if ! cert_fingerprint=$(get_cert_fingerprint "DER" "${cert_file}") ; then
        # Unable to parse certificate and determine fingerprint; skip file (e.g. not an X.509 certificate)
        continue
      fi
    fi

    # Append successfully gathered fingerprint to list of fingerprints
    echo "${cert_fingerprint}"
  done
}

# INPUTS
# $1: path to folder containing certificate files (without trailing slash)
# $2: root file extension (e.g. pem, crt)
# $3: certificate fingerprints (one per line)
#
# OUTPUTS
# $update_ca_trust_required: 0 indicates update not required, otherwise update is required
add_roots() {
  local -r cert_files_path="${1}"
  local -r root_file_ext="${2}"
  local -r cert_fingerprints="${3}"

  local ca_record alias fingerprint cert
  update_ca_trust_required=0
  printf '\nAdding Apple Corporate Root CAs to OS trust store:\n'
  for ca_record in "${ca_records[@]}"; do
    alias=$(sed -n '1p' <<< "${ca_record}")
    fingerprint=$(sed -n '3p' <<< "${ca_record}" | sed 's|SHA256: \(.*\)|\1|')
    cert=$(sed '1,3d' <<< "${ca_record}" )
    echo "  ${alias}"

    # Check whether or not root certificate is already present in the trust store
    if [[ "${cert_fingerprints}" =~ .*"${fingerprint}".* ]]; then
      # Present: no further action needed
      echo "    already present"
    else
      # Absent: add root certificate
      echo "${cert}" > "${cert_files_path}/${alias}.${root_file_ext}"
      update_ca_trust_required=1
      echo "    added"
    fi
  done
}

# INPUTS
# $1: value to search for in trust store; when found, this indicates the root is already present
# $2: value to append to trust store; when search finds nothing, this is value is appended
# $3: path to the trust store; this is the trust store being updated (must be a PEM trust store)
#
# OUTPUTS
# none
add_root_to_pem_trust_store() {
  local -r search_value="${1}"
  local -r append_value="${2}"
  local -r trust_store="${3}"

  # Check whether or not root certificate is already present in the trust store
  if grep -q -- "$(tr '\n' '\01' <<< "${search_value}")" <(tr '\n' '\01' < "${trust_store}"); then
    # Present: no further action needed
    echo "      already present"
    return 0
  fi

  # Absent: import root certificate into trust store

  # Ensure trust store file permission allow write
  if [[ ! -w "${trust_store}" ]]; then
    echo "      ERROR: User does not have permission to modify trust store"
    return 1
  fi

  # Handle trust store file that does not end with a new line
  #
  # Important: To avoid corrupting a PEM trust store we handle a trust store file that does end with a new line by
  # adding one before appending any additional entries. Also, since it's also best practice to end a file with a
  # carriage return character so we do that too.
  local append_value_prefix=''
  if [[ $(tail -c1 "${trust_store}" | wc -l) -eq 0 ]]; then
    append_value_prefix=$'\n'
  fi

  # Attempt to append root certificate to trust store
  if ! printf '%s%s\n' "${append_value_prefix}" "${append_value}" >> "${trust_store}" ; then
    # Import failed
    echo "      ERROR: Unable to add certificate to trust store"
    return 1
  fi

  # Import succeeded
  echo "      added"
}

# INPUTS
# none
#
# OUTPUTS
# none
update_os_trust_store() {
  # Supported OSs:
  # - CentOS 6,7
  # - Debian 8,9
  # - macOS 10.14
  # - OEL 7
  # - RHEL 6,7
  # - Ubuntu 12,14,16,18

  printf '\n==========================  Updating OS Trust Store  ===========================\n'

  # Note: This script uses the update-ca-trust tool to perform the update in manner that will not conflict with
  # packages that perform a similar function. Specifically, the script first adds Apple Corporate roots certificates as
  # individual PEM files located at /etc/pki/ca-trust/source/anchors/, and then runs the 'update-ca-trust extract'
  # command to scan these "source" files and produce updated versions of the consolidated configuration files located
  # at /etc/pki/ca-trust/extracted

  # Check whether or not script is being run as root
  if [ $EUID -ne 0 ]; then
    # Script not running as root; unable to update trust store
    printf '\nWARNING: Script must be run as root to update the OS trust store\n'
    return 1
  fi

  # Script running as root

  # Check whether or not OS is macOS
  local cert_fingerprints ca_record alias fingerprint cert
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS

    # Determine SHA1 fingerprints of added roots
    #
    # Note: Unfortunately macOS does not support SHA256 fingerprints yet, otherwise we'd be using them
    cert_fingerprints=$(security find-certificate -a -Z "/Library/Keychains/System.keychain" \
                                                        "/System/Library/Keychains/SystemRootCertificates.keychain" \
                          | grep "SHA-1 hash")

    # Update system with added roots
    printf '\nAdding Apple Corporate Root CAs to OS trust store:\n'
    for ca_record in "${ca_records[@]}"; do
      alias=$(sed -n '1p' <<< "${ca_record}")
      fingerprint=$(sed -n '2p'  <<< "${ca_record}" | sed 's|SHA1: \(.*\)|\1|' | tr -d :)
      cert=$(sed '1,3d' <<< "${ca_record}")
      echo "  ${alias}"

      # Check whether or not root certificate is already present in the trust store
      if [[ "${cert_fingerprints}" =~ .*"${fingerprint}".* ]]; then
        # Present: no further action needed
        echo "    already present"
      else
        # Absent: add root certificate
        security add-trusted-cert -d -k "/Library/Keychains/System.keychain" <(echo "${cert}")
        echo "    added"
      fi
    done
    return 0
  fi

  # Check whether or not the OS supports trust store configuration via update-ca-trust
  if command -v "update-ca-trust" 1>/dev/null 2>&1 ; then
    # CentOS, RHEL

    # Determine fingerprints of already added roots
    cert_fingerprints=$(get_cert_fingerprints "/etc/pki/ca-trust/source/anchors")

    # Update OS roots
    add_roots "/etc/pki/ca-trust/source/anchors" "pem" "${cert_fingerprints}"

    # Update system with added roots
    if [[ ${update_ca_trust_required} -ne 0 ]]; then

      # Instruct update-ca-trust to scan the SOURCE CONFIGURATION and produce updated versions of the consolidated
      # configuration files stored below the /etc/pki/ca-trust/extracted directory hierarchy.
      update-ca-trust "extract"

      #
      # RHEL 6 requires this after installing the update
      #
      # Check the consistency status, and if no problems are detected, enable the compatible CA trust replacements.
      # Backup copies of classic configuration files will be created.
      update-ca-trust "enable"
    fi
    return 0
  fi

  # Check whether or not the OS supports trust store configuration via update-ca-certificates
  if command -v "update-ca-certificates" 1>/dev/null 2>&1 ; then
    # Ubuntu, SUSE

    # Determine location of Directory of CA certificate trust anchors
    local ca_certs_path
    if [ -d "/usr/local/share/ca-certificates" ]; then
      # Ubuntu
      ca_certs_path="/usr/local/share/ca-certificates"
    elif [ -d "/usr/share/pki/trust/anchors" ]; then
      # SUSE
      ca_certs_path="/usr/share/pki/trust/anchors"
    else
      # Unsupported
      printf '\nWARNING: OS trust store update not supported (unable to locate Directory of CA certificate trust anchors)\n'
      return 1
    fi

    # Determine fingerprints of already added roots
    cert_fingerprints=$(get_cert_fingerprints "${ca_certs_path}")

    # Update OS roots
    add_roots "${ca_certs_path}" "crt" "${cert_fingerprints}"

    # Update system with added roots
    if [[ ${update_ca_trust_required} -ne 0 ]]; then

      # Instruct update-ca-certificates to updates the directory /etc/ssl/certs to hold SSL certificates and
      # generate ca-certificates.crt, a concatenated single-file list of certificates.
      update-ca-certificates
    fi
    return 0
  fi

  # update-ca-trust and update-ca-certificates commands not available; unable to update the trust store
  printf '\nWARNING: OS trust store update not supported (required commands missing: update-ca-trust and/or update-ca-certificates)\n'
  return 1
}

# INPUTS
# $1: match
# $@: elements
#
# OUTPUTS
# none
contains_element() {
  local -r match="${1}"
  shift
  for element in "$@"; do
    if [[ "${element}" == "${match}" ]]; then
      return 0
    fi
  done
  return 1
}

# INPUTS
# $trust_store_search_paths: array of trust store search paths; trust stores are searched for under these paths
#
# OUTPUTS
# java_trust_stores: array of java trust stores; each java trust store that is found is appended
# python_trust_stores: array of python trust stores; each java trust store that is found is appended
# openssl_trust_stores: array of open trust stores; each java trust store that is found is appended
find_additional_trust_stores() {
  printf '\n========================  Finding Non-OS Trust Stores  =========================\n'

  # Default trust store search paths
  user_search_paths_specified=1
  if [[ ${#trust_store_search_paths[@]} -eq 0 ]]; then
    trust_store_search_paths=("${TRUST_STORE_SEARCH_PATHS[@]}")
    user_search_paths_specified=0
  fi

  # IMPORTANT: Force read command delimit input only by newlines; the default behaviour is to split by spaces, tabs and
  # newlines this is need for processing the output of the `find` command
  local -r IFS=$'\n'

  # Find trust stores in all search paths
  local trust_store_search_path
  local trust_stores_find_result_item
  local trust_store_type
  printf '\nSearching for existing trust stores:\n'
  for trust_store_search_path in "${trust_store_search_paths[@]}"; do

    # skip ~ when using default search paths and user specified --no-user-dir
    if [[ \
        ${user_search_paths_specified} -eq 0 && \
        ${search_user_dir} -eq 0 && \
        "${trust_store_search_path}" == "${CURRENT_USER_DIR}" \
    ]]; then
        continue
    fi

    # Find trust stores in search path
    echo "  ${trust_store_search_path}"
    while read -r trust_stores_find_result_item; do

      # Determine type of trust store
      if [[ "${trust_stores_find_result_item}" == *cacerts ]]; then
        # Java
        trust_store_type="Java"
        if ! contains_element "${trust_stores_find_result_item}" "${java_trust_stores[@]}"; then
          java_trust_stores+=("${trust_stores_find_result_item}")
        fi
      elif [[ "${trust_stores_find_result_item}" == */cacert.pem ]]; then
        # Python
        trust_store_type="Python"
        if ! contains_element "${trust_stores_find_result_item}" "${python_trust_stores[@]}"; then
          python_trust_stores+=("${trust_stores_find_result_item}")
        fi
      elif [[ "${trust_stores_find_result_item}" == */cert.pem ]] ||
           [[ "${trust_stores_find_result_item}" == */cacerts.pem ]]; then
        # OpenSSL
        trust_store_type="OpenSSL"
        if ! contains_element "${trust_stores_find_result_item}" "${openssl_trust_stores[@]}"; then
          openssl_trust_stores+=("${trust_stores_find_result_item}")
        fi
      else
        # Unknown
        continue
      fi
      printf '    %s trust store found: %s\n' "${trust_store_type}" "${trust_stores_find_result_item}"

    done < <(find "${trust_store_search_path}" \
                  "${TRUST_STORE_FIND_FILTERS[@]}" \
                  "${TRUST_STORE_FIND_WHOLENAMES[@]}" \
                  2>/dev/null)
  done

  if [[ ${user_search_paths_specified} -eq 0 ]]; then
    # Find missing JetBrains custom trust stores in all search paths
    printf '\nSearching for missing JetBrains trust stores:\n'
    for trust_store_search_path in "${JETBRAINS_TRUST_STORE_SEARCH_PATHS[@]}"; do

      # Find missing JetBrains trust store in search path
      echo "  ${trust_store_search_path}"
      while read -r trust_stores_find_result_item; do
        trust_stores_find_result_item+="/cacerts"
        if [[ ! -f "${trust_stores_find_result_item}" ]]; then
          printf '    JetBrains trust store is missing: %s\n'  "${trust_stores_find_result_item}"
          java_trust_stores+=("${trust_stores_find_result_item}")
        fi
      done < <(find "${trust_store_search_path}" -wholename "*/Library/Caches/*/tasks" 2>/dev/null)
    done
  fi
}

# INPUTS
# java_trust_stores: array of java trust stores; these trust stores are updated
#
# OUTPUTS
# none
update_java_trust_stores() {
  printf '\n=========================  Updating Java Trust Stores  =========================\n'

  # Zero java default trust stores found; skip
  if [[ "${#java_trust_stores[@]}" -eq 0 ]]; then
    printf '\nNo Java trust stores found\n'
    return 0
  fi

  # One or more default java trust stores found; Identify trust stores
  local java_trust_store
  printf '\nJava trust stores found:\n'
  for java_trust_store in "${java_trust_stores[@]}"; do
    echo "  ${java_trust_store}"
  done

  # Update trust stores
  local keytool cert_fingerprints tmp_cert_file ca_record alias fingerprint cert return_code=0
  printf '\nAdding Apple Corporate Root CAs to Java trust stores:\n'
  for java_trust_store in "${java_trust_stores[@]}"; do
    echo "  ${java_trust_store}"

    # Find keytool binary for Java platform
    keytool="${java_trust_store/\/lib\/security\/*//bin/keytool}"
    if ! "${keytool}" -help >/dev/null 2>&1; then
      # Fall back to system default Java platform
      keytool="keytool"
      if ! "${keytool}" -help >/dev/null 2>&1; then
        echo "    WARN: Can not update ${java_trust_store} as keytool is not executable for this platform and system default keytool was not found."
        continue
      fi
    fi

    # Determine fingerprints of all root certificate that already present in the trust store
    if ! cert_fingerprints=$("${keytool}" -list \
                                     -keystore "${java_trust_store}" \
                                     -storepass "changeit" \
                                     -v \
                           | grep "SHA256: ") ; then
      return_code=1
    fi

    # Update trust store with each root
    tmp_cert_file="$(dirname "${java_trust_store}")/.trust_apple_corp_root_cas.tmp_cert.pem"
    for ca_record in "${ca_records[@]}"; do
      alias="$(sed -n '1p' <<< "${ca_record}") [trust_apple_corp_root_cas.sh]"
      fingerprint=$(sed -n '3p' <<< "${ca_record}")
      cert=$(sed '1,3d' <<< "${ca_record}")
      echo "    ${alias}"

      # Check whether or not root certificate is already present in the trust store
      if [[ "${cert_fingerprints}" =~ .*"${fingerprint}".* ]]; then
        # Present: no further action needed
        echo "      already present"
        continue
      fi

      # Absent: import root certificate into trust store

      # Ensure trust store file permission allow write
      if [[ -f "${java_trust_store}" ]] && [[ ! -w "${java_trust_store}" ]]; then
        echo "      ERROR: User does not have permission to modify trust store"
        return_code=1
        break
      fi

      # Attempt to insert root certificate into trust store
      #
      # Note: We write the CA certificate to a temporary file to workaround a known issue/limitation  in Java 17 that
      # results in "keytool error: java.io.IOException: Illegal seek" when attempting to pass the file using pipe
      # (e.g. -file <(echo "${cert}"))
      echo "${cert}" > "${tmp_cert_file}"
      if ! "${keytool}" -import -keystore "${java_trust_store}" \
                                -storepass "changeit" \
                                -alias "${alias}" \
                                -file "${tmp_cert_file}" \
                                -noprompt \
                                2> >(sed 's|^|      |') \
                                1> >(sed 's|^|      |') ; then
        # Import failed
        rm "${tmp_cert_file}"
        echo "      ERROR: Unable to add certificate to trust store"
        return_code=1
        break
      fi
      rm "${tmp_cert_file}"

      # Import succeeded
      echo "      added"
    done
  done
  return ${return_code}
}

# INPUTS
# python_trust_stores: array of java trust stores; these trust stores are updated
#
# OUTPUTS
# none
update_python_trust_stores() {
  printf '\n========================  Updating Python Trust Stores  ========================\n'

  # Zero python trust stores found; skip
  if [[ "${#python_trust_stores[@]}" -eq 0 ]]; then
    printf '\nNo Python trust stores found\n'
    return 0
  fi

  # One or more python trust stores found; Identify trust stores
  local python_trust_store
  printf '\nPython trust stores found:\n'
  for python_trust_store in "${python_trust_stores[@]}"; do
    echo "  ${python_trust_store}"
  done

  # Update trust stores
  local ca_record alias comment cert return_code=0
  printf '\nAdding Apple Corporate Root CAs to Python trust stores:\n'
  for python_trust_store in "${python_trust_stores[@]}"; do
    echo "  ${python_trust_store}"

    for ca_record in "${ca_records[@]}"; do
      alias=$(sed -n '1p' <<< "${ca_record}")
      comment=$(sed -n '1,3s/.*/# &/p;3q' <<< "${ca_record}")
      cert=$(sed '1,3d' <<< "${ca_record}")
      echo "    ${alias}"

      # Add root to trust store
      if ! add_root_to_pem_trust_store "${cert}" \
                                       "$(printf '\n# Added by trust_apple_corp_root_cas.sh\n%s\n%s' "${comment}" "${cert}")" \
                                       "${python_trust_store}" ; then
        return_code=1
      fi
    done
  done
  return ${return_code}
}

# INPUTS
# openssl_trust_stores: array of java trust stores; these trust stores are updated
#
# OUTPUTS
# none
update_openssl_trust_stores() {
  printf '\n=======================  Updating OpenSSL Trust Stores  ========================\n'

  # Zero OpenSSL trust stores found; skip
  if [[ "${#openssl_trust_stores[@]}" -eq 0 ]]; then
    printf '\nNo OpenSSL trust stores found\n'
    return 0
  fi

  # One or more openssl trust stores found; Identify trust stores
  local openssl_trust_store
  printf '\nOpenSSL trust stores found:\n'
  for openssl_trust_store in "${openssl_trust_stores[@]}"; do
    echo "  ${openssl_trust_store}"
  done

  # Repair corrupted PEM trust store caused by a bug in older versions of this script.
  #
  # Older versions of this script assumed that the PEM trust store file always ended with a newline character and
  # simply appended new certificates. Unfortunately, this was not the case for some versions of openssl (specifically
  # OpenSSL 1.0.2o  27 Mar 2018), which resulted in the last line in the file and the first line we append being merged
  # into a single line like the following:
  #
  # -----END CERTIFICATE-----Added by trust_apple_corp_root_cas.sh
  #
  # This merged line corrupted the PEM trust store, causing none of the certificates in it to be trusted by openssl.
  # The fix is to check for this problematic line and split it into two lines (as originally intended).
  #
  # Note: on macOS the sed command does not interpret the carriage return character (e.g. \n) in the replace pattern,
  # so we workaround this limitation by using a literal new line preceded by a line continuation character.
  local -r corrupt_line_regex='^-----END CERTIFICATE-----Added by trust_apple_corp_root_cas.sh$'
  local -r corrupt_line_replace=$'-----END CERTIFICATE-----\
Added by trust_apple_corp_root_cas.sh'
  printf '\nRepairing broken OpenSSL trust stores:\n'
  for openssl_trust_store in "${openssl_trust_stores[@]}"; do
    echo "  ${openssl_trust_store}"
    if grep -q -- "${corrupt_line_regex}" "${openssl_trust_store}"; then
      sed -i "" "s|${corrupt_line_regex}|${corrupt_line_replace}|g" "${openssl_trust_store}"
      echo "    repaired"
    else
      echo "    unaffected"
    fi
  done

  # Update trust stores
  local ca_record alias cert return_code=0
  printf '\nAdding Apple Corporate Root CAs to OpenSSL trust stores:\n'
  for openssl_trust_store in "${openssl_trust_stores[@]}"; do
    echo "  ${openssl_trust_store}"

    for ca_record in "${ca_records[@]}"; do
      alias=$(sed -n '1p' <<< "${ca_record}")
      cert=$(sed '1,3d' <<< "${ca_record}")
      echo "    ${alias}"

      # Add root to trust store
      if ! add_root_to_pem_trust_store "${cert}" \
                                       "$(printf 'Added by trust_apple_corp_root_cas.sh\n\n%s' "${ca_record}")" \
                                       "${openssl_trust_store}" ; then
        return_code=1
      fi
    done
  done
  return ${return_code}
}

# NOTE: these globals should only ever be modified by main!
trust_store_search_paths=()
ca_records=()
search_user_dir=1

main() {
  local arg
  local install_corp_roots install_apz_roots install_silk_road_roots install_golden_gate_roots
  install_corp_roots=1
  install_apz_roots=0
  install_silk_road_roots=0
  install_golden_gate_roots=0
  local update_os_trust_store
  update_os_trust_store=1
  local additional_cas_filenames=()

  # Process command options/arguments
  while [[ $# -gt 0 ]]; do
    arg="$1"
    case "${arg}" in
      # Help
      -\?|-h|--help)
        usage
        exit 0
        ;;
      # Exclude Corporate Roots
      --no-corp)
        install_corp_roots=0
        shift
        ;;
      # Include APZ Roots
      --apz)
        install_apz_roots=1
        shift
        ;;
      # Include Silk Road Roots
      --silk-road)
        install_silk_road_roots=1
        shift
        ;;
      # Include Golden Gate Roots
      --golden-gate)
        install_golden_gate_roots=1
        shift
        ;;
      # user dir
      --no-user-dir)
        search_user_dir=0
        shift
        ;;
      # os trust store
      --no-os-trust-store)
        update_os_trust_store=0
        shift
        ;;
      # additional cas
      --additional-cas)
        additional_cas_filenames+=("${2}")
        shift
        shift || handle_shift_error "${arg}"
        ;;
      # Default
      *)
        trust_store_search_paths+=("$arg")
        shift
        ;;
    esac
  done
  script_return_code=0

  # Add pre-configured Roots
  local pre_configured_ca_record pre_configured_ca_records=()
  if [[ ${install_corp_roots} -eq 1 ]]; then
    # Apple Corporate Roots
    pre_configured_ca_records+=("${ROOTS_CORP[@]}")
  fi
  if [[ ${install_apz_roots} -eq 1 ]]; then
    # APZ Roots
    pre_configured_ca_records+=("${ROOTS_APZ[@]}")
  fi
  if [[ ${install_silk_road_roots} -eq 1 ]]; then
    # Silk Road Roots
    pre_configured_ca_records+=("${ROOTS_SILK_ROAD[@]}")
  fi
  if [[ ${install_golden_gate_roots} -eq 1 ]]; then
    # Golden Gate Roots
    pre_configured_ca_records+=("${ROOTS_GOLDEN_GATE[@]}")
  fi
  for pre_configured_ca_record in "${pre_configured_ca_records[@]}"; do
    pre_configured_ca_record=$(sed '/^$/d' <<< "${pre_configured_ca_record}")
    ca_records+=("${pre_configured_ca_record}")
  done

  # Add additional CAs
  local additional_cas_filename additional_cas_content additional_ca_pem subject_and_issuer subject issuer
  local additional_ca_pems=()
  if [[ ${#additional_cas_filenames[@]} -gt 0 ]]; then
    assert_command_exists "openssl" "; please install this package"
  fi
  for additional_cas_filename in "${additional_cas_filenames[@]}"; do
    # Read content from additional CA file
    if ! additional_cas_content=$(cat "${additional_cas_filename}" 2>&1); then
      echo "ERROR: Failed while attempting to read additional CAs from file ${additional_cas_filename}"
      echo "${additional_cas_content}"
      return 1
    fi

    # Extract PEM certificates from additional CA file content
    while true; do
      # Extract first certificate from additional CA file content
      additional_ca_pem=$(sed -n \
        '/^-----BEGIN CERTIFICATE-----$/,/^-----END CERTIFICATE-----$/p;/^-----END CERTIFICATE-----$/q' \
        <<< "${additional_cas_content}")

      # Abort when all certificates in additional CA file content have been examined
      if [[ -z "${additional_ca_pem}" ]]; then
        break
      fi

      # Remove certificate from additional CA file content
      additional_cas_content="${additional_cas_content#*"${additional_ca_pem}"}"

      # Skip duplicates (certificates already scheduled for being added as trusted)
      if [[ "${additional_ca_pems[*]}" == *"${additional_ca_pem}"* ]] ||
         [[ "${pre_configured_ca_records[*]}" == *"${additional_ca_pem}"* ]]; then
        continue
      fi

      # Ensure certificate can be parsed (is valid PEM)
      if ! subject_and_issuer=$(openssl x509 -noout -subject -issuer <<< "${additional_ca_pem}" 2>&1); then
        echo "ERROR: Failed while attempting to parse additional CAs from file ${additional_cas_filename}"
        echo "${subject_and_issuer}"
        return 1
      fi

      # Ensure certificate is a Root CA certificate
      subject=$(grep "subject=" <<< "${subject_and_issuer}" | sed 's|[^=]*=\(.*\)|\1|')
      issuer=$(grep "issuer=" <<< "${subject_and_issuer}" | sed 's|[^=]*=\(.*\)|\1|')
      if [[ "${subject}" != "${issuer}" ]]; then
        echo "ERROR: Only Root CAs are permitted in additional CA file ${additional_cas_filename}"
        return 1
      fi
      additional_ca_pems+=("${additional_ca_pem}")
    done
  done

  # Convert CAs to be added from PEM to CA record representation (alias, sha1, sha256, pem)
  local alias sha1 sha256 ca_record
  for additional_ca_pem in "${additional_ca_pems[@]}"; do
    alias=$(openssl x509 -noout -subject -nameopt multiline <<< "${additional_ca_pem}" \
            | grep "commonName" \
            | head -1 \
            | sed 's|[^=]*=[ ]*\(.*\)|\1|' \
            | tr '[:upper:]' '[:lower:]' \
            | tr ' ' '_' \
    )
    sha1=$(openssl x509 -noout -fingerprint <<< "${additional_ca_pem}" \
           | sed 's|[^=]*=\(.*\)|SHA1: \1|' \
    )
    sha256=$(openssl x509 -noout -fingerprint -sha256 <<< "${additional_ca_pem}" \
             | sed 's|[^=]*=\(.*\)|SHA256: \1|' \
    )
    ca_record=$(printf '%s\n%s\n%s\n%s\n' "${alias}" "${sha1}" "${sha256}" "${additional_ca_pem}" | sed '/^$/d')
    ca_records+=("${ca_record}")
  done

  # List CAs to be added as trusted
  printf '\n===========================  CAs To Add As Trusted  ============================\n'
  printf '\nThe following CAs will be added (if not already present):\n'
  for ca_record in "${ca_records[@]}"; do
    alias=$(sed -n '1p' <<< "${ca_record}")
    echo "  ${alias}"
  done

  # Update OS trust store
  if [[ ${update_os_trust_store} -eq 1 ]]; then
    update_os_trust_store  || script_return_code=$?
  fi

  # Find additional trust stores (Java, Python, OpenSSL, JetBrains)
  java_trust_stores=()
  python_trust_stores=()
  openssl_trust_stores=()
  find_additional_trust_stores || script_return_code=$?

  # Update Java trust stores
  update_java_trust_stores || script_return_code=$?

  # Update Python trust stores
  update_python_trust_stores || script_return_code=$?

  # Update OpenSSL trust stores
  update_openssl_trust_stores || script_return_code=$?

  return ${script_return_code}
}

########################################################################################################################
# Main
########################################################################################################################

main "$@"
